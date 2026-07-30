import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/security/token_store.dart';
import 'package:qalam_mobile/core/session/current_user.dart';
import 'package:qalam_mobile/core/session/current_user_controller.dart';
import 'package:qalam_mobile/core/session/session_controller.dart';
import 'package:qalam_mobile/core/session/session_state.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

import '../../support/harness.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> _refreshOk() => Response<dynamic>(
  requestOptions: RequestOptions(path: '/auth/refresh'),
  statusCode: 200,
  data: <String, dynamic>{
    'success': true,
    'data': <String, dynamic>{
      'accessToken': fakeJwt(),
      'refreshToken': 'rt-rotated',
    },
  },
);

void main() {
  const CurrentUser user = CurrentUser(
    id: 'user-1',
    email: 'writer@qalam.test',
    username: 'writer',
    isEmailVerified: false,
  );

  test('cold start with no tokens → anonymous, currentUser null', () async {
    final ProviderContainer container = await buildTestContainer();
    addTearDown(container.dispose);
    final SessionState session = await container.read(
      sessionControllerProvider.future,
    );
    expect(session.isAnonymous, isTrue);
    expect(container.read(currentUserControllerProvider), isNull);
  });

  test(
    'remember-me OFF skips silent restore even with a refresh token present',
    () async {
      final MockDio dio = MockDio();
      final ProviderContainer container = await buildTestContainer(
        tokens: <String, String>{
          'qalam.refresh_token': 'rt',
          'qalam.access_token': fakeJwt(),
        },
        refreshClient: dio,
      );
      addTearDown(container.dispose);
      final SessionState session = await container.read(
        sessionControllerProvider.future,
      );
      expect(session.isAnonymous, isTrue);
      verifyNever(() => dio.post<dynamic>(any(), data: any(named: 'data')));
    },
  );

  test(
    'silent restore succeeds when remember-me ON and refresh works',
    () async {
      final MockDio dio = MockDio();
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _refreshOk());
      final ProviderContainer container = await buildTestContainer(
        tokens: <String, String>{
          'qalam.refresh_token': 'rt',
          'qalam.access_token': fakeJwt(),
        },
        rememberMe: true,
        refreshClient: dio,
      );
      addTearDown(container.dispose);

      final SessionState session = await container.read(
        sessionControllerProvider.future,
      );
      expect(session.isAuthenticated, isTrue);
      expect(session.role, Role.user);
    },
  );

  test(
    'silent restore fails gracefully to anonymous when refresh is rejected',
    () async {
      final MockDio dio = MockDio();
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            statusCode: 401,
          ),
        ),
      );
      final ProviderContainer container = await buildTestContainer(
        tokens: <String, String>{
          'qalam.refresh_token': 'rt',
          'qalam.access_token': fakeJwt(),
        },
        rememberMe: true,
        refreshClient: dio,
      );
      addTearDown(container.dispose);

      final SessionState session = await container.read(
        sessionControllerProvider.future,
      );
      expect(session.isAnonymous, isTrue);
    },
  );

  test(
    'establish → authenticated, currentUser set, tokens + remember-me persisted',
    () async {
      final ProviderContainer container = await buildTestContainer();
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .establish(
            user: user,
            accessToken: fakeJwt(),
            refreshToken: 'rt',
            rememberMe: true,
          );

      final SessionState session = container
          .read(sessionControllerProvider)
          .requireValue;
      expect(session.isAuthenticated, isTrue);
      expect(session.isEmailVerified, isFalse);
      expect(container.read(currentUserControllerProvider)?.username, 'writer');
      expect(container.read(tokenStoreProvider).accessToken, isNotNull);
      expect(container.read(preferencesStoreProvider).rememberMe, isTrue);
    },
  );

  test(
    'establish without a refresh token forces remember-me off (Google gap)',
    () async {
      final ProviderContainer container = await buildTestContainer();
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .establish(accessToken: fakeJwt(), rememberMe: true);

      expect(container.read(preferencesStoreProvider).rememberMe, isFalse);
      expect(
        container.read(sessionControllerProvider).requireValue.isAuthenticated,
        isTrue,
      );
    },
  );

  test('markEmailVerified flips the session + current-user flag', () async {
    final ProviderContainer container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(sessionControllerProvider.future);
    await container
        .read(sessionControllerProvider.notifier)
        .establish(
          user: user,
          accessToken: fakeJwt(),
          refreshToken: 'rt',
          rememberMe: true,
        );

    container.read(sessionControllerProvider.notifier).markEmailVerified();

    expect(
      container.read(sessionControllerProvider).requireValue.isEmailVerified,
      isTrue,
    );
    expect(
      container.read(currentUserControllerProvider)?.isEmailVerified,
      isTrue,
    );
  });

  test('signOut clears tokens, current user, and flips to anonymous', () async {
    final ProviderContainer container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(sessionControllerProvider.future);
    final TokenStore tokenStore = container.read(tokenStoreProvider);
    await container
        .read(sessionControllerProvider.notifier)
        .establish(
          user: user,
          accessToken: fakeJwt(),
          refreshToken: 'rt',
          rememberMe: true,
        );

    await container.read(sessionControllerProvider.notifier).signOut();

    expect(
      container.read(sessionControllerProvider).requireValue.isAnonymous,
      isTrue,
    );
    expect(container.read(currentUserControllerProvider), isNull);
    expect(tokenStore.accessToken, isNull);
    expect(await tokenStore.hasRefreshToken(), isFalse);
  });
}

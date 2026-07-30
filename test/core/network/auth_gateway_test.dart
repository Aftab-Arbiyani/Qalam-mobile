import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/network/auth_gateway.dart';
import 'package:qalam_mobile/core/security/token_store.dart';

import '../../support/harness.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> _refreshOk() => Response<dynamic>(
  requestOptions: RequestOptions(path: '/auth/refresh'),
  statusCode: 200,
  data: <String, dynamic>{
    'success': true,
    'data': <String, dynamic>{
      'accessToken': 'at_new',
      'refreshToken': 'rt_new',
    },
  },
);

void main() {
  late MockDio refreshClient;
  late TokenStore tokenStore;
  late AuthGateway gateway;

  setUp(() {
    refreshClient = MockDio();
    tokenStore = TokenStore(
      buildFakeSecureStorage(<String, String>{
        'qalam.refresh_token': 'rt_old',
        'qalam.access_token': 'at_old',
      }),
    );
    gateway = AuthGateway(
      tokenStore: tokenStore,
      config: testConfig,
      logger: AppLogger(flavor: AppFlavor.development),
      refreshClient: refreshClient,
    );
  });

  test('concurrent refreshes are single-flight (one network call)', () async {
    when(
      () => refreshClient.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return _refreshOk();
    });

    final List<bool> results = await Future.wait<bool>(<Future<bool>>[
      gateway.refresh(),
      gateway.refresh(),
      gateway.refresh(),
    ]);

    expect(results, everyElement(isTrue));
    verify(
      () => refreshClient.post<dynamic>(any(), data: any(named: 'data')),
    ).called(1);
    expect(tokenStore.accessToken, 'at_new');
  });

  test('refresh failure clears success and returns false', () async {
    when(
      () => refreshClient.post<dynamic>(any(), data: any(named: 'data')),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 401,
        ),
      ),
    );

    expect(await gateway.refresh(), isFalse);
  });

  test('unauthorized handler clears tokens and fires the callback', () async {
    var fired = false;
    gateway.onUnauthorized = () => fired = true;
    await gateway.handleTerminalUnauthorized();
    expect(fired, isTrue);
    expect(await tokenStore.hasRefreshToken(), isFalse);
  });
}

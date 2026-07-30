import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/connectivity/connectivity_service.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/session/session_controller.dart';
import 'package:qalam_mobile/core/session/session_state.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/social/social_providers.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';
import 'package:qalam_mobile/shared/widgets/social/follow_button.dart';

import '../../../support/fake_reading_repository.dart';

/// A synchronous online connectivity — no platform channel, no stream churn.
class _OnlineConnectivity implements ConnectivityService {
  @override
  bool get isOnline => true;
  @override
  Stream<bool> get onStatusChange => const Stream<bool>.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _AuthedSession extends SessionController {
  @override
  Future<SessionState> build() async =>
      const SessionState.authenticated(role: Role.user);
}

class _AnonSession extends SessionController {
  @override
  Future<SessionState> build() async => const SessionState.anonymous();
}

ProviderContainer _container({required bool authed}) => ProviderContainer(
  overrides: [
    connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
    engagementRepositoryProvider.overrideWithValue(FakeEngagementRepository()),
    sessionControllerProvider.overrideWith(
      authed ? _AuthedSession.new : _AnonSession.new,
    ),
  ],
);

Widget _wrap(ProviderContainer c, Widget child) => UncontrolledProviderScope(
  container: c,
  child: MaterialApp(
    theme: buildQalamTheme(brightness: Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('signed out → hidden', (WidgetTester tester) async {
    final ProviderContainer c = _container(authed: false);
    addTearDown(c.dispose);
    await c.read(sessionControllerProvider.future);
    await tester.pumpWidget(
      _wrap(c, const FollowButton(userId: 'u1', isPrivate: false)),
    );
    await tester.pump();
    expect(find.text('Follow'), findsNothing);
  });

  testWidgets('signed in → shows the Follow affordance', (
    WidgetTester tester,
  ) async {
    final ProviderContainer c = _container(authed: true);
    addTearDown(c.dispose);
    await c.read(sessionControllerProvider.future);
    await tester.pumpWidget(
      _wrap(c, const FollowButton(userId: 'u1', isPrivate: false)),
    );
    await tester.pump();
    expect(find.text('Follow'), findsOneWidget);
  });

  testWidgets('an already-followed writer shows Following', (
    WidgetTester tester,
  ) async {
    final ProviderContainer c = _container(authed: true);
    addTearDown(c.dispose);
    await c.read(sessionControllerProvider.future);
    await tester.pumpWidget(
      _wrap(
        c,
        const FollowButton(
          userId: 'u1',
          isPrivate: false,
          initiallyFollowing: true,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('Follow'), findsNothing);
  });
}

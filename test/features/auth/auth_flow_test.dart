import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:qalam_mobile/features/profile/presentation/screens/my_profile_screen.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/harness.dart';

void main() {
  testWidgets('login flow: creds → session established → profile surface', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository fake = FakeAuthRepository();
    await pumpTestApp(tester, authRepository: fake);

    // Reach login by tapping the protected profile tab.
    await tester.tap(find.text('Profile'));
    await settleFrames(tester);
    expect(find.byType(LoginScreen), findsOneWidget);

    // Enter credentials (email field, then password field).
    await tester.enterText(find.byType(TextField).at(0), 'writer@qalam.test');
    await tester.enterText(find.byType(TextField).at(1), 'secret1234');
    await settleFrames(tester);

    // Submit — the session establish does real async storage writes.
    await tapAndSettle(tester, find.text('Sign in'));

    expect(fake.loginCalls, 1);
    // The `/me` tab now hosts the real profile surface (M5).
    expect(find.byType(MyProfileScreen), findsOneWidget);
  });

  testWidgets('empty submit surfaces inline validation, no repo call', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository fake = FakeAuthRepository();
    await pumpTestApp(tester, authRepository: fake);
    await tester.tap(find.text('Profile'));
    await settleFrames(tester);

    await tester.tap(find.text('Sign in'));
    await settleFrames(tester);

    expect(find.text('This field is required.'), findsWidgets);
    expect(fake.loginCalls, 0);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('logout (via settings → account) tears down the session', (
    WidgetTester tester,
  ) async {
    // A tall surface so every account-settings row (incl. Log out) is on-screen.
    tester.view.physicalSize = const Size(500, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final FakeAuthRepository fake = FakeAuthRepository();
    await pumpTestApp(tester, authRepository: fake);

    await tester.tap(find.text('Profile'));
    await settleFrames(tester);
    await tester.enterText(find.byType(TextField).at(0), 'writer@qalam.test');
    await tester.enterText(find.byType(TextField).at(1), 'secret1234');
    await tapAndSettle(tester, find.text('Sign in'));
    expect(find.byType(MyProfileScreen), findsOneWidget);

    // Profile → Settings → Account → Log out.
    await tapAndSettle(tester, find.byIcon(Icons.settings_outlined));
    await tapAndSettle(tester, find.text('Account'));
    await tapAndSettle(tester, find.text('Log out'));

    expect(fake.logoutCalls, 1);
    // The account tab is protected → an anonymous session bounces to login.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

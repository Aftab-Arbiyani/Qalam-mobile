import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/auth/presentation/screens/change_password_screen.dart';
import 'package:qalam_mobile/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:qalam_mobile/features/reading/presentation/screens/appearance_settings_screen.dart';
import 'package:qalam_mobile/features/settings/presentation/screens/settings_hub_screen.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_profile_repository.dart';
import '../../support/harness.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(500, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  late final Widget app;
  await tester.runAsync(() async {
    app = await buildTestApp(
      profileRepository: FakeProfileRepository(),
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: screen,
      ),
    );
  });
  await tester.pumpWidget(app);
  await settleFrames(tester);
}

void main() {
  testWidgets('Settings hub lists the section entries', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const SettingsHubScreen());
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Appearance & reading'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Design gallery'), findsOneWidget);
  });

  testWidgets('Appearance screen renders reading + app preference controls', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const AppearanceSettingsScreen());
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    expect(find.text('Reading width'), findsOneWidget);
    expect(find.text('Default feed'), findsOneWidget);
    expect(find.text('Autoplay media'), findsOneWidget);
  });

  testWidgets('Change password: empty submit surfaces required errors', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const ChangePasswordScreen());
    await tester.tap(find.text('Update password'));
    await settleFrames(tester);
    expect(find.text('Required.'), findsWidgets);
  });

  testWidgets('Edit profile renders the form fields and save action', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const ProfileEditScreen());
    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
    expect(find.text('Website'), findsOneWidget);
    expect(find.text('Default language'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}

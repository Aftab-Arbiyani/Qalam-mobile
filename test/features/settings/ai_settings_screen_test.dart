/// B5 (`platfrom/docs/45` §4.10) — the account's own "turn AI off" switch, on mobile.
///
/// These assert REACHABILITY and effect, not wire shape: that the tile is on the settings
/// hub at all (mobile's record here is four surfaces that looked wired and were not —
/// R-1, M5-1, W5-3, W8-1), that flipping it actually reaches the repository, and that a
/// failed write rolls the switch back instead of leaving the writer believing AI is off.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/settings/presentation/screens/ai_settings_screen.dart';
import 'package:qalam_mobile/features/settings/presentation/screens/settings_hub_screen.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_user_settings_repository.dart';
import '../../support/harness.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  FakeUserSettingsRepository? settings,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = const Size(500, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  late final Widget app;
  await tester.runAsync(() async {
    app = await buildTestApp(
      userSettingsRepository: settings ?? FakeUserSettingsRepository(),
      child: MaterialApp(
        theme: buildQalamTheme(brightness: brightness),
        home: screen,
      ),
    );
  });
  await tester.pumpWidget(app);
  await settleFrames(tester);
}

void main() {
  testWidgets('the settings hub has a way in — the switch is not orphaned', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const SettingsHubScreen());

    // A screen the router knows about and no menu links to is the R-1 defect class.
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Use AI on this account'), findsOneWidget);
  });

  testWidgets('renders on by default — an existing writer is unaffected', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const AiSettingsScreen());

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('renders off for a writer who already turned AI off', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const AiSettingsScreen(),
      settings: FakeUserSettingsRepository(aiEnabled: false),
    );

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('turning it off goes to the SERVER, not just the screen', (
    WidgetTester tester,
  ) async {
    final FakeUserSettingsRepository repo = FakeUserSettingsRepository();
    await _pump(tester, const AiSettingsScreen(), settings: repo);

    await tester.tap(find.byType(Switch));
    await settleFrames(tester);

    // The whole feature rests on this being a server write: a purely local hide would
    // leave every AI request still succeeding.
    expect(repo.writes, <bool>[false]);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets(
    'and back on again — the remedy the error copy promises must work',
    (WidgetTester tester) async {
      final FakeUserSettingsRepository repo = FakeUserSettingsRepository(
        aiEnabled: false,
      );
      await _pump(tester, const AiSettingsScreen(), settings: repo);

      await tester.tap(find.byType(Switch));
      await settleFrames(tester);

      expect(repo.writes, <bool>[true]);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    },
  );

  testWidgets('a failed save rolls back rather than lying about the state', (
    WidgetTester tester,
  ) async {
    final FakeUserSettingsRepository repo = FakeUserSettingsRepository(
      failWrites: true,
    );
    await _pump(tester, const AiSettingsScreen(), settings: repo);

    await tester.tap(find.byType(Switch));
    await settleFrames(tester);

    expect(repo.writes, <bool>[false]);
    // Still on: the server never accepted it, and showing it off would tell the writer
    // AI was disabled while every request still went through.
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(find.textContaining('unchanged'), findsOneWidget);
  });

  testWidgets('names the difference from the training consent', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const AiSettingsScreen());

    // §4.10: the two must be legible as different choices to a non-technical writer.
    expect(
      find.textContaining('separate from whether your work may be used'),
      findsOneWidget,
    );
  });

  testWidgets('renders in dark mode too (docs/45 §2 step 5)', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const AiSettingsScreen(), brightness: Brightness.dark);

    expect(find.text('Use AI on this account'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });
}

/// The Usage screen (**D5**, M3).
///
/// It was the "AI usage" dashboard: token counts, an estimated dollar cost, a projected
/// monthly spend, and a per-feature token breakdown. **The absences below are the
/// feature.** None of that was a fact about writing — a poet cannot decide anything from
/// "42,150 tokens", and showing them the provider's cost of serving them makes an
/// editing tool feel like a taxi meter running over their draft.
///
/// What replaces it is one line a writer can act on per tool, and the parse that feeds
/// it has one trap worth pinning: `limit: 0` is `PlanLimits`' sentinel for *unlimited*,
/// so reading it as a real ceiling would render "3 of 0 today" — a permanent lock on an
/// unlimited plan.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/core/config/app_config.dart';
import 'package:umberleaf_mobile/core/config/app_flavor.dart';
import 'package:umberleaf_mobile/core/di/providers.dart';
import 'package:umberleaf_mobile/core/utils/typedefs.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/usage_summary.dart';
import 'package:umberleaf_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:umberleaf_mobile/features/monetization/presentation/screens/usage_dashboard_screen.dart';
import 'package:umberleaf_mobile/shared/theme/app_theme.dart';

const AppConfig _monetizationOn = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: true,
  enableMonetization: true,
  enableCollaboration: false,
);

/// The wire shape, parsed rather than constructed: the field names and the `unlimited`
/// flag are half of what this screen depends on, and a hand-built entity would skip them.
MonetizationUsageSummary _summary(List<Json> quotas) =>
    MonetizationUsageSummary.fromJson(<String, dynamic>{'quotas': quotas});

Json _quota({
  String limitKey = 'polishActionsPerDay',
  String label = 'Polish',
  String window = 'daily',
  int used = 12,
  Object? limit = 30,
  bool unlimited = false,
}) => <String, dynamic>{
  'limitKey': limitKey,
  'label': label,
  'window': window,
  'used': used,
  'limit': limit,
  'unlimited': unlimited,
  'resetsAt': null,
};

Future<void> _pump(
  WidgetTester tester,
  MonetizationUsageSummary summary,
) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_monetizationOn),
        monetizationUsageProvider.overrideWith((_) async => summary),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const UsageDashboardScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('shows one line per tool, and no tokens or cost anywhere', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      _summary(<Json>[
        _quota(),
        _quota(
          limitKey: 'storyAnalysesPerMonth',
          label: 'Story analyses',
          window: 'monthly',
          used: 3,
          limit: 20,
        ),
      ]),
    );

    expect(find.text('Usage'), findsOneWidget);
    expect(find.text('Polish'), findsOneWidget);
    expect(find.text('12 of 30 today'), findsOneWidget);
    expect(find.text('Story analyses'), findsOneWidget);
    expect(find.text('3 of 20 this month'), findsOneWidget);

    // The removals, asserted. Each of these was on the old screen.
    for (final String gone in <String>[
      'token',
      'Token',
      'cost',
      'Cost',
      'Forecast',
      'Lifetime',
      'AI',
    ]) {
      expect(
        find.textContaining(gone),
        findsNothing,
        reason: '"$gone" must not appear on the Usage screen',
      );
    }
  });

  /// `0` is `PlanLimits`' unlimited sentinel, and so is a literal `null`. Reading
  /// either as a ceiling renders "3 of 0 today" — which looks like a permanent lock on
  /// a plan that has none.
  testWidgets('an unlimited allowance says so, and draws no bar', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      _summary(<Json>[
        _quota(used: 3, limit: 0),
        _quota(
          limitKey: 'feedbackReportsPerDay',
          label: 'Manuscript feedback',
          used: 1,
          limit: null,
          unlimited: true,
        ),
      ]),
    );

    expect(find.text('Unlimited'), findsNWidgets(2));
    expect(find.textContaining('of 0'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('a spent allowance says when it comes back, and offers no plan', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _summary(<Json>[_quota(used: 30)]));

    expect(find.text('30 of 30 today'), findsOneWidget);
    expect(find.textContaining('used today’s allowance'), findsOneWidget);
    // The remedy for a spent allowance is waiting. Selling a plan here would sell
    // someone something they do not need (docs/48 §5.2, consequence 2).
    expect(find.textContaining('plan'), findsNothing);
    expect(find.textContaining('Upgrade'), findsNothing);
  });

  /// Not an error, and not "you have used nothing": the server sends no rows when
  /// limits are not being enforced for this account.
  testWidgets('no allowances reads as unlimited, not as broken', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _summary(const <Json>[]));

    expect(find.text('Nothing to report yet'), findsOneWidget);
    expect(find.textContaining('aren’t limited'), findsOneWidget);
  });
}

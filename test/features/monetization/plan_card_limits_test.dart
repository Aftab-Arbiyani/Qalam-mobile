/// What a plan card promises (**D5**, M3).
///
/// The card used to end with "5,000 AI credits / month". A credit balance is a currency
/// a writer has to learn before it means anything, and learning it teaches them to
/// think about their editing in units of machine time. The card now names what those
/// credits bought: "100 polish actions a day".
///
/// The two assertions that matter are about what does NOT appear. A plan's `limits` map
/// is open, so rendering every key is how a token budget walks back onto the card — and
/// `featureLabel` must not name `ai_budget`, which the server still lists in `features`
/// until Phase V.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/core/config/app_config.dart';
import 'package:umberleaf_mobile/core/config/app_flavor.dart';
import 'package:umberleaf_mobile/core/di/providers.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/plan.dart';
import 'package:umberleaf_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:umberleaf_mobile/features/monetization/presentation/screens/plans_screen.dart';
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

/// A catalogue shaped like the real one mid-D5: the plan still carries `ai_budget` in
/// `features` (Phase V has not contracted it) and still carries token keys in `limits`
/// (they are only removed from `DEFAULT_PLAN_LIMITS` at V). Both must be invisible.
const PlanCatalogue _catalogue = PlanCatalogue(
  currency: 'usd',
  plans: <Plan>[
    Plan(
      tier: PlanTier.plus,
      name: 'Plus',
      description: 'For writers who edit closely.',
      features: <String>[PremiumFeature.aiWriting, 'ai_budget'],
      limits: <String, int>{
        'polishActionsPerDay': 100,
        'feedbackReportsPerDay': 20,
        'storyAnalysesPerMonth': 20,
        'maxCollaborators': 3,
        'aiMonthlyTokens': 250000,
        'aiMonthlyCredits': 5000,
      },
      prices: <String, Map<String, int>>{
        BillingInterval.monthly: <String, int>{'usd': 999},
      },
      trialDays: 0,
    ),
  ],
);

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_monetizationOn),
        plansProvider.overrideWith((_) async => _catalogue),
        currentSubscriptionProvider.overrideWith((_) async => null),
        entitlementSnapshotProvider.overrideWith(
          (_) async => const EntitlementSnapshot(
            tier: PlanTier.free,
            status: EntitlementStatus.allow,
            features: <EntitlementDecision>[],
          ),
        ),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const PlansScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('a plan card names the allowances, not a credit balance', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    expect(find.text('100 polish actions a day'), findsOneWidget);
    expect(find.text('20 feedback reports a day'), findsOneWidget);
    expect(find.text('20 story analyses a month'), findsOneWidget);
    expect(find.text('3 collaborators'), findsOneWidget);
  });

  /// The allowlist doing its job. `aiMonthlyTokens` and `aiMonthlyCredits` are in the
  /// plan's limits map and must not reach the card in any form — not as a number, not
  /// as a prettified key.
  testWidgets('no token or credit limit survives onto the card', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    for (final String gone in <String>[
      '250000',
      '250,000',
      '5000',
      '5,000',
      'token',
      'Token',
      'credit',
      'Credit',
    ]) {
      expect(
        find.textContaining(gone),
        findsNothing,
        reason: '"$gone" must not appear on a plan card',
      );
    }
  });

  /// `ai_budget` is still in `features` on the wire. It has no label any more, so it
  /// renders as its raw code — ugly and temporary, and deliberately preferred over a
  /// friendly name that would put a credit balance back on the card D5 cleared.
  testWidgets('the feature list is de-branded', (WidgetTester tester) async {
    await _pump(tester);

    expect(find.text('Polish & feedback'), findsOneWidget);
    expect(find.textContaining('AI Writing'), findsNothing);
    expect(find.textContaining('AI Usage'), findsNothing);
  });
}

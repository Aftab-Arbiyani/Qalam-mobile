/// [PremiumGate]'s own behaviour, at the widget level. Where it is *placed* — and that
/// it is placed at all, which is defect M5-1 — is pinned by
/// `premium_gate_placement_test.dart`.
///
/// The feature under test is `ai_budget` throughout — `PremiumGate` itself doesn't
/// care which feature it's given, so one is enough to pin the widget's own behaviour.
/// `ai_budget`, `ai_writing` (D3), and `story_intelligence` (D4) are the three the app
/// actually gates; every other catalogued feature is computed by the Entitlement
/// Service and asserted by no route, so gating one would withhold UI the server serves
/// freely (docs/48 §5.2).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:qalam_mobile/features/monetization/presentation/widgets/premium_gate.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

EntitlementSnapshot _snapshot({required bool allowBudget}) =>
    EntitlementSnapshot(
      tier: allowBudget ? PlanTier.pro : PlanTier.free,
      status: EntitlementStatus.allow,
      features: <EntitlementDecision>[
        EntitlementDecision(
          feature: PremiumFeature.aiBudget,
          status: allowBudget
              ? EntitlementStatus.allow
              : EntitlementStatus.deny,
          allowed: allowBudget,
          reason: allowBudget
              ? EntitlementReason.planIncludes
              : EntitlementReason.planExcludes,
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, {required bool allow}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        entitlementSnapshotProvider.overrideWith(
          (ref) async => _snapshot(allowBudget: allow),
        ),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const Scaffold(
          body: PremiumGate(
            feature: PremiumFeature.aiBudget,
            child: Text('unlocked-content'),
          ),
        ),
      ),
    ),
  );
  await tester.pump(); // resolve the async entitlement provider
}

void main() {
  testWidgets('PremiumGate renders the child when the feature is allowed', (
    WidgetTester tester,
  ) async {
    await _pump(tester, allow: true);
    expect(find.text('unlocked-content'), findsOneWidget);
    expect(find.textContaining('paid plan'), findsNothing);
  });

  testWidgets('PremiumGate renders the lock card when the feature is denied', (
    WidgetTester tester,
  ) async {
    await _pump(tester, allow: false);
    expect(find.text('unlocked-content'), findsNothing);
    // The lock names the feature and the server's own reason, not a generic
    // "premium feature" — the reason is what tells the reader what to do next.
    expect(find.textContaining('needs a paid plan'), findsOneWidget);
    expect(find.textContaining('Not in your current plan'), findsOneWidget);
    expect(find.text('See plans'), findsOneWidget);
  });

  testWidgets('a feature the snapshot never mentions fails closed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementSnapshotProvider.overrideWith(
            (ref) async => EntitlementSnapshot.free,
          ),
        ],
        child: MaterialApp(
          theme: buildQalamTheme(brightness: Brightness.light),
          home: const Scaffold(
            body: PremiumGate(
              feature: PremiumFeature.aiBudget,
              child: Text('unlocked-content'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('unlocked-content'), findsNothing);
  });

  testWidgets('optimistic renders the child while the snapshot is in flight', (
    WidgetTester tester,
  ) async {
    // Being briefly too strict costs a control that appears late; being too permissive
    // shows a control that then 402s. `optimistic` is for content the server refuses
    // either way, where a flash of lock on every open is the worse trade.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementSnapshotProvider.overrideWith((ref) async {
            await Future<void>.delayed(const Duration(seconds: 1));
            return EntitlementSnapshot.free;
          }),
        ],
        child: MaterialApp(
          theme: buildQalamTheme(brightness: Brightness.light),
          home: const Scaffold(
            body: PremiumGate(
              feature: PremiumFeature.aiBudget,
              optimistic: true,
              child: Text('unlocked-content'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('unlocked-content'), findsOneWidget);

    // Drain the in-flight snapshot so the test ends with no pending timer, then confirm
    // the resolved deny does take over — optimistic delays the lock, it never cancels it.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('unlocked-content'), findsNothing);
  });
}

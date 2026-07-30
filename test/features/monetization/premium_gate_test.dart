import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:qalam_mobile/features/monetization/presentation/widgets/premium_gate.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

EntitlementSnapshot _snapshot({required bool allowWriting}) => EntitlementSnapshot(
  tier: allowWriting ? PlanTier.pro : PlanTier.free,
  status: EntitlementStatus.allow,
  features: <EntitlementDecision>[
    EntitlementDecision(
      feature: PremiumFeature.aiWriting,
      status: allowWriting ? EntitlementStatus.allow : EntitlementStatus.deny,
      allowed: allowWriting,
      reason: allowWriting ? 'plan_includes' : 'plan_excludes',
    ),
  ],
);

Future<void> _pump(WidgetTester tester, {required bool allow}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        entitlementSnapshotProvider.overrideWith(
          (ref) async => _snapshot(allowWriting: allow),
        ),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const Scaffold(
          body: PremiumGate(
            feature: PremiumFeature.aiWriting,
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
    expect(find.textContaining('premium feature'), findsNothing);
  });

  testWidgets('PremiumGate renders the lock card when the feature is denied', (
    WidgetTester tester,
  ) async {
    await _pump(tester, allow: false);
    expect(find.text('unlocked-content'), findsNothing);
    expect(find.textContaining('premium feature'), findsOneWidget);
    expect(find.text('See plans'), findsOneWidget);
  });
}

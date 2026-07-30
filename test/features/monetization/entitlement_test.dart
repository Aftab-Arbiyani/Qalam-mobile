import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';

void main() {
  group('EntitlementSnapshot', () {
    test('allows() reflects the decision for a feature', () {
      const EntitlementSnapshot snapshot = EntitlementSnapshot(
        tier: PlanTier.pro,
        status: EntitlementStatus.allow,
        features: <EntitlementDecision>[
          EntitlementDecision(
            feature: PremiumFeature.aiWriting,
            status: EntitlementStatus.allow,
            allowed: true,
            reason: 'plan_includes',
          ),
          EntitlementDecision(
            feature: PremiumFeature.storyIntelligence,
            status: EntitlementStatus.deny,
            allowed: false,
            reason: 'plan_excludes',
          ),
        ],
      );

      expect(snapshot.allows(PremiumFeature.aiWriting), isTrue);
      expect(snapshot.allows(PremiumFeature.storyIntelligence), isFalse);
      expect(snapshot.isPremium, isTrue);
    });

    test('decisionFor() denies an unknown feature by default', () {
      const EntitlementSnapshot snapshot = EntitlementSnapshot.free;
      final EntitlementDecision decision =
          snapshot.decisionFor(PremiumFeature.advancedAnalytics);
      expect(decision.allowed, isFalse);
      expect(snapshot.isPremium, isFalse);
    });

    test('round-trips through JSON (cache persistence)', () {
      const EntitlementSnapshot original = EntitlementSnapshot(
        tier: PlanTier.plus,
        status: EntitlementStatus.trial,
        features: <EntitlementDecision>[
          EntitlementDecision(
            feature: PremiumFeature.aiDiscovery,
            status: EntitlementStatus.trial,
            allowed: true,
            reason: 'trial',
          ),
        ],
      );
      final EntitlementSnapshot restored =
          EntitlementSnapshot.fromJson(original.toJson());
      expect(restored.tier, PlanTier.plus);
      expect(restored.features.single.feature, PremiumFeature.aiDiscovery);
      expect(restored.allows(PremiumFeature.aiDiscovery), isTrue);
    });
  });

  group('plan rank helpers', () {
    test('orders tiers and detects upgrade/downgrade', () {
      expect(planRank(PlanTier.free), 0);
      expect(planRank(PlanTier.enterprise), 3);
      expect(isPlanUpgrade(PlanTier.free, PlanTier.pro), isTrue);
      expect(isPlanDowngrade(PlanTier.pro, PlanTier.plus), isTrue);
      expect(isPlanUpgrade(PlanTier.pro, PlanTier.pro), isFalse);
    });
  });
}

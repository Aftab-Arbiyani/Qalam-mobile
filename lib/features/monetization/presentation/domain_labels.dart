/// Human labels for monetization enum values (AF5) — presentation only. Kept pure so
/// screens never branch on raw wire strings for display copy.
library;

import '../domain/entities/monetization_enums.dart';

String planLabel(String tier) => switch (tier) {
  PlanTier.free => 'Free',
  PlanTier.plus => 'Plus',
  PlanTier.pro => 'Pro',
  PlanTier.enterprise => 'Enterprise',
  _ => tier,
};

String intervalLabel(String interval) => switch (interval) {
  BillingInterval.monthly => 'Monthly',
  BillingInterval.yearly => 'Yearly',
  _ => '',
};

String subscriptionStatusLabel(String status) => switch (status) {
  SubscriptionStatus.trialing => 'Free trial',
  SubscriptionStatus.active => 'Active',
  SubscriptionStatus.pastDue => 'Payment overdue',
  SubscriptionStatus.gracePeriod => 'Grace period',
  SubscriptionStatus.paused => 'Paused',
  SubscriptionStatus.canceled => 'Cancelled',
  SubscriptionStatus.expired => 'Expired',
  SubscriptionStatus.pendingActivation => 'Pending activation',
  _ => status,
};

String featureLabel(String feature) => switch (feature) {
  PremiumFeature.aiWriting => 'AI Writing Assistant',
  PremiumFeature.aiDiscovery => 'AI Discovery',
  PremiumFeature.storyIntelligence => 'Story Intelligence',
  PremiumFeature.premiumSearch => 'Premium Search',
  PremiumFeature.premiumRecommendations => 'Premium Recommendations',
  PremiumFeature.advancedAnalytics => 'Advanced Analytics',
  PremiumFeature.publishingPro => 'Pro Publishing',
  PremiumFeature.aiBudget => 'AI Usage',
  _ => feature,
};

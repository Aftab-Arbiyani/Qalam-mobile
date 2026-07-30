/// Monetization vocabulary (AF5) — a Dart mirror of `@qalam/shared` `monetization.ts`
/// (wire strings the API returns/accepts). Clients branch on these stable values,
/// never on message text. Server-authoritative: the client uses these to render a
/// HINT (lock/trial/grace/expired) and always defers to a fresh server response.
library;

/// Subscription plan tiers (ascending rank via [planRank]).
abstract final class PlanTier {
  static const String free = 'free';
  static const String plus = 'plus';
  static const String pro = 'pro';
  static const String enterprise = 'enterprise';

  static const List<String> ordered = <String>[free, plus, pro, enterprise];
}

/// Ascending rank of a plan tier (free=0 … enterprise=3; unknown → 0).
int planRank(String tier) {
  final int i = PlanTier.ordered.indexOf(tier);
  return i < 0 ? 0 : i;
}

bool isPlanUpgrade(String from, String to) => planRank(to) > planRank(from);
bool isPlanDowngrade(String from, String to) => planRank(to) < planRank(from);

/// Billing cadence.
abstract final class BillingInterval {
  static const String none = 'none';
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';
}

/// Subscription lifecycle state.
abstract final class SubscriptionStatus {
  static const String pendingActivation = 'pending_activation';
  static const String trialing = 'trialing';
  static const String active = 'active';
  static const String pastDue = 'past_due';
  static const String gracePeriod = 'grace_period';
  static const String paused = 'paused';
  static const String canceled = 'canceled';
  static const String expired = 'expired';
}

/// The effective per-feature access decision (what the client gates on).
abstract final class EntitlementStatus {
  static const String allow = 'allow';
  static const String limited = 'limited';
  static const String trial = 'trial';
  static const String gracePeriod = 'grace_period';
  static const String deny = 'deny';
  static const String expired = 'expired';
  static const String suspended = 'suspended';
  static const String pendingActivation = 'pending_activation';
  static const String cancelled = 'cancelled';
  static const String paused = 'paused';
}

/// Premium capabilities gated by the Entitlement service.
abstract final class PremiumFeature {
  static const String aiWriting = 'ai_writing';
  static const String aiDiscovery = 'ai_discovery';
  static const String storyIntelligence = 'story_intelligence';
  static const String premiumSearch = 'premium_search';
  static const String premiumRecommendations = 'premium_recommendations';
  static const String advancedAnalytics = 'advanced_analytics';
  static const String publishingPro = 'publishing_pro';
  static const String aiBudget = 'ai_budget';
}

/// Payment providers.
abstract final class PaymentProvider {
  static const String stripe = 'stripe';
  static const String appleAppStore = 'apple_app_store';
  static const String googlePlay = 'google_play';
}

/// What a coupon grants.
abstract final class PromotionType {
  static const String percentageDiscount = 'percentage_discount';
  static const String fixedDiscount = 'fixed_discount';
  static const String freeTrial = 'free_trial';
  static const String trialExtension = 'trial_extension';
  static const String promotionalCredits = 'promotional_credits';
  static const String freePeriod = 'free_period';
}

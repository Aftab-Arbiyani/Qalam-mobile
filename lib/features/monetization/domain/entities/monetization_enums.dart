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

/// Why the Entitlement Service reached the decision it did (`EntitlementReason`).
///
/// The client never derives a verdict from these — `allowed` is the answer — but the
/// reason decides the **remedy**, and the remedies are not interchangeable:
/// [quotaExceeded] resets on its own and waiting is enough, while [planExcludes] /
/// [noSubscription] never reset and only a plan changes them. Offering "See plans" to
/// someone who has to wait until tomorrow sells them something they do not need
/// (docs/48 §5.2, consequence 2).
abstract final class EntitlementReason {
  static const String planIncludes = 'plan_includes';
  static const String trial = 'trial';
  static const String gracePeriod = 'grace_period';
  static const String promotional = 'promotional';
  static const String temporaryAccess = 'temporary_access';
  static const String adminOverride = 'admin_override';
  static const String legacyPlan = 'legacy_plan';
  static const String quotaExceeded = 'quota_exceeded';
  static const String noSubscription = 'no_subscription';
  static const String planExcludes = 'plan_excludes';
  static const String featureDisabled = 'feature_disabled';
  static const String suspended = 'suspended';
  static const String expired = 'expired';
  static const String deniedOverride = 'denied_override';
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

/// Invoice lifecycle (`InvoiceStatus`).
abstract final class InvoiceStatus {
  static const String draft = 'draft';
  static const String open = 'open';
  static const String paid = 'paid';
  static const String voided = 'void';
  static const String uncollectible = 'uncollectible';
  static const String refunded = 'refunded';
}

/// Payment lifecycle (`PaymentStatus`).
abstract final class PaymentStatus {
  static const String pending = 'pending';
  static const String succeeded = 'succeeded';
  static const String failed = 'failed';
  static const String refunded = 'refunded';
  static const String partiallyRefunded = 'partially_refunded';
  static const String disputed = 'disputed';
  static const String canceled = 'canceled';
}

/// What was bought (`PurchaseKind`).
abstract final class PurchaseKind {
  static const String subscription = 'subscription';
  static const String credits = 'credits';
  static const String oneTime = 'one_time';
}

/// Purchase lifecycle (`PurchaseStatus`, append-only). `restored` = re-granted from a
/// store receipt.
abstract final class PurchaseStatus {
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String refunded = 'refunded';
  static const String restored = 'restored';
}

/// Why a credit ledger row exists (`CreditReason`).
abstract final class CreditReason {
  static const String purchase = 'purchase';
  static const String subscriptionGrant = 'subscription_grant';
  static const String trialGrant = 'trial_grant';
  static const String promotional = 'promotional';
  static const String referral = 'referral';
  static const String aiUsage = 'ai_usage';
  static const String refund = 'refund';
  static const String expiration = 'expiration';
  static const String adminAdjustment = 'admin_adjustment';
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

/// Coupon-code bounds, mirroring `@qalam/shared`'s `COUPON_CODE_MIN/MAX`.
/// `ValidateCouponDto` enforces `@MaxLength(COUPON_CODE_MAX)`, so a longer code is a
/// 400 rather than a "not valid" answer — the field caps input instead.
const int couponCodeMin = 3;
const int couponCodeMax = 40;

/// Normalize a coupon code for lookup — upper-case, trimmed.
///
/// A Dart mirror of `normalizeCouponCode` in `@qalam/shared`. The server looks a coupon
/// up by its normalized code, so sending `" summer24 "` verbatim finds nothing; the
/// lookup is not case-insensitive on the client's behalf.
String normalizeCouponCode(String code) => code.trim().toUpperCase();

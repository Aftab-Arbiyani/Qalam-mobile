/// Human labels for monetization enum values (AF5) — presentation only. Kept pure so
/// screens never branch on raw wire strings for display copy.
///
/// Every function falls back to the raw value rather than throwing or blanking: these
/// enumerations are deliberately OPEN on the wire (varchar columns, so a new tier or
/// provider lands without a migration — docs/37), so an unknown value is a
/// forward-compatible server, not a bug. Showing it verbatim is worse copy than a real
/// label and much better than an empty cell.
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

/// Why the server allowed or denied a feature, in a reader's words.
///
/// The lock card states the server's own reason rather than a generic "premium
/// feature" — the reason is what tells someone whether to wait or to upgrade.
String entitlementReasonLabel(String reason) => switch (reason) {
  EntitlementReason.planIncludes => 'Included in your plan',
  EntitlementReason.trial => 'Included in your trial',
  EntitlementReason.gracePeriod => 'Available during your grace period',
  EntitlementReason.promotional => 'Included by a promotion',
  EntitlementReason.temporaryAccess => 'Temporarily available',
  EntitlementReason.adminOverride => 'Granted for your account',
  EntitlementReason.legacyPlan => 'Included in your legacy plan',
  EntitlementReason.quotaExceeded => 'You’ve used your allowance',
  EntitlementReason.noSubscription => 'Needs a paid plan',
  EntitlementReason.planExcludes => 'Not in your current plan',
  EntitlementReason.featureDisabled => 'Not available yet',
  EntitlementReason.suspended => 'Unavailable while your account is suspended',
  EntitlementReason.expired => 'Your plan has expired',
  EntitlementReason.deniedOverride => 'Unavailable on your account',
  _ => reason,
};

/// How a payment was taken. Named because a receipt that says `apple_app_store` is the
/// app talking to itself.
String providerLabel(String provider) => switch (provider) {
  PaymentProvider.stripe => 'Card',
  PaymentProvider.appleAppStore => 'App Store',
  PaymentProvider.googlePlay => 'Google Play',
  _ => provider,
};

String invoiceStatusLabel(String status) => switch (status) {
  InvoiceStatus.draft => 'Draft',
  InvoiceStatus.open => 'Unpaid',
  InvoiceStatus.paid => 'Paid',
  InvoiceStatus.voided => 'Void',
  InvoiceStatus.uncollectible => 'Uncollectible',
  InvoiceStatus.refunded => 'Refunded',
  _ => status,
};

String paymentStatusLabel(String status) => switch (status) {
  PaymentStatus.pending => 'Pending',
  PaymentStatus.succeeded => 'Paid',
  PaymentStatus.failed => 'Failed',
  PaymentStatus.refunded => 'Refunded',
  PaymentStatus.partiallyRefunded => 'Partly refunded',
  PaymentStatus.disputed => 'Disputed',
  PaymentStatus.canceled => 'Cancelled',
  _ => status,
};

String purchaseKindLabel(String kind) => switch (kind) {
  PurchaseKind.subscription => 'Subscription',
  PurchaseKind.credits => 'AI credits',
  PurchaseKind.oneTime => 'One-off purchase',
  _ => kind,
};

String purchaseStatusLabel(String status) => switch (status) {
  PurchaseStatus.pending => 'Pending',
  PurchaseStatus.completed => 'Completed',
  PurchaseStatus.failed => 'Failed',
  PurchaseStatus.refunded => 'Refunded',
  // Not a synonym for completed: it means the entitlement was re-granted from a store
  // receipt rather than bought again, and a reader looking for a second charge needs to
  // see the difference.
  PurchaseStatus.restored => 'Restored',
  _ => status,
};

/// Why a credit ledger row exists. The dashboard used to strip the underscores, which
/// turned `subscription_grant` into "subscription grant" — readable, but not written.
String creditReasonLabel(String reason) => switch (reason) {
  CreditReason.purchase => 'Purchased',
  CreditReason.subscriptionGrant => 'Included with your plan',
  CreditReason.trialGrant => 'Trial credits',
  CreditReason.promotional => 'Promotional credits',
  CreditReason.referral => 'Referral bonus',
  CreditReason.aiUsage => 'AI usage',
  CreditReason.refund => 'Refunded',
  CreditReason.expiration => 'Expired',
  CreditReason.adminAdjustment => 'Adjustment',
  _ => reason,
};

/// A subscription event's `type`.
///
/// The wire types this as a plain `string`, not one of the labelled enumerations —
/// `SubscriptionEventType` exists in the vocabulary but `SubscriptionEventResponse.type`
/// is not narrowed to it. So underscores are stripped rather than mapped: the set the
/// server actually emits is not something the contract pins down.
String subscriptionEventLabel(String type) => type.replaceAll('_', ' ');

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

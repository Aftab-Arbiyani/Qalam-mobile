/// Subscription entities (AF5) — the client view of `GET /monetization/subscription`
/// and its history. Server owns the lifecycle; the client renders state + drives
/// actions (upgrade/downgrade/cancel/reactivate/pause/resume) that the server applies.
library;

import '../../../../core/utils/typedefs.dart';
import 'monetization_enums.dart';

class Subscription {
  const Subscription({
    required this.id,
    required this.tier,
    required this.status,
    required this.interval,
    required this.provider,
    required this.currency,
    required this.autoRenew,
    required this.cancelAtPeriodEnd,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialEnd,
    this.gracePeriodEnd,
    this.canceledAt,
    this.scheduledTier,
    this.scheduledInterval,
  });

  final String id;
  final String tier;
  final String status;
  final String interval;
  final String provider;
  final String currency;
  final bool autoRenew;
  final bool cancelAtPeriodEnd;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? trialEnd;
  final DateTime? gracePeriodEnd;
  final DateTime? canceledAt;
  final String? scheduledTier;
  final String? scheduledInterval;

  bool get isTrialing => status == SubscriptionStatus.trialing;
  bool get isActive => status == SubscriptionStatus.active;
  bool get isInGrace => status == SubscriptionStatus.gracePeriod;
  bool get isPaused => status == SubscriptionStatus.paused;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isCanceled => status == SubscriptionStatus.canceled;
  bool get hasScheduledChange => scheduledTier != null;

  factory Subscription.fromJson(Json json) => Subscription(
    id: json['id'] as String? ?? '',
    tier: json['tier'] as String? ?? PlanTier.free,
    status: json['status'] as String? ?? SubscriptionStatus.expired,
    interval: json['interval'] as String? ?? BillingInterval.none,
    provider: json['provider'] as String? ?? PaymentProvider.stripe,
    currency: json['currency'] as String? ?? 'usd',
    autoRenew: json['autoRenew'] as bool? ?? false,
    cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
    currentPeriodStart: _date(json['currentPeriodStart']),
    currentPeriodEnd: _date(json['currentPeriodEnd']),
    trialEnd: _date(json['trialEnd']),
    gracePeriodEnd: _date(json['gracePeriodEnd']),
    canceledAt: _date(json['canceledAt']),
    scheduledTier: json['scheduledTier'] as String?,
    scheduledInterval: json['scheduledInterval'] as String?,
  );
}

class SubscriptionEvent {
  const SubscriptionEvent({
    required this.id,
    required this.type,
    required this.createdAt,
    this.fromTier,
    this.toTier,
  });

  final String id;
  final String type;
  final DateTime createdAt;
  final String? fromTier;
  final String? toTier;

  factory SubscriptionEvent.fromJson(Json json) => SubscriptionEvent(
    id: json['id'] as String? ?? '',
    type: json['type'] as String? ?? '',
    createdAt: _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    fromTier: json['fromTier'] as String?,
    toTier: json['toTier'] as String?,
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

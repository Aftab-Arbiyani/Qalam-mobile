/// Entitlement entities (AF5) — the client view of the server-authoritative
/// entitlement snapshot (`GET /monetization/entitlements`). The snapshot is the
/// SINGLE source of truth the app gates premium UI on; it is cached locally for a
/// snappy, offline-tolerant read but a fresh server response always wins.
library;

import '../../../../core/utils/typedefs.dart';
import 'monetization_enums.dart';

/// One premium feature's decision.
class EntitlementDecision {
  const EntitlementDecision({
    required this.feature,
    required this.status,
    required this.allowed,
    required this.reason,
    this.expiresAt,
    this.remaining,
    this.limit,
  });

  final String feature;
  final String status;
  final bool allowed;
  final String reason;
  final DateTime? expiresAt;
  final int? remaining;
  final int? limit;

  bool get isTrial => status == EntitlementStatus.trial;
  bool get isGrace => status == EntitlementStatus.gracePeriod;
  bool get isLimited => status == EntitlementStatus.limited;

  factory EntitlementDecision.fromJson(Json json) => EntitlementDecision(
    feature: json['feature'] as String? ?? '',
    status: json['status'] as String? ?? EntitlementStatus.deny,
    allowed: json['allowed'] as bool? ?? false,
    reason: json['reason'] as String? ?? '',
    expiresAt: _date(json['expiresAt']),
    remaining: (json['remaining'] as num?)?.toInt(),
    limit: (json['limit'] as num?)?.toInt(),
  );

  Json toJson() => <String, Object?>{
    'feature': feature,
    'status': status,
    'allowed': allowed,
    'reason': reason,
    'expiresAt': expiresAt?.toIso8601String(),
    'remaining': remaining,
    'limit': limit,
  };
}

/// The full entitlement snapshot for the current user.
class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.tier,
    required this.status,
    required this.features,
    this.refreshAt,
  });

  final String tier;
  final String status;
  final List<EntitlementDecision> features;
  final DateTime? refreshAt;

  bool get isPremium => planRank(tier) > planRank(PlanTier.free);

  /// The decision for a feature (denied by default when absent).
  EntitlementDecision decisionFor(String feature) => features.firstWhere(
    (EntitlementDecision d) => d.feature == feature,
    orElse: () => EntitlementDecision(
      feature: feature,
      status: EntitlementStatus.deny,
      allowed: false,
      reason: 'plan_excludes',
    ),
  );

  /// Whether the user may use a premium feature (the gate the UI reads).
  bool allows(String feature) => decisionFor(feature).allowed;

  factory EntitlementSnapshot.fromJson(Json json) => EntitlementSnapshot(
    tier: json['tier'] as String? ?? PlanTier.free,
    status: json['status'] as String? ?? EntitlementStatus.allow,
    features: (json['features'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic e) => EntitlementDecision.fromJson(e as Json))
        .toList(growable: false),
    refreshAt: _date(json['refreshAt']),
  );

  Json toJson() => <String, Object?>{
    'tier': tier,
    'status': status,
    'features': features.map((EntitlementDecision d) => d.toJson()).toList(),
    'refreshAt': refreshAt?.toIso8601String(),
  };

  /// A safe default when the platform is off / offline with no cache: free tier,
  /// everything premium denied (fail-closed on premium; the app still works free).
  static const EntitlementSnapshot free = EntitlementSnapshot(
    tier: PlanTier.free,
    status: EntitlementStatus.allow,
    features: <EntitlementDecision>[],
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

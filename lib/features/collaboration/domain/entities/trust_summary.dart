/// Trust summary entities (AF6) — the client view of the current user's trust
/// standing (`GET /me/trust`): a score, level, coarse status, active strike weight,
/// and any active restrictions. The server is authoritative; the client renders the
/// standing and the restricted-state experiences (read-only / muted / suspended).
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

/// One active or historical restriction on the account.
class UserRestriction {
  const UserRestriction({
    required this.id,
    required this.type,
    required this.reason,
    required this.active,
    this.startsAt,
    this.expiresAt,
  });

  final String id;
  final String type;
  final String reason;
  final bool active;
  final DateTime? startsAt;
  final DateTime? expiresAt;

  bool get isPermanent => active && expiresAt == null;

  factory UserRestriction.fromJson(Json json) => UserRestriction(
    id: json['id'] as String? ?? '',
    type: json['type'] as String? ?? RestrictionType.restricted,
    reason: json['reason'] as String? ?? '',
    active: json['active'] as bool? ?? true,
    startsAt: _date(json['startsAt']),
    expiresAt: _date(json['expiresAt']),
  );
}

class TrustSummary {
  const TrustSummary({
    required this.score,
    required this.level,
    required this.status,
    required this.activeStrikeWeight,
    required this.restrictions,
  });

  final double score;
  final String level;
  final String status;
  final double activeStrikeWeight;
  final List<UserRestriction> restrictions;

  List<UserRestriction> get activeRestrictions => restrictions
      .where((UserRestriction r) => r.active)
      .toList(growable: false);

  bool get isGoodStanding =>
      status == TrustStatus.trusted || status == TrustStatus.normal;

  bool get isRestricted => !isGoodStanding || activeRestrictions.isNotEmpty;

  bool _hasRestriction(String type) =>
      activeRestrictions.any((UserRestriction r) => r.type == type);

  bool get isReadOnly =>
      status == TrustStatus.readOnly ||
      _hasRestriction(RestrictionType.readOnly);

  bool get isMuted =>
      status == TrustStatus.muted ||
      status == TrustStatus.shadowed ||
      _hasRestriction(RestrictionType.muted) ||
      _hasRestriction(RestrictionType.shadow);

  bool get isSuspended =>
      status == TrustStatus.suspended ||
      status == TrustStatus.banned ||
      _hasRestriction(RestrictionType.suspended);

  factory TrustSummary.fromJson(Json json) => TrustSummary(
    score: (json['score'] as num?)?.toDouble() ?? 0,
    level: json['level'] as String? ?? '',
    status: json['status'] as String? ?? TrustStatus.normal,
    activeStrikeWeight: (json['activeStrikeWeight'] as num?)?.toDouble() ?? 0,
    restrictions: (json['restrictions'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (dynamic e) =>
              UserRestriction.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false),
  );

  /// A fail-open default (good standing, no restrictions) — used when trust is
  /// unavailable so the app is not falsely gated.
  static const TrustSummary healthy = TrustSummary(
    score: 100,
    level: 'normal',
    status: TrustStatus.normal,
    activeStrikeWeight: 0,
    restrictions: <UserRestriction>[],
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

/// The writer-facing usage read — `GET /monetization/usage`.
///
/// **D5 changed what a writer is shown here, not just how it is worded.** The meter was
/// a token budget: daily/monthly/lifetime rollups, an estimated dollar cost, and a
/// projected monthly spend. None of that is a fact about writing. A poet cannot decide
/// anything from "42,150 tokens", and being shown the provider's cost of serving them
/// makes the tool feel like a taxi meter running over their draft.
///
/// The limits are per-feature **counts** now (B3), so the client reads `quotas` and
/// nothing else. The token rollups are still on the wire and are deliberately NOT
/// parsed: keeping a field the UI cannot show is how it creeps back.
///
/// `limit == null` (or `unlimited`) means no ceiling. `resetsAt` is when the window
/// rolls over.
library;

import '../../../../core/utils/typedefs.dart';

/// One tool's allowance in its window.
class FeatureAllowance {
  const FeatureAllowance({
    required this.key,
    required this.label,
    required this.window,
    required this.used,
    required this.limit,
    this.resetsAt,
  });

  /// The `PlanLimits` key this came from (e.g. `polishActionsPerDay`).
  final String key;

  /// The server's own label for the tool. Preferred over a client-side mapping so the
  /// two halves cannot drift; [allowanceNoun] covers a server that sends none.
  final String label;

  /// `daily` or `monthly` on the wire.
  final String window;
  final int used;

  /// `null` = no ceiling.
  final int? limit;
  final DateTime? resetsAt;

  bool get isUnlimited => limit == null;

  int? get remaining => limit == null ? null : (limit! - used).clamp(0, limit!);

  /// 0–1 for the progress bar; 0 when unlimited (nothing to fill toward).
  double get fraction =>
      limit == null || limit! <= 0 ? 0 : (used / limit!).clamp(0, 1).toDouble();

  bool get isExhausted => limit != null && used >= limit!;

  /// Tolerant by design: this list grows whenever a new `PlanLimits` key is metered,
  /// and a client that throws on an unfamiliar row would break on a server deploy.
  ///
  /// **`limit` is normalised to `null` for every non-positive value**, not only for a
  /// literal null. `0` is the sentinel for unlimited in `PlanLimits`, and a `<= 0`
  /// ceiling cannot mean anything else here — treating it as a real limit would render
  /// "3 of 0 today" and read as a permanent lock on an unlimited plan.
  factory FeatureAllowance.fromJson(Json json) {
    final int? rawLimit = (json['limit'] as num?)?.toInt();
    final bool unlimited = json['unlimited'] as bool? ?? false;
    return FeatureAllowance(
      key: json['limitKey'] as String? ?? '',
      label: json['label'] as String? ?? '',
      window: json['window'] as String? ?? '',
      used: ((json['used'] as num?)?.toInt() ?? 0).clamp(0, 1 << 31),
      limit: unlimited || rawLimit == null || rawLimit <= 0 ? null : rawLimit,
      resetsAt: _date(json['resetsAt']),
    );
  }
}

/// The whole usage read: one allowance per metered tool.
class MonetizationUsageSummary {
  const MonetizationUsageSummary({required this.features});

  final List<FeatureAllowance> features;

  bool get isEmpty => features.isEmpty;

  factory MonetizationUsageSummary.fromJson(Json json) =>
      MonetizationUsageSummary(
        features: (json['quotas'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> e) =>
                  FeatureAllowance.fromJson(Json.from(e)),
            )
            .toList(growable: false),
      );

  static const MonetizationUsageSummary empty = MonetizationUsageSummary(
    features: <FeatureAllowance>[],
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

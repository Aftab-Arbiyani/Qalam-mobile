/// AI usage + token-accounting domain types (AF2) — the client view of
/// `GET /ai/usage/me` (docs/34 §7). Token counts are authoritative from the server
/// (provider `usage`); the client only DISPLAYS them (estimated cost, daily/monthly/
/// lifetime windows, per-feature breakdown, remaining quota). Plain value types.
library;

import '../../../../core/utils/typedefs.dart';

/// Usage rolled up over one window (daily / monthly / lifetime).
class AiUsageWindow {
  const AiUsageWindow({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.requests,
    required this.estimatedCostUsd,
    this.tokenLimit,
    this.usedFraction,
  });

  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final int requests;
  final double estimatedCostUsd;

  /// The configured cap for this window (null = unlimited).
  final int? tokenLimit;

  /// Fraction of the cap consumed (0–1; null when unlimited).
  final double? usedFraction;

  /// Tokens still available in this window (null when unlimited).
  int? get remaining =>
      tokenLimit == null ? null : (tokenLimit! - totalTokens).clamp(0, tokenLimit!);

  bool get isUnlimited => tokenLimit == null;

  factory AiUsageWindow.fromJson(Json json) => AiUsageWindow(
        inputTokens: (json['inputTokens'] as num?)?.toInt() ?? 0,
        outputTokens: (json['outputTokens'] as num?)?.toInt() ?? 0,
        totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
        requests: (json['requests'] as num?)?.toInt() ?? 0,
        estimatedCostUsd: (json['estimatedCostUsd'] as num?)?.toDouble() ?? 0,
        tokenLimit: (json['tokenLimit'] as num?)?.toInt(),
        usedFraction: (json['usedFraction'] as num?)?.toDouble(),
      );

  static const AiUsageWindow zero = AiUsageWindow(
    inputTokens: 0,
    outputTokens: 0,
    totalTokens: 0,
    requests: 0,
    estimatedCostUsd: 0,
  );
}

/// One feature's lifetime usage row.
class AiFeatureUsage {
  const AiFeatureUsage({
    required this.feature,
    required this.totalTokens,
    required this.requests,
  });

  final String feature;
  final int totalTokens;
  final int requests;

  factory AiFeatureUsage.fromJson(Json json) => AiFeatureUsage(
        feature: json['feature'] as String? ?? '',
        totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
        requests: (json['requests'] as num?)?.toInt() ?? 0,
      );
}

/// `GET /ai/usage/me` — the caller's own usage across windows + per feature.
class AiUsageSummary {
  const AiUsageSummary({
    required this.daily,
    required this.monthly,
    required this.total,
    required this.byFeature,
  });

  final AiUsageWindow daily;
  final AiUsageWindow monthly;
  final AiUsageWindow total;
  final List<AiFeatureUsage> byFeature;

  factory AiUsageSummary.fromJson(Json json) {
    AiUsageWindow window(String key) {
      final Object? raw = json[key];
      return raw is Map ? AiUsageWindow.fromJson(Json.from(raw)) : AiUsageWindow.zero;
    }

    return AiUsageSummary(
      daily: window('daily'),
      monthly: window('monthly'),
      total: window('total'),
      byFeature: (json['byFeature'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> f) => AiFeatureUsage.fromJson(Json.from(f)))
          .toList(growable: false),
    );
  }
}

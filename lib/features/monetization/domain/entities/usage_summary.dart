/// Monetization AI-usage entities (AF5) — `GET /monetization/usage`: daily/monthly/
/// lifetime rollups + per-feature breakdown + a monthly forecast. Read-only display;
/// the server is authoritative on the counts.
library;

import '../../../../core/utils/typedefs.dart';

class MonetizationUsageWindow {
  const MonetizationUsageWindow({
    required this.window,
    required this.tokens,
    required this.credits,
    required this.requests,
    required this.costUsd,
    this.tokenLimit,
    this.creditLimit,
    this.usedFraction,
    this.resetsAt,
  });

  final String window;
  final int tokens;
  final int credits;
  final int requests;
  final double costUsd;
  final int? tokenLimit;
  final int? creditLimit;
  final double? usedFraction;
  final DateTime? resetsAt;

  bool get isUnlimited => tokenLimit == null;
  int? get remaining =>
      tokenLimit == null ? null : (tokenLimit! - tokens).clamp(0, tokenLimit!);

  factory MonetizationUsageWindow.fromJson(Json json) => MonetizationUsageWindow(
    window: json['window'] as String? ?? '',
    tokens: (json['tokens'] as num?)?.toInt() ?? 0,
    credits: (json['credits'] as num?)?.toInt() ?? 0,
    requests: (json['requests'] as num?)?.toInt() ?? 0,
    costUsd: (json['costUsd'] as num?)?.toDouble() ?? 0,
    tokenLimit: (json['tokenLimit'] as num?)?.toInt(),
    creditLimit: (json['creditLimit'] as num?)?.toInt(),
    usedFraction: (json['usedFraction'] as num?)?.toDouble(),
    resetsAt: _date(json['resetsAt']),
  );

  static const MonetizationUsageWindow zero = MonetizationUsageWindow(
    window: '',
    tokens: 0,
    credits: 0,
    requests: 0,
    costUsd: 0,
  );
}

class MonetizationFeatureUsage {
  const MonetizationFeatureUsage({
    required this.feature,
    required this.tokens,
    required this.credits,
    required this.requests,
  });

  final String feature;
  final int tokens;
  final int credits;
  final int requests;

  factory MonetizationFeatureUsage.fromJson(Json json) => MonetizationFeatureUsage(
    feature: json['feature'] as String? ?? '',
    tokens: (json['tokens'] as num?)?.toInt() ?? 0,
    credits: (json['credits'] as num?)?.toInt() ?? 0,
    requests: (json['requests'] as num?)?.toInt() ?? 0,
  );
}

class MonetizationUsageSummary {
  const MonetizationUsageSummary({
    required this.daily,
    required this.monthly,
    required this.total,
    required this.byFeature,
    required this.forecastMonthlyTokens,
    required this.forecastMonthlyCostUsd,
  });

  final MonetizationUsageWindow daily;
  final MonetizationUsageWindow monthly;
  final MonetizationUsageWindow total;
  final List<MonetizationFeatureUsage> byFeature;
  final int forecastMonthlyTokens;
  final double forecastMonthlyCostUsd;

  factory MonetizationUsageSummary.fromJson(Json json) => MonetizationUsageSummary(
    daily: MonetizationUsageWindow.fromJson(
      json['daily'] as Json? ?? const <String, Object?>{},
    ),
    monthly: MonetizationUsageWindow.fromJson(
      json['monthly'] as Json? ?? const <String, Object?>{},
    ),
    total: MonetizationUsageWindow.fromJson(
      json['total'] as Json? ?? const <String, Object?>{},
    ),
    byFeature: (json['byFeature'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic e) => MonetizationFeatureUsage.fromJson(e as Json))
        .toList(growable: false),
    forecastMonthlyTokens: (json['forecastMonthlyTokens'] as num?)?.toInt() ?? 0,
    forecastMonthlyCostUsd: (json['forecastMonthlyCostUsd'] as num?)?.toDouble() ?? 0,
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

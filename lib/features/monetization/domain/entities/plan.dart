/// Plan catalogue entities (AF5) — `GET /monetization/plans` for the comparison
/// screen. Prices are minor units (cents) keyed by interval then currency.
library;

import '../../../../core/utils/typedefs.dart';
import 'monetization_enums.dart';

class Plan {
  const Plan({
    required this.tier,
    required this.name,
    required this.description,
    required this.features,
    required this.limits,
    required this.monthlyCredits,
    required this.prices,
    required this.trialDays,
  });

  final String tier;
  final String name;
  final String description;
  final List<String> features;
  final Map<String, int> limits;
  final int monthlyCredits;

  /// interval → currency → minor units.
  final Map<String, Map<String, int>> prices;
  final int trialDays;

  bool get isFree => tier == PlanTier.free;

  /// Minor-unit price for an interval + currency (0 if not offered).
  int priceMinor(String interval, String currency) =>
      prices[interval]?[currency] ?? 0;

  factory Plan.fromJson(Json json) => Plan(
    tier: json['tier'] as String? ?? PlanTier.free,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    features: (json['features'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic e) => e as String)
        .toList(growable: false),
    limits: _intMap(json['limits']),
    monthlyCredits: (json['monthlyCredits'] as num?)?.toInt() ?? 0,
    prices: _priceMap(json['prices']),
    trialDays: (json['trialDays'] as num?)?.toInt() ?? 0,
  );
}

class PlanCatalogue {
  const PlanCatalogue({
    required this.plans,
    required this.currency,
    this.region,
  });

  final List<Plan> plans;
  final String currency;
  final String? region;

  factory PlanCatalogue.fromJson(Json json) => PlanCatalogue(
    plans: (json['plans'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic e) => Plan.fromJson(e as Json))
        .toList(growable: false),
    currency: json['currency'] as String? ?? 'usd',
    region: json['region'] as String?,
  );
}

Map<String, int> _intMap(Object? raw) {
  if (raw is! Map) return <String, int>{};
  return raw.map(
    (dynamic k, dynamic v) =>
        MapEntry<String, int>(k as String, (v as num?)?.toInt() ?? 0),
  );
}

Map<String, Map<String, int>> _priceMap(Object? raw) {
  if (raw is! Map) return <String, Map<String, int>>{};
  return raw.map(
    (dynamic k, dynamic v) =>
        MapEntry<String, Map<String, int>>(k as String, _intMap(v)),
  );
}

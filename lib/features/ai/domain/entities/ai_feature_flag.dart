/// AI feature-flag state (AF1) — the effective on/off of each AI feature for the
/// caller, from `GET /ai/features`. The runtime source of truth for gating an AI
/// affordance (the compile-time `AppConfig.enableAi` is the outer kill switch).
library;

import '../../../../core/utils/typedefs.dart';

class AiFeatureFlag {
  const AiFeatureFlag({required this.feature, required this.flagKey, required this.enabled});

  final String feature;
  final String flagKey;
  final bool enabled;

  factory AiFeatureFlag.fromJson(Json json) => AiFeatureFlag(
    feature: json['feature'] as String? ?? '',
    flagKey: json['flagKey'] as String? ?? '',
    enabled: json['enabled'] as bool? ?? false,
  );
}

class AiFeatures {
  const AiFeatures({required this.aiEnabled, required this.features});

  final bool aiEnabled;
  final List<AiFeatureFlag> features;

  /// A feature is usable only when the master switch AND its own flag are on.
  bool isEnabled(String feature) =>
      aiEnabled && features.any((flag) => flag.feature == feature && flag.enabled);

  factory AiFeatures.fromJson(Json json) => AiFeatures(
    aiEnabled: json['aiEnabled'] as bool? ?? false,
    features: (json['features'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> flag) => AiFeatureFlag.fromJson(Json.from(flag)))
        .toList(growable: false),
  );
}

/// AI feature-flag state (AF1) — the effective on/off of each AI feature for the
/// caller, from `GET /ai/features`. The runtime source of truth for gating an AI
/// affordance (the compile-time `AppConfig.enableAi` is the outer kill switch).
library;

import '../../../../core/utils/typedefs.dart';

class AiFeatureFlag {
  const AiFeatureFlag({
    required this.feature,
    required this.flagKey,
    required this.enabled,
  });

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
  const AiFeatures({
    required this.aiEnabled,
    required this.features,
    this.userAiEnabled = true,
  });

  /// AI is usable by this caller. Since B5 (`platfrom/docs/45` §4.10) this is the
  /// platform master flag AND [userAiEnabled] — one value, so every existing gate
  /// that reads it follows the account's own switch with no change.
  final bool aiEnabled;

  /// B5 — the caller's OWN "turn AI off" switch, reported separately so a screen can
  /// tell the two causes of `aiEnabled == false` apart and offer the right remedy:
  /// their settings, versus an administrator's platform switch they cannot affect.
  ///
  /// Precedence is admin-off-beats-user-on, so `userAiEnabled == true` alongside
  /// `aiEnabled == false` simply means the platform flag is down.
  ///
  /// **Defaults to `true` when absent**, so an older server (or a trimmed payload)
  /// never gets read as "this writer opted out".
  final bool userAiEnabled;

  final List<AiFeatureFlag> features;

  /// A feature is usable only when the master switch AND its own flag are on.
  bool isEnabled(String feature) =>
      aiEnabled &&
      features.any((flag) => flag.feature == feature && flag.enabled);

  /// B5 — AI is off specifically BECAUSE this writer turned it off, as opposed to an
  /// administrator's platform switch. The one question that decides which copy to show.
  bool get disabledByUser => !aiEnabled && !userAiEnabled;

  factory AiFeatures.fromJson(Json json) => AiFeatures(
    aiEnabled: json['aiEnabled'] as bool? ?? false,
    userAiEnabled: json['userAiEnabled'] as bool? ?? true,
    features: (json['features'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> flag) =>
              AiFeatureFlag.fromJson(Json.from(flag)),
        )
        .toList(growable: false),
  );
}

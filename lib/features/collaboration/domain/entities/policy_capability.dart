/// Policy capability entities (AF6) — the client view of the server-authoritative
/// capability map (`GET /stories/{id}/capabilities`): for each policy action, the
/// effect + whether it is allowed + why. This is the SINGLE thing collaboration UI
/// gates affordances on (analogous to the entitlement snapshot for premium). It is a
/// UX HINT — the policy engine re-checks and is authoritative (a denied action still
/// fails server-side).
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

/// One action's policy decision (the value a [CapabilityGate] reads).
class PolicyCapability {
  const PolicyCapability({
    required this.action,
    required this.effect,
    required this.allowed,
    required this.reason,
    required this.obligations,
    this.matchedRule,
  });

  final String action;
  final String effect;
  final bool allowed;
  final String reason;
  final List<String> obligations;
  final String? matchedRule;

  bool get requiresReview => effect == PolicyEffect.requiresReview;
  bool get isReadOnly => effect == PolicyEffect.readOnly;
  bool get isConditional => effect == PolicyEffect.conditionalAccess;

  /// The action key comes from the map key, not the payload.
  factory PolicyCapability.fromJson(String action, Json json) =>
      PolicyCapability(
        action: action,
        effect: json['effect'] as String? ?? PolicyEffect.deny,
        allowed: json['allowed'] as bool? ?? false,
        reason: json['reason'] as String? ?? '',
        obligations: (json['obligations'] as List<dynamic>? ?? <dynamic>[])
            .whereType<String>()
            .toList(growable: false),
        matchedRule: json['matchedRule'] as String?,
      );

  /// A default-deny decision for an action the map does not carry.
  factory PolicyCapability.deny(String action) => PolicyCapability(
    action: action,
    effect: PolicyEffect.deny,
    allowed: false,
    reason: 'no_policy',
    obligations: const <String>[],
  );
}

/// The full capability map for the current viewer on one story.
class StoryCapabilities {
  const StoryCapabilities({required this.capabilities});

  /// action → decision.
  final Map<String, PolicyCapability> capabilities;

  /// The decision for an action (default-deny when absent).
  PolicyCapability capabilityFor(String action) =>
      capabilities[action] ?? PolicyCapability.deny(action);

  /// Whether the viewer may perform [action] (the gate widgets read this).
  bool allows(String action) => capabilityFor(action).allowed;

  factory StoryCapabilities.fromJson(Json json) {
    final Map<String, PolicyCapability> caps = <String, PolicyCapability>{};
    json.forEach((String action, dynamic value) {
      if (value is Map) {
        caps[action] = PolicyCapability.fromJson(
          action,
          Map<String, dynamic>.from(value),
        );
      }
    });
    return StoryCapabilities(capabilities: caps);
  }

  /// A fail-closed default: view allowed, every mutation denied.
  static const StoryCapabilities readOnly = StoryCapabilities(
    capabilities: <String, PolicyCapability>{},
  );
}

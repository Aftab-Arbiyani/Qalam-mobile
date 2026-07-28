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
  });

  final String action;
  final String effect;
  final bool allowed;
  final String reason;
  final List<String> obligations;
  // No `matchedRule`: `PolicyDecision` carries one, but `toCapabilityDtos`
  // (collaboration.mappers.ts) drops it, so the wire never sends it.

  bool get requiresReview => effect == PolicyEffect.requiresReview;
  bool get isReadOnly => effect == PolicyEffect.readOnly;
  bool get isConditional => effect == PolicyEffect.conditionalAccess;

  /// One `CapabilityDto` element: `{action, effect, allowed, reason, obligations}`.
  /// The action is carried **in** the payload — `toCapabilityDtos` flattens the
  /// engine's `explain` map into a list, so there is no map key to read it from.
  factory PolicyCapability.fromJson(Json json) => PolicyCapability(
    action: json['action'] as String? ?? '',
    effect: json['effect'] as String? ?? PolicyEffect.deny,
    allowed: json['allowed'] as bool? ?? false,
    reason: json['reason'] as String? ?? '',
    obligations: (json['obligations'] as List<dynamic>? ?? <dynamic>[])
        .whereType<String>()
        .toList(growable: false),
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
  const StoryCapabilities({required this.capabilities, this.storyId = ''});

  /// action → decision.
  final Map<String, PolicyCapability> capabilities;

  /// The story the decisions were evaluated against (`CapabilitiesDto.storyId`).
  final String storyId;

  /// The decision for an action (default-deny when absent).
  PolicyCapability capabilityFor(String action) =>
      capabilities[action] ?? PolicyCapability.deny(action);

  /// Whether the viewer may perform [action] (the gate widgets read this).
  bool allows(String action) => capabilityFor(action).allowed;

  /// Decodes `CapabilitiesDto` — `{storyId, capabilities: CapabilityDto[]}`.
  ///
  /// The payload is an object wrapping an **array**, not an `{action: decision}`
  /// map. This factory used to iterate the top-level object as if it were that
  /// map, so `storyId` (a String) and `capabilities` (a List) were both skipped
  /// and every viewer got an EMPTY map — `allows()` false for everything, so
  /// every `CapabilityGate` in the feature rendered its locked fallback on every
  /// story, the owner included (defect **C-1**, `docs/56` §2.1).
  factory StoryCapabilities.fromJson(Json json) {
    final Map<String, PolicyCapability> caps = <String, PolicyCapability>{};
    for (final Object? raw
        in json['capabilities'] as List<dynamic>? ?? const <dynamic>[]) {
      if (raw is! Map) continue;
      final PolicyCapability capability = PolicyCapability.fromJson(
        Map<String, dynamic>.from(raw),
      );
      // An element with no action cannot be keyed; dropping it keeps the map
      // default-deny for that action rather than inventing an '' entry.
      if (capability.action.isEmpty) continue;
      caps[capability.action] = capability;
    }
    return StoryCapabilities(
      capabilities: caps,
      storyId: json['storyId'] as String? ?? '',
    );
  }

  /// A fail-closed default: every action denied (`capabilityFor` → `deny`).
  /// Used when the capability read itself fails — the engine re-checks anyway.
  static const StoryCapabilities readOnly = StoryCapabilities(
    capabilities: <String, PolicyCapability>{},
  );
}

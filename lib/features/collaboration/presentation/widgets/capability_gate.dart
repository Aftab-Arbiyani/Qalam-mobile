/// Capability-gating widget (AF6) — the ONE way collaboration UI gates an affordance
/// on a policy action. Analogous to monetization's `PremiumGate`: every action button
/// that a story policy governs wraps its trigger in a [CapabilityGate] (or reads the
/// capability map) rather than branching on role inline. Gating is a UX HINT — the
/// policy engine re-checks and is authoritative (a denied action still fails).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/policy_capability.dart';
import '../providers/collaboration_providers.dart';

/// Renders [child] when the viewer may perform [action] on [storyId]; otherwise
/// renders [locked] (defaulting to nothing). While the capability map loads it shows
/// [child] iff [optimistic] (the server still gates the action), else nothing.
class CapabilityGate extends ConsumerWidget {
  const CapabilityGate({
    required this.storyId,
    required this.action,
    required this.child,
    this.locked,
    this.optimistic = false,
    super.key,
  });

  final String storyId;
  final String action;
  final Widget child;
  final Widget? locked;
  final bool optimistic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<StoryCapabilities> async = ref.watch(
      storyCapabilitiesProvider(storyId),
    );
    final Widget fallback = locked ?? const SizedBox.shrink();
    return async.when(
      loading: () => optimistic ? child : fallback,
      error: (Object _, StackTrace _) => fallback,
      data: (StoryCapabilities caps) => caps.allows(action) ? child : fallback,
    );
  }
}

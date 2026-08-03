/// Premium-gating widgets (AF5) — how the app marks and, where the server really
/// enforces it, withholds a premium capability.
///
/// **Where these belong, narrowly.** [PremiumGate] withholds content; [PremiumBadge]
/// only annotates it. The division is not stylistic — it follows what the backend
/// asserts. `ai_budget` is the ONLY premium feature any server route checks
/// (`AiUsageMeterService.checkQuota`, and only while `feature.payments.enabled` is up).
/// The other seven catalogued features — `ai_writing`, `publishing_pro`,
/// `advanced_analytics` and the rest — are computed by the Entitlement Service and
/// asserted by nothing (docs/48 §5.2). Gating one of those would put a client-only wall
/// in front of a route the server serves to anyone: dead UI, the W3c-1 defect class with
/// the sign flipped. So **gate `ai_budget`; badge everything else and keep it working.**
///
/// This file used to claim that "every premium affordance elsewhere wraps its content in
/// PremiumGate". It had zero call sites when it said that (docs/48 §3.7, M5-1). The
/// call sites are now real and are listed here so the claim stays checkable:
///
/// - `credit_dashboard_screen` — the balance, gated on `ai_budget`. Credits are only
///   spendable through an AI request, so an account denied that budget cannot spend one.
/// - `subscription_screen` — [PremiumBadge] beside the viewer's tier. A marker, no gate.
///
/// Gating is a UX HINT — the server re-checks and is authoritative (a denied action
/// still 402s).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../domain/entities/entitlement.dart';
import '../../domain/entities/monetization_enums.dart';
// Re-exports `domain_labels.dart`, which is where the label helpers live.
import '../monetization_format.dart';
import '../providers/monetization_providers.dart';

/// Renders [child] when the server says the viewer is entitled to [feature]; otherwise
/// renders [locked] (defaulting to the explanatory [FeatureLockCard]).
///
/// **Fails closed.** Loading (unless [optimistic]), an error, and a snapshot that does
/// not mention the feature all render the locked slot. Being briefly too strict costs a
/// control that appears a moment late; being too permissive shows a control that then
/// 402s, which reads as a broken app.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    required this.feature,
    required this.child,
    this.locked,
    this.optimistic = false,
    super.key,
  });

  final String feature;
  final Widget child;
  final Widget? locked;

  /// Render [child] while the snapshot is in flight rather than holding it back. For
  /// content that is merely *annotated* by entitlement — the server refuses the action
  /// either way — this avoids a flash of lock on every screen open.
  final bool optimistic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EntitlementSnapshot> async = ref.watch(
      entitlementSnapshotProvider,
    );
    return async.when(
      loading: () => optimistic ? child : const SizedBox.shrink(),
      error: (_, _) => locked ?? FeatureLockCard(decision: _denied(feature)),
      data: (EntitlementSnapshot snapshot) {
        final EntitlementDecision decision = snapshot.decisionFor(feature);
        if (decision.allowed) return child;
        return locked ?? FeatureLockCard(decision: decision);
      },
    );
  }

  /// The stand-in decision when the snapshot itself could not be read. `plan_excludes`
  /// is the same reason `decisionFor` synthesises for an absent feature, so an
  /// unreachable server and an unlisted feature explain themselves identically.
  static EntitlementDecision _denied(String feature) => EntitlementDecision(
    feature: feature,
    status: EntitlementStatus.deny,
    allowed: false,
    reason: EntitlementReason.planExcludes,
  );
}

/// The explanatory lock (the default `locked` slot), exported so a surface can place it
/// itself.
///
/// Says what happened **in the server's own terms** and offers the action that actually
/// helps: a quota denial gets the reset date and no upgrade button, every other denial
/// gets the plan comparison (docs/48 §5.2).
class FeatureLockCard extends StatelessWidget {
  const FeatureLockCard({required this.decision, super.key});

  final EntitlementDecision decision;

  @override
  Widget build(BuildContext context) {
    final bool quota = decision.isQuotaDenial;
    final String name = featureLabel(decision.feature);
    final String title = quota
        ? 'You’ve used your ${name.toLowerCase()}'
        : '$name needs a paid plan';
    final String message = quota
        ? decision.expiresAt == null
              ? 'Your allowance resets at the start of the next period.'
              : 'Your allowance resets on ${formatDate(decision.expiresAt!)}.'
        : '${entitlementReasonLabel(decision.reason)}. A paid plan unlocks it.';

    return Semantics(
      label: title,
      child: Padding(
        padding: QSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(quota ? Icons.speed_outlined : Icons.lock_outline, size: 40),
            Gap.v2,
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Gap.v1,
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            // No upgrade button on a quota denial: the allowance returns on its own and
            // a plan is not the remedy.
            if (!quota) ...<Widget>[
              Gap.v3,
              QButton(
                label: 'See plans',
                variant: QButtonVariant.primary,
                icon: Icons.workspace_premium_outlined,
                onPressed: () => context.push(Routes.billingPlans),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The marker on a premium affordance — a label beside a control, never a wrapper
/// around one. The control it sits next to stays live.
///
/// Names the tier rather than saying a generic "PRO", so the reader learns which plan
/// the affordance belongs to instead of guessing.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({this.tier, this.label, super.key});

  final String? tier;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String text = label ?? (tier == null ? 'Premium' : planLabel(tier!));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

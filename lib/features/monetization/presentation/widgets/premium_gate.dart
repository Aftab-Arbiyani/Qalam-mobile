/// Premium-gating widgets (AF5) — the ONE way the app gates a premium capability in
/// the UI. Every premium affordance elsewhere wraps its content in [PremiumGate] (or
/// checks the entitlement snapshot); there is no scattered inline plan check. Gating is
/// a UX HINT — the server re-checks and is authoritative (a denied action still 402s).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../domain/entities/entitlement.dart';
import '../domain_labels.dart';
import '../providers/monetization_providers.dart';

/// Renders [child] when the user is entitled to [feature]; otherwise renders [locked]
/// (defaulting to a compact upgrade prompt). While the snapshot loads it shows [child]
/// optimistically iff [optimistic] (the server still gates the action), else a spinner.
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
  final bool optimistic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EntitlementSnapshot> async = ref.watch(entitlementSnapshotProvider);
    return async.when(
      loading: () => optimistic
          ? child
          : const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox.shrink())),
      error: (_, _) => locked ?? FeatureLockCard(feature: feature),
      data: (EntitlementSnapshot snapshot) =>
          snapshot.allows(feature) ? child : (locked ?? FeatureLockCard(feature: feature)),
    );
  }
}

/// A compact inline lock affordance (used as the default `locked` slot).
class FeatureLockCard extends StatelessWidget {
  const FeatureLockCard({required this.feature, super.key});

  final String feature;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${featureLabel(feature)} requires an upgrade',
      child: Padding(
        padding: QSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.lock_outline, size: 40),
            Gap.v2,
            Text(
              '${featureLabel(feature)} is a premium feature',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Gap.v1,
            Text(
              'Upgrade your plan to unlock it.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Gap.v3,
            QButton(
              label: 'See plans',
              variant: QButtonVariant.primary,
              icon: Icons.workspace_premium_outlined,
              onPressed: () => context.push(Routes.billingPlans),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small "PRO" style badge for premium affordances in menus/toolbars.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({this.label = 'PRO', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Subscription management (AF5) — the monetization home. Shows the current plan +
/// status (with dedicated trial / grace-period / expired experiences), and drives
/// cancel / reactivate / pause / resume and navigation to plans, usage, credits, and
/// billing history. Free users see an upsell into the plan comparison.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/monetization_enums.dart';
import '../../domain/entities/subscription.dart';
import '../controllers/subscription_controller.dart';
import '../monetization_format.dart';
import '../providers/monetization_providers.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Subscription?> async = ref.watch(currentSubscriptionProvider);
    return Scaffold(
      appBar: const QAppBar(title: 'Subscription'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error'),
          onRetry: () => ref.invalidate(currentSubscriptionProvider),
        ),
        data: (Subscription? sub) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(currentSubscriptionProvider),
          child: ListView(
            padding: QSpacing.pagePadding,
            children: sub == null
                ? _freeBody(context)
                : _subscribedBody(context, ref, sub),
          ),
        ),
      ),
    );
  }

  List<Widget> _freeBody(BuildContext context) => <Widget>[
    QCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('You are on the Free plan',
              style: Theme.of(context).textTheme.titleLarge),
          Gap.v1,
          const Text('Upgrade to unlock AI writing, discovery, and more.'),
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
    Gap.v3,
    ..._navTiles(context),
  ];

  List<Widget> _subscribedBody(BuildContext context, WidgetRef ref, Subscription sub) {
    final Widget? banner = _statusBanner(context, sub);
    return <Widget>[
      if (banner != null) ...<Widget>[banner, Gap.v3],
      _PlanSummaryCard(sub: sub),
      Gap.v3,
      _ActionsCard(sub: sub),
      Gap.v3,
      ..._navTiles(context),
    ];
  }

  /// The trial / grace-period / expired / paused experiences (dedicated banners).
  Widget? _statusBanner(BuildContext context, Subscription sub) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    if (sub.isTrialing && sub.trialEnd != null) {
      return _Banner(
        color: cs.tertiaryContainer,
        icon: Icons.hourglass_bottom,
        text: 'Free trial ends ${formatDate(sub.trialEnd!)}.',
      );
    }
    if (sub.isInGrace) {
      return _Banner(
        color: cs.errorContainer,
        icon: Icons.warning_amber,
        text: sub.gracePeriodEnd != null
            ? 'Payment failed. Update your payment method before ${formatDate(sub.gracePeriodEnd!)} to keep access.'
            : 'Payment failed — you are in a grace period.',
      );
    }
    if (sub.isPaused) {
      return _Banner(
        color: cs.secondaryContainer,
        icon: Icons.pause_circle_outline,
        text: 'Your subscription is paused.',
      );
    }
    if (sub.isExpired || sub.isCanceled) {
      return _Banner(
        color: cs.errorContainer,
        icon: Icons.lock_clock,
        text: 'Your subscription has ended. Resubscribe to restore premium access.',
      );
    }
    if (sub.cancelAtPeriodEnd && sub.currentPeriodEnd != null) {
      return _Banner(
        color: cs.secondaryContainer,
        icon: Icons.event_busy,
        text: 'Cancels on ${formatDate(sub.currentPeriodEnd!)}. You keep access until then.',
      );
    }
    return null;
  }

  List<Widget> _navTiles(BuildContext context) => <Widget>[
    _NavTile(
      icon: Icons.insights_outlined,
      label: 'AI usage',
      onTap: () => context.push(Routes.billingUsage),
    ),
    _NavTile(
      icon: Icons.toll_outlined,
      label: 'Credits',
      onTap: () => context.push(Routes.billingCredits),
    ),
    _NavTile(
      icon: Icons.receipt_long_outlined,
      label: 'Billing history',
      onTap: () => context.push(Routes.billingHistory),
    ),
    _NavTile(
      icon: Icons.workspace_premium_outlined,
      label: 'Compare plans',
      onTap: () => context.push(Routes.billingPlans),
    ),
  ];
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.sub});
  final Subscription sub;

  @override
  Widget build(BuildContext context) {
    return QCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('${planLabel(sub.tier)} plan',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Chip(
                label: Text(subscriptionStatusLabel(sub.status)),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (sub.interval != BillingInterval.none) ...<Widget>[
            Gap.v1,
            Text('Billed ${intervalLabel(sub.interval).toLowerCase()}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
          if (sub.currentPeriodEnd != null) ...<Widget>[
            Gap.v1,
            Text('Renews ${formatDate(sub.currentPeriodEnd!)}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
          if (sub.hasScheduledChange) ...<Widget>[
            Gap.v1,
            Text('Scheduled change to ${planLabel(sub.scheduledTier!)} at period end.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _ActionsCard extends ConsumerWidget {
  const _ActionsCard({required this.sub});
  final Subscription sub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> action = ref.watch(subscriptionControllerProvider);
    final SubscriptionController controller =
        ref.read(subscriptionControllerProvider.notifier);
    final bool busy = action.isLoading;

    Future<void> run(Future<bool> Function() op, String okMsg) async {
      final bool ok = await op();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? okMsg : _errorMessage(ref))),
      );
    }

    final List<Widget> actions = <Widget>[
      QButton(
        label: 'Change plan',
        block: true,
        onPressed: busy ? null : () => context.push(Routes.billingPlans),
      ),
    ];

    if (sub.isPaused) {
      actions.add(QButton(
        label: 'Resume',
        block: true,
        loading: busy,
        variant: QButtonVariant.primary,
        onPressed: busy ? null : () => run(controller.resume, 'Subscription resumed.'),
      ));
    } else if (sub.cancelAtPeriodEnd || sub.isCanceled) {
      actions.add(QButton(
        label: 'Reactivate',
        block: true,
        loading: busy,
        variant: QButtonVariant.primary,
        onPressed: busy ? null : () => run(controller.reactivate, 'Subscription reactivated.'),
      ));
    } else if (sub.isActive) {
      actions
        ..add(QButton(
          label: 'Pause',
          block: true,
          onPressed: busy ? null : () => run(controller.pause, 'Subscription paused.'),
        ))
        ..add(QButton(
          label: 'Cancel subscription',
          block: true,
          variant: QButtonVariant.danger,
          onPressed: busy ? null : () => _confirmCancel(context, ref),
        ));
    }
    actions.add(QButton(
      label: 'Restore purchases',
      block: true,
      variant: QButtonVariant.ghost,
      onPressed: busy
          ? null
          : () async {
              final result = await controller.restore(provider: sub.provider);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result == null
                    ? _errorMessage(ref)
                    : 'Restored ${result.restored} purchase(s).'),
              ));
            },
    ));

    return QCard(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < actions.length; i++) ...<Widget>[
            if (i > 0) Gap.v2,
            actions[i],
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Cancel subscription?'),
        content: const Text(
          'You will keep premium access until the end of the current billing period.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel plan')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final bool ok = await ref.read(subscriptionControllerProvider.notifier).cancel();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Subscription will cancel at period end.' : _errorMessage(ref))),
    );
  }

  String _errorMessage(WidgetRef ref) {
    final Object? err = ref.read(subscriptionControllerProvider).error;
    return err is Failure ? err.message : 'Something went wrong.';
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.icon, required this.text});
  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

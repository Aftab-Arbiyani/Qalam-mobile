/// Plan comparison + upgrade/downgrade flow (AF5, docs/40 §41). Lists the plan
/// catalogue with a monthly/yearly toggle, marks the current plan, and drives a
/// checkout (new subscription) or a plan change (existing subscription). Store
/// purchases go through the billing gateway; a Stripe checkout returns a URL surfaced
/// for the browser (a launcher is a documented seam — no new dependency added).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/billing/store_billing_gateway.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/billing.dart';
import '../../domain/entities/entitlement.dart';
import '../../domain/entities/monetization_enums.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/subscription.dart';
import '../controllers/subscription_controller.dart';
import '../monetization_format.dart';
import '../providers/monetization_providers.dart';
import '../widgets/coupon_field.dart';
import '../widgets/monetization_off_screen.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  bool _yearly = false;

  /// The promo code the server has already accepted a preview for, or null. Handed to
  /// checkout; cleared whenever the field's contents change.
  String? _coupon;

  String get _interval =>
      _yearly ? BillingInterval.yearly : BillingInterval.monthly;

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(appConfigProvider).enableMonetization) {
      return const MonetizationOffScreen(
        appBarTitle: 'Plans',
        icon: Icons.credit_card_outlined,
        title: 'Plans aren’t available yet',
        message: 'Subscriptions and AI credits arrive with the next release.',
      );
    }

    final AsyncValue<PlanCatalogue> plansAsync = ref.watch(plansProvider);
    final AsyncValue<Subscription?> subAsync = ref.watch(
      currentSubscriptionProvider,
    );
    final AsyncValue<void> action = ref.watch(subscriptionControllerProvider);
    final String currentTier = subAsync.asData?.value?.tier ?? PlanTier.free;

    return Scaffold(
      appBar: const QAppBar(title: 'Plans'),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(
                  code: ErrorCodes.apiUnexpected,
                  message: '$error',
                ),
          onRetry: () => ref.invalidate(plansProvider),
        ),
        data: (PlanCatalogue catalogue) => ListView(
          padding: QSpacing.pagePadding,
          children: <Widget>[
            _IntervalToggle(
              yearly: _yearly,
              onChanged: (bool v) => setState(() => _yearly = v),
            ),
            Gap.v3,
            for (final Plan plan in catalogue.plans)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlanCard(
                  plan: plan,
                  interval: _interval,
                  currency: catalogue.currency,
                  isCurrent: plan.tier == currentTier,
                  busy: action.isLoading,
                  onSelect: () => _select(
                    plan,
                    currentTier,
                    hasSub: subAsync.asData?.value != null,
                  ),
                ),
              ),
            // A promo code applies to a NEW subscription only, and the field is hidden
            // from existing subscribers rather than ignored for them: `ChangePlanDto`
            // has no `couponCode` property and the API runs
            // `ValidationPipe({whitelist: true, forbidNonWhitelisted: true})`, so
            // sending one would 400 the whole plan change — the same trap the M-1
            // invite defect fell into.
            //
            // No `tier` is passed: the reader has not chosen a plan when they enter the
            // code, so the server confirms the code without a figure rather than
            // pricing it against a guess.
            if (subAsync.asData?.value == null) ...<Widget>[
              Gap.v2,
              QCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Have a promo code?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Gap.v2,
                    CouponField(
                      interval: _interval,
                      currency: catalogue.currency,
                      onApplied: (String? code) =>
                          setState(() => _coupon = code),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _select(
    Plan plan,
    String currentTier, {
    required bool hasSub,
  }) async {
    if (plan.isFree || plan.tier == currentTier) {
      return;
    }
    final SubscriptionController controller = ref.read(
      subscriptionControllerProvider.notifier,
    );
    try {
      if (!hasSub) {
        final CheckoutResult? result = await controller.subscribe(
          tier: plan.tier,
          interval: _interval,
          provider: PaymentProvider.stripe,
          // The previewed code, if the server accepted one. Redemption happens here,
          // server-side — the preview only kept the reader from typing a dead code.
          couponCode: _coupon,
        );
        if (!mounted) return;
        if (result == null) {
          _showError();
        } else if (result.needsRedirect) {
          _showCheckoutSheet(result.checkoutUrl!);
        } else if (result.needsClientConfirmation) {
          // No on-device confirmation step is implemented for this provider path
          // (docs/48 §3.22a, AF5-cs) — say so rather than claim a subscription that
          // is not actually active yet.
          _snack(
            'This payment method is not supported yet. Please try another.',
          );
        } else {
          _snack('You are now on ${planLabel(plan.tier)}.');
        }
      } else {
        final bool ok = await controller.changePlan(
          tier: plan.tier,
          interval: _interval,
          atPeriodEnd: isPlanDowngrade(currentTier, plan.tier),
        );
        if (!mounted) return;
        ok ? _snack('Plan updated.') : _showError();
      }
    } on StoreBillingUnavailable catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  void _showError() {
    final AsyncValue<void> state = ref.read(subscriptionControllerProvider);
    final Object? err = state.error;
    _snack(
      err is Failure ? err.message : 'Something went wrong. Please try again.',
    );
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  void _showCheckoutSheet(String url) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => Padding(
        padding: QSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Complete your purchase',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            Gap.v2,
            const Text(
              'Open this secure checkout link in your browser to finish:',
            ),
            Gap.v2,
            SelectableText(url, style: Theme.of(ctx).textTheme.bodySmall),
            Gap.v3,
            QButton(
              label: 'Done',
              block: true,
              variant: QButtonVariant.primary,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntervalToggle extends StatelessWidget {
  const _IntervalToggle({required this.yearly, required this.onChanged});

  final bool yearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const <ButtonSegment<bool>>[
        ButtonSegment<bool>(value: false, label: Text('Monthly')),
        ButtonSegment<bool>(value: true, label: Text('Yearly')),
      ],
      selected: <bool>{yearly},
      onSelectionChanged: (Set<bool> s) => onChanged(s.first),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({
    required this.plan,
    required this.interval,
    required this.currency,
    required this.isCurrent,
    required this.busy,
    required this.onSelect,
  });

  final Plan plan;
  final String interval;
  final String currency;
  final bool isCurrent;
  final bool busy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int price = plan.priceMinor(interval, currency);
    final EntitlementSnapshot? snapshot = ref
        .watch(entitlementSnapshotProvider)
        .asData
        ?.value;
    final String currentTier = snapshot?.tier ?? PlanTier.free;
    return QCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(plan.name, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (isCurrent)
                const Chip(
                  label: Text('Current'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          Gap.v1,
          Text(
            plan.isFree
                ? 'Free'
                : '${formatMoney(price, currency)} / ${_short(interval)}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Gap.v2,
          for (final String f in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.check, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(featureLabel(f))),
                ],
              ),
            ),
          if (plan.monthlyCredits > 0) ...<Widget>[
            Gap.v1,
            Text(
              '${formatCount(plan.monthlyCredits)} AI credits / month',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (!plan.isFree && !isCurrent) ...<Widget>[
            Gap.v3,
            QButton(
              label: _cta(currentTier),
              block: true,
              loading: busy,
              variant: QButtonVariant.primary,
              onPressed: busy ? null : onSelect,
            ),
          ],
        ],
      ),
    );
  }

  String _cta(String currentTier) =>
      isPlanUpgrade(currentTier, plan.tier) ? 'Upgrade' : 'Switch';

  String _short(String interval) =>
      interval == BillingInterval.yearly ? 'yr' : 'mo';
}

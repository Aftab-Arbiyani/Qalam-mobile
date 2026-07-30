/// Credit dashboard (AF5) — the AI credit wallet balance + recent ledger, with a
/// buy-credits affordance (store IAP via the billing gateway). Read-only display of the
/// server-owned balance; a top-up is server-validated.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/billing/store_billing_gateway.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/credit.dart';
import '../../domain/entities/monetization_enums.dart';
import '../controllers/subscription_controller.dart';
import '../monetization_format.dart';
import '../providers/monetization_providers.dart';

/// Credit-pack options (store product ids follow the `com.qalam.credits.<n>` convention).
const List<({int credits, String productId})> _packs = <({int credits, String productId})>[
  (credits: 1000, productId: 'com.qalam.credits.1000'),
  (credits: 5000, productId: 'com.qalam.credits.5000'),
  (credits: 20000, productId: 'com.qalam.credits.20000'),
];

class CreditDashboardScreen extends ConsumerWidget {
  const CreditDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CreditBalance> balanceAsync = ref.watch(creditBalanceProvider);
    final AsyncValue<List<CreditTransaction>> ledgerAsync = ref.watch(creditLedgerProvider);

    return Scaffold(
      appBar: const QAppBar(title: 'AI credits'),
      body: balanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error'),
          onRetry: () => ref.invalidate(creditBalanceProvider),
        ),
        data: (CreditBalance balance) => ListView(
          padding: QSpacing.pagePadding,
          children: <Widget>[
            QCard(
              child: Column(
                children: <Widget>[
                  Text(formatCount(balance.balance),
                      style: Theme.of(context).textTheme.displaySmall),
                  Text('credits available', style: Theme.of(context).textTheme.bodyMedium),
                  Gap.v2,
                  Text(
                    '${formatCount(balance.lifetimeGranted)} granted · '
                    '${formatCount(balance.lifetimeConsumed)} used',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Gap.v4,
            Text('Buy credits', style: Theme.of(context).textTheme.titleMedium),
            Gap.v2,
            for (final ({int credits, String productId}) pack in _packs)
              _CreditPackTile(
                credits: pack.credits,
                onBuy: () => _buy(context, ref, pack.credits, pack.productId),
              ),
            Gap.v4,
            Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
            Gap.v2,
            ledgerAsync.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )),
              error: (_, _) => const Text('Could not load recent activity.'),
              data: (List<CreditTransaction> txns) => txns.isEmpty
                  ? const Text('No activity yet.')
                  : Column(
                      children: <Widget>[
                        for (final CreditTransaction t in txns) _LedgerRow(txn: t),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buy(BuildContext context, WidgetRef ref, int credits, String productId) async {
    final SubscriptionController controller = ref.read(subscriptionControllerProvider.notifier);
    try {
      final result = await controller.purchaseCredits(
        credits: credits,
        provider: PaymentProvider.appleAppStore,
        productId: productId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result == null
            ? _errorMessage(ref)
            : 'Added ${formatCount(credits)} credits.'),
      ));
    } on StoreBillingUnavailable catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  String _errorMessage(WidgetRef ref) {
    final Object? err = ref.read(subscriptionControllerProvider).error;
    return err is Failure ? err.message : 'Purchase failed.';
  }
}

class _CreditPackTile extends ConsumerWidget {
  const _CreditPackTile({required this.credits, required this.onBuy});
  final int credits;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool busy = ref.watch(subscriptionControllerProvider).isLoading;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: QCard(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('${formatCount(credits)} credits',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            QButton(
              label: 'Buy',
              loading: busy,
              onPressed: busy ? null : onBuy,
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.txn});
  final CreditTransaction txn;

  @override
  Widget build(BuildContext context) {
    final Color color = txn.isGrant ? Colors.green : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(txn.reason.replaceAll('_', ' ')),
      subtitle: Text(formatDate(txn.createdAt)),
      trailing: Text(
        '${txn.isGrant ? '+' : ''}${txn.delta}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}

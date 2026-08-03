/// Billing history (AF5) — the four owner-scoped ledgers, in four tabs: invoices,
/// payments, purchases and subscription events.
///
/// **Two of the four had no surface.** `MonetizationRepository.purchases()` and
/// `.history()` were implemented through to the data source and called by nothing, so a
/// mobile reader could not see a credit-pack purchase or a single plan change — the same
/// defect class as M5-2 and M-4, and the "two history tabs mobile lacks" that §2 of the
/// parity register had been carrying as prose (docs/48 §3.7, M5-6).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/billing.dart';
import '../../domain/entities/subscription.dart';
import '../monetization_format.dart';
import '../providers/monetization_providers.dart';
import '../widgets/monetization_off_screen.dart';

class BillingHistoryScreen extends ConsumerWidget {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appConfigProvider).enableMonetization) {
      return const MonetizationOffScreen(
        appBarTitle: 'Billing history',
        icon: Icons.receipt_long_outlined,
        title: 'Billing history isn’t available yet',
        message: 'Receipts appear once subscriptions are switched on.',
      );
    }

    return const DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: QAppBar(
          title: 'Billing history',
          bottom: TabBar(
            // Four labels do not fit a phone width evenly; scrolling keeps every tab
            // readable rather than truncating two of them to fit.
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: 'Invoices'),
              Tab(text: 'Payments'),
              Tab(text: 'Purchases'),
              Tab(text: 'Plan changes'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _InvoicesTab(),
            _PaymentsTab(),
            _PurchasesTab(),
            _EventsTab(),
          ],
        ),
      ),
    );
  }
}

/// The shared frame for a ledger tab — loading, error, empty, rows.
///
/// Four tabs with identical states and different row shapes: the states belong in one
/// place so an empty purchases list and an empty invoice list cannot drift into saying
/// different things, or into one of them quietly losing its retry.
class _Ledger<T> extends StatelessWidget {
  const _Ledger({
    required this.async,
    required this.empty,
    required this.row,
    required this.onRetry,
  });

  final AsyncValue<List<T>> async;
  final String empty;
  final Widget Function(BuildContext, T) row;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace _) => QErrorView(
        failure: e is Failure
            ? e
            : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$e'),
        onRetry: onRetry,
      ),
      data: (List<T> rows) => rows.isEmpty
          ? Center(
              child: Padding(padding: QSpacing.pagePadding, child: Text(empty)),
            )
          : ListView(
              padding: QSpacing.pagePadding,
              children: <Widget>[
                for (final T item in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: row(context, item),
                  ),
              ],
            ),
    );
  }
}

/// One ledger row: a title, a supporting line, and an optional trailing figure.
class _LedgerCard extends StatelessWidget {
  const _LedgerCard({required this.title, required this.detail, this.trailing});

  final String title;
  final String detail;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return QCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: text.titleSmall),
                Text(detail, style: text.bodySmall),
              ],
            ),
          ),
          if (trailing != null) Text(trailing!, style: text.titleMedium),
        ],
      ),
    );
  }
}

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Ledger<Invoice>(
    async: ref.watch(invoiceHistoryProvider),
    empty: 'No invoices yet.',
    onRetry: () => ref.invalidate(invoiceHistoryProvider),
    row: (BuildContext context, Invoice i) => _LedgerCard(
      title: i.number,
      detail: '${invoiceStatusLabel(i.status)} · ${formatDate(i.createdAt)}',
      trailing: formatMoney(i.total, i.currency),
    ),
  );
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Ledger<Payment>(
    async: ref.watch(paymentHistoryProvider),
    empty: 'No payments yet.',
    onRetry: () => ref.invalidate(paymentHistoryProvider),
    row: (BuildContext context, Payment p) => _LedgerCard(
      title: p.description ?? providerLabel(p.provider),
      detail: '${paymentStatusLabel(p.status)} · ${formatDate(p.createdAt)}',
      trailing: formatMoney(p.amount, p.currency),
    ),
  );
}

class _PurchasesTab extends ConsumerWidget {
  const _PurchasesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Ledger<Purchase>(
    async: ref.watch(purchaseHistoryProvider),
    empty: 'No purchases yet.',
    onRetry: () => ref.invalidate(purchaseHistoryProvider),
    row: (BuildContext context, Purchase p) => _LedgerCard(
      title: purchaseKindLabel(p.kind),
      detail:
          '${purchaseStatusLabel(p.status)} · ${providerLabel(p.provider)} · '
          '${formatDate(p.createdAt)}'
          '${p.creditsGranted > 0 ? ' · ${formatCount(p.creditsGranted)} credits' : ''}',
      trailing: formatMoney(p.amount, p.currency),
    ),
  );
}

class _EventsTab extends ConsumerWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Ledger<SubscriptionEvent>(
    async: ref.watch(subscriptionEventsProvider),
    empty: 'No plan changes yet.',
    onRetry: () => ref.invalidate(subscriptionEventsProvider),
    row: (BuildContext context, SubscriptionEvent e) => _LedgerCard(
      title: subscriptionEventLabel(e.type),
      detail: formatDate(e.createdAt),
      trailing: _tierChange(e),
    ),
  );

  /// Where the plan moved from and to. An event with neither tier is a lifecycle event
  /// — a pause, a renewal — and gets no trailing text rather than an empty arrow.
  String? _tierChange(SubscriptionEvent e) {
    if (e.fromTier == null && e.toTier == null) return null;
    if (e.fromTier == null) return planLabel(e.toTier!);
    if (e.toTier == null) return planLabel(e.fromTier!);
    return '${planLabel(e.fromTier!)} → ${planLabel(e.toTier!)}';
  }
}

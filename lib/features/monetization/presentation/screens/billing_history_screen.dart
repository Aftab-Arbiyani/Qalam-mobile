/// Billing history (AF5) — invoices + payments, in two tabs. Read-only owner-scoped
/// history from `GET /monetization/invoices` + `/payments`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/billing.dart';
import '../monetization_format.dart';
import '../providers/monetization_providers.dart';

class BillingHistoryScreen extends ConsumerWidget {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: QAppBar(
          title: 'Billing history',
          bottom: TabBar(tabs: <Widget>[Tab(text: 'Invoices'), Tab(text: 'Payments')]),
        ),
        body: TabBarView(
          children: <Widget>[_InvoicesTab(), _PaymentsTab()],
        ),
      ),
    );
  }
}

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Invoice>> async = ref.watch(invoiceHistoryProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace _) => QErrorView(
        failure: e is Failure ? e : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$e'),
        onRetry: () => ref.invalidate(invoiceHistoryProvider),
      ),
      data: (List<Invoice> invoices) => invoices.isEmpty
          ? const _Empty(message: 'No invoices yet.')
          : ListView(
              padding: QSpacing.pagePadding,
              children: <Widget>[
                for (final Invoice i in invoices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: QCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(i.number,
                                    style: Theme.of(context).textTheme.titleSmall),
                                Text('${i.status} · ${formatDate(i.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Text(formatMoney(i.total, i.currency),
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Payment>> async = ref.watch(paymentHistoryProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace _) => QErrorView(
        failure: e is Failure ? e : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$e'),
        onRetry: () => ref.invalidate(paymentHistoryProvider),
      ),
      data: (List<Payment> payments) => payments.isEmpty
          ? const _Empty(message: 'No payments yet.')
          : ListView(
              padding: QSpacing.pagePadding,
              children: <Widget>[
                for (final Payment p in payments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: QCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(p.description ?? p.provider,
                                    style: Theme.of(context).textTheme.titleSmall),
                                Text('${p.status} · ${formatDate(p.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Text(formatMoney(p.amount, p.currency),
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) =>
      Center(child: Padding(padding: QSpacing.pagePadding, child: Text(message)));
}

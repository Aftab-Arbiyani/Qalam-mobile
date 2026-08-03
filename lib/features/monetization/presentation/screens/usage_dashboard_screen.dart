/// AI usage dashboard (AF5) — daily/monthly/lifetime token+credit usage, estimated
/// cost, remaining quota, a monthly forecast, and a per-feature breakdown, from the
/// monetization Usage service (`GET /monetization/usage`). Read-only; server counts.
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
import '../../domain/entities/usage_summary.dart';
import '../monetization_format.dart';
import '../providers/monetization_providers.dart';
import '../widgets/monetization_off_screen.dart';

class UsageDashboardScreen extends ConsumerWidget {
  const UsageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appConfigProvider).enableMonetization) {
      return const MonetizationOffScreen(
        appBarTitle: 'AI usage',
        icon: Icons.insights_outlined,
        title: 'Usage isn’t available yet',
        message: 'AI allowances arrive with subscriptions.',
      );
    }

    final AsyncValue<MonetizationUsageSummary> async = ref.watch(monetizationUsageProvider);
    return Scaffold(
      appBar: QAppBar(
        title: 'AI usage',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(monetizationUsageProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error'),
          onRetry: () => ref.invalidate(monetizationUsageProvider),
        ),
        data: (MonetizationUsageSummary usage) => ListView(
          padding: QSpacing.pagePadding,
          children: <Widget>[
            _WindowCard(label: 'Today', window: usage.daily),
            Gap.v3,
            _WindowCard(label: 'This month', window: usage.monthly),
            Gap.v3,
            _WindowCard(label: 'Lifetime', window: usage.total),
            Gap.v3,
            QCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Forecast', style: Theme.of(context).textTheme.titleMedium),
                  Gap.v1,
                  Text('~${formatCount(usage.forecastMonthlyTokens)} tokens this month'),
                  Text('~\$${usage.forecastMonthlyCostUsd.toStringAsFixed(2)} projected cost'),
                ],
              ),
            ),
            if (usage.byFeature.isNotEmpty) ...<Widget>[
              Gap.v5,
              Text('By feature', style: Theme.of(context).textTheme.titleMedium),
              Gap.v2,
              for (final MonetizationFeatureUsage f in usage.byFeature)
                _FeatureRow(usage: f),
            ],
          ],
        ),
      ),
    );
  }
}

class _WindowCard extends StatelessWidget {
  const _WindowCard({required this.label, required this.window});
  final String label;
  final MonetizationUsageWindow window;

  @override
  Widget build(BuildContext context) {
    return QCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Gap.v2,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _Stat(value: formatCount(window.tokens), label: 'tokens'),
              _Stat(value: '${window.requests}', label: 'requests'),
              _Stat(value: '\$${window.costUsd.toStringAsFixed(2)}', label: 'cost'),
            ],
          ),
          if (!window.isUnlimited && window.usedFraction != null) ...<Widget>[
            Gap.v2,
            LinearProgressIndicator(value: window.usedFraction!.clamp(0, 1)),
            Gap.v1,
            Text(
              window.remaining != null
                  ? '${formatCount(window.remaining!)} of ${formatCount(window.tokenLimit!)} remaining'
                  : '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else ...<Widget>[
            Gap.v1,
            Text('Unlimited', style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.usage});
  final MonetizationFeatureUsage usage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(featureLabel(usage.feature))),
          Text('${formatCount(usage.tokens)} tok · ${usage.requests} req',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// AI usage dashboard (AF2) — the caller's token usage across daily / monthly /
/// lifetime windows, estimated cost, remaining quota, and a per-feature breakdown,
/// from the reused AF1 `GET /ai/usage/me`. Read-only display; counts are the server's.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/ai_usage.dart';
import '../providers/ai_providers.dart';

class AiUsageScreen extends ConsumerWidget {
  const AiUsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AiUsageSummary> async = ref.watch(aiUsageProvider);
    return Scaffold(
      appBar: QAppBar(
        title: 'AI usage',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(aiUsageProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error'),
          onRetry: () => ref.invalidate(aiUsageProvider),
        ),
        data: (AiUsageSummary usage) => ListView(
          padding: QSpacing.pagePadding,
          children: <Widget>[
            _WindowCard(label: 'Today', window: usage.daily),
            Gap.v3,
            _WindowCard(label: 'This month', window: usage.monthly),
            Gap.v3,
            _WindowCard(label: 'Lifetime', window: usage.total),
            if (usage.byFeature.isNotEmpty) ...<Widget>[
              Gap.v5,
              Text('By feature', style: Theme.of(context).textTheme.titleMedium),
              Gap.v2,
              for (final AiFeatureUsage f in usage.byFeature) _FeatureRow(usage: f),
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
  final AiUsageWindow window;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return QCard(
      padding: QCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
              Text(
                '${_fmt(window.totalTokens)} tokens',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Gap.v1,
          Text(
            '${window.requests} requests  ·  \$${window.estimatedCostUsd.toStringAsFixed(4)}',
            style: TextStyle(color: tokens.colors.textSecondary),
          ),
          if (!window.isUnlimited) ...<Widget>[
            Gap.v2,
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (window.usedFraction ?? 0).clamp(0, 1),
                minHeight: 6,
                backgroundColor: tokens.colors.bgRaised,
                valueColor: AlwaysStoppedAnimation<Color>(
                  (window.usedFraction ?? 0) >= 0.9 ? tokens.colors.danger : tokens.colors.accent,
                ),
              ),
            ),
            Gap.v1,
            Text(
              '${_fmt(window.remaining ?? 0)} of ${_fmt(window.tokenLimit ?? 0)} left',
              style: TextStyle(color: tokens.colors.textMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.usage});
  final AiFeatureUsage usage;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: QSpacing.s1),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(_pretty(usage.feature))),
          Text(
            '${_fmt(usage.totalTokens)} · ${usage.requests}',
            style: TextStyle(color: tokens.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  static String _pretty(String feature) => feature
      .split('_')
      .map((String w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

String _fmt(int value) {
  final String s = value.toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

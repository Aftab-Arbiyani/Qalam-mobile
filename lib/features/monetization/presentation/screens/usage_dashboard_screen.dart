/// **Usage** — one card per writing tool, showing what is left in the window.
///
/// This was the "AI usage" dashboard: token counts, an estimated dollar cost, and a
/// projected monthly spend. **D5 removed all three, and the removal is the feature.**
/// None of it was a fact about writing — a poet cannot decide anything from "42,150
/// tokens", and showing them the provider's cost of serving them makes an editing tool
/// feel like a taxi meter running over their draft. What a writer can act on is how
/// many Polish actions they have left today.
///
/// Read-only; the server owns the counts (`GET /monetization/usage`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/usage_summary.dart';
import '../allowance_labels.dart';
import '../providers/monetization_providers.dart';
import '../widgets/monetization_off_screen.dart';

class UsageDashboardScreen extends ConsumerWidget {
  const UsageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appConfigProvider).enableMonetization) {
      return const MonetizationOffScreen(
        appBarTitle: 'Usage',
        icon: Icons.insights_outlined,
        title: 'Usage isn’t available yet',
        message: 'Tool allowances arrive with subscriptions.',
      );
    }

    final AsyncValue<MonetizationUsageSummary> async = ref.watch(
      monetizationUsageProvider,
    );
    return Scaffold(
      appBar: QAppBar(
        title: 'Usage',
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
              : Failure.unexpected(
                  code: ErrorCodes.apiUnexpected,
                  message: '$error',
                ),
          onRetry: () => ref.invalidate(monetizationUsageProvider),
        ),
        data: (MonetizationUsageSummary usage) => usage.isEmpty
            // Not an error, and not "you have used nothing": the server sends no
            // allowance rows when limits are not being enforced for this account.
            ? const QEmptyState(
                icon: Icons.insights_outlined,
                title: 'Nothing to report yet',
                message: 'Your writing tools aren’t limited right now.',
              )
            : Semantics(
                container: true,
                label: 'Tool allowances',
                child: ListView.separated(
                  padding: QSpacing.pagePadding,
                  itemCount: usage.features.length,
                  separatorBuilder: (_, _) => Gap.v3,
                  itemBuilder: (_, int i) =>
                      _AllowanceCard(allowance: usage.features[i]),
                ),
              ),
      ),
    );
  }
}

class _AllowanceCard extends StatelessWidget {
  const _AllowanceCard({required this.allowance});

  final FeatureAllowance allowance;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final String noun = allowanceNoun(allowance);
    final String line = allowanceLine(allowance);

    return QCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                allowanceIcon(allowance.key),
                size: 18,
                color: tokens.colors.accent,
              ),
              const SizedBox(width: QSpacing.s2),
              Expanded(child: Text(noun, style: text.titleMedium)),
            ],
          ),
          Gap.v2,
          // One line, read as a sentence by a screen reader. The bar below is decorative
          // — announcing a percentage as well would say the same thing twice.
          Text(
            line,
            style: text.bodyMedium?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
          if (!allowance.isUnlimited) ...<Widget>[
            Gap.v2,
            ExcludeSemantics(
              child: LinearProgressIndicator(value: allowance.fraction),
            ),
            if (allowance.isExhausted) ...<Widget>[
              Gap.v1,
              Text(
                allowanceExhaustedLine(allowance),
                style: text.bodySmall?.copyWith(
                  color: tokens.colors.warningText,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

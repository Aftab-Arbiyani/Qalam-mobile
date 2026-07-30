/// Per-piece analytics (docs/40 §30) — the owner-only detail behind a writer's
/// piece (`/analytics/pieces/:id`). Metric cards plus a reading-sources donut.
/// Loading / empty / error states throughout; the donut carries a semantic label.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/charts/chart_primitives.dart';
import '../../../../shared/charts/pie_chart.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/piece_analytics.dart';
import '../analytics_format.dart';
import '../controllers/creator_analytics_controller.dart';
import '../widgets/analytics_skeletons.dart';
import '../widgets/metric_card.dart';

class PieceAnalyticsScreen extends ConsumerWidget {
  const PieceAnalyticsScreen({required this.pieceId, super.key});

  final String pieceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PieceAnalytics> value = ref.watch(
      pieceAnalyticsProvider(pieceId),
    );

    return QScaffold(
      appBar: const QAppBar(title: 'Piece analytics'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pieceAnalyticsProvider(pieceId));
          await ref.read(pieceAnalyticsProvider(pieceId).future);
        },
        child: value.when(
          skipLoadingOnRefresh: false,
          loading: () => const _Loading(),
          error: (Object error, StackTrace _) => ListView(
            children: <Widget>[
              QErrorView(
                failure: error is Failure
                    ? error
                    : const Failure.unexpected(code: 'UNKNOWN'),
                onRetry: () => ref.invalidate(pieceAnalyticsProvider(pieceId)),
              ),
            ],
          ),
          data: (PieceAnalytics a) => _Loaded(analytics: a),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => ListView(
    padding: QSpacing.pagePadding,
    children: const <Widget>[MetricGridSkeleton(count: 8)],
  );
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.analytics});

  final PieceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final ReadingSources src = analytics.readingSources;
    final int srcTotal = src.internal + src.external + src.copyLink;

    return ListView(
      padding: QSpacing.pagePadding,
      children: <Widget>[
        MetricGrid(
          children: <Widget>[
            MetricCard(
              icon: Icons.visibility_outlined,
              label: 'Views',
              value: compactNumber(analytics.views),
              caption: '${compactNumber(analytics.uniqueViews)} unique',
            ),
            MetricCard(
              icon: Icons.menu_book_outlined,
              label: 'Reads',
              value: compactNumber(analytics.reads),
            ),
            MetricCard(
              icon: Icons.check_circle_outline,
              label: 'Completion',
              value: percentLabel(analytics.completionRate),
            ),
            MetricCard(
              icon: Icons.timer_outlined,
              label: 'Avg read',
              value: readDuration(analytics.averageReadTimeSeconds),
            ),
            MetricCard(
              icon: Icons.favorite_outline,
              label: 'Claps',
              value: compactNumber(analytics.claps),
            ),
            MetricCard(
              icon: Icons.bookmark_outline,
              label: 'Bookmarks',
              value: compactNumber(analytics.bookmarks),
            ),
            MetricCard(
              icon: Icons.mode_comment_outlined,
              label: 'Comments',
              value: compactNumber(analytics.comments),
            ),
            MetricCard(
              icon: Icons.share_outlined,
              label: 'Shares',
              value: compactNumber(analytics.shares),
            ),
          ],
        ),
        Gap.v5,
        Text('Reading sources', style: theme.textTheme.titleSmall),
        Gap.v2,
        QCard(
          padding: QCardPadding.md,
          child: srcTotal == 0
              ? Text(
                  'No reads recorded yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                )
              : QPieChart(
                  semanticLabel:
                      'Reading sources: ${src.internal} internal, ${src.external} external, ${src.copyLink} copied link',
                  slices: <ChartSlice>[
                    ChartSlice(
                      label: 'In-app',
                      value: src.internal.toDouble(),
                      color: tokens.colors.accent,
                    ),
                    ChartSlice(
                      label: 'External',
                      value: src.external.toDouble(),
                      color: tokens.colors.info,
                    ),
                    ChartSlice(
                      label: 'Copied link',
                      value: src.copyLink.toDouble(),
                      color: tokens.colors.success,
                    ),
                  ],
                ),
        ),
        Gap.v5,
      ],
    );
  }
}

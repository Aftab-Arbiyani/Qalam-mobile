/// Creator Analytics dashboard (docs/40 §30, docs/32 screen spec). Lifetime
/// headline metric cards (`/analytics/me`), a range-scoped growth line chart and a
/// per-period bar chart (`/analytics/me/growth`), the top-performing piece, and a
/// publishing-activity summary. The range selector scopes ONLY the charts — the
/// headline cards are all-time (the endpoint has no range filter, docs/40 §30).
/// Every surface has loading / empty / error states; charts carry semantic labels.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/charts/bar_chart.dart';
import '../../../../shared/charts/chart_card.dart';
import '../../../../shared/charts/chart_primitives.dart';
import '../../../../shared/charts/line_chart.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../../../shared/widgets/sync/sync_indicator.dart';
import '../../domain/entities/growth_series.dart';
import '../../domain/entities/writer_analytics.dart';
import '../analytics_format.dart';
import '../controllers/creator_analytics_controller.dart';
import '../widgets/analytics_range_selector.dart';
import '../widgets/analytics_skeletons.dart';
import '../widgets/metric_card.dart';

class CreatorAnalyticsScreen extends ConsumerWidget {
  const CreatorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WriterAnalytics> writer = ref.watch(writerAnalyticsProvider);
    final AsyncValue<GrowthSeries> growth = ref.watch(writerGrowthProvider);

    return QScaffold(
      appBar: const QAppBar(
        title: 'Creator Analytics',
        actions: <Widget>[SyncIndicator()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(writerAnalyticsProvider);
          ref.invalidate(writerGrowthProvider);
          await ref.read(writerAnalyticsProvider.future);
        },
        child: ListView(
          padding: QSpacing.pagePadding,
          children: <Widget>[
            const _RangeHeader(),
            Gap.v4,
            _headline(context, ref, writer),
            Gap.v5,
            AnalyticsChartCard<GrowthSeries>(
              title: 'Views over time',
              subtitle: 'Cumulative views for the selected range',
              value: growth,
              onRetry: () => ref.invalidate(writerGrowthProvider),
              isEmpty: (GrowthSeries g) => g.points.length < 2,
              emptyMessage:
                  'No growth snapshots for this range yet. Snapshots appear as your work is read over time.',
              chartBuilder: (GrowthSeries g) => QLineChart(
                semanticLabel:
                    'Cumulative views, ${g.points.length} points, ending at '
                    '${compactNumber(g.cumulative(GrowthMetric.views).isEmpty ? 0 : g.cumulative(GrowthMetric.views).last)}',
                series: <ChartSeries>[
                  ChartSeries(
                    label: 'Views',
                    color: QTokens.of(context).colors.accent,
                    values: g.cumulative(GrowthMetric.views),
                  ),
                ],
              ),
            ),
            Gap.v4,
            AnalyticsChartCard<GrowthSeries>(
              title: 'Reads per period',
              subtitle: 'New reads in each snapshot window',
              value: growth,
              onRetry: () => ref.invalidate(writerGrowthProvider),
              isEmpty: (GrowthSeries g) => g.points.length < 2,
              chartBuilder: (GrowthSeries g) => QBarChart(
                semanticLabel:
                    'Reads per period across ${g.points.length} snapshots',
                bars: _readsBars(g),
              ),
            ),
            Gap.v5,
            _TopPieceSection(writer: writer),
            Gap.v5,
            _PublishingActivity(writer: writer),
            Gap.v5,
          ],
        ),
      ),
    );
  }

  Widget _headline(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<WriterAnalytics> writer,
  ) => writer.when(
    skipLoadingOnRefresh: false,
    loading: () => const MetricGridSkeleton(count: 8),
    error: (Object error, StackTrace _) => QErrorView(
      failure: error is Failure
          ? error
          : const Failure.unexpected(code: 'UNKNOWN'),
      onRetry: () => ref.invalidate(writerAnalyticsProvider),
    ),
    data: (WriterAnalytics w) => _MetricGrid(writer: w),
  );

  static List<ChartBar> _readsBars(GrowthSeries g) {
    final List<double> deltas = g.deltas(GrowthMetric.reads);
    final List<GrowthPoint> pts = g.points;
    // Cap visible bars so labels stay legible; show the most recent window.
    const int maxBars = 14;
    final int start = deltas.length > maxBars ? deltas.length - maxBars : 0;
    return <ChartBar>[
      for (int i = start; i < deltas.length; i++)
        ChartBar(
          label: _dayLabel(i < pts.length ? pts[i].date : null),
          value: deltas[i],
        ),
    ];
  }

  static String _dayLabel(DateTime? d) =>
      d == null ? '' : '${d.day}/${d.month}';
}

class _RangeHeader extends StatelessWidget {
  const _RangeHeader();

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AnalyticsRangeSelector(),
        Gap.v2,
        Text(
          'Headline totals are all-time; the charts follow the range above.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: tokens.colors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.writer});

  final WriterAnalytics writer;

  @override
  Widget build(BuildContext context) => MetricGrid(
    children: <Widget>[
      MetricCard(
        icon: Icons.visibility_outlined,
        label: 'Views',
        value: compactNumber(writer.totalViews),
        caption: '${compactNumber(writer.uniqueViews)} unique',
      ),
      MetricCard(
        icon: Icons.menu_book_outlined,
        label: 'Reads',
        value: compactNumber(writer.reads),
      ),
      MetricCard(
        icon: Icons.timer_outlined,
        label: 'Reading time',
        value: readDuration(writer.totalReadSeconds),
      ),
      MetricCard(
        icon: Icons.check_circle_outline,
        label: 'Completion',
        value: percentLabel(writer.completionRate),
      ),
      MetricCard(
        icon: Icons.group_add_outlined,
        label: 'Followers',
        value: compactNumber(writer.followersGained),
      ),
      MetricCard(
        icon: Icons.bookmark_outline,
        label: 'Bookmarks',
        value: compactNumber(writer.bookmarksReceived),
      ),
      MetricCard(
        icon: Icons.mode_comment_outlined,
        label: 'Comments',
        value: compactNumber(writer.commentsReceived),
      ),
      MetricCard(
        icon: Icons.forum_outlined,
        label: 'Responses',
        value: compactNumber(writer.responsesReceived),
      ),
      MetricCard(
        icon: Icons.favorite_outline,
        label: 'Claps',
        value: compactNumber(writer.clapsReceived),
      ),
    ],
  );
}

class _TopPieceSection extends StatelessWidget {
  const _TopPieceSection({required this.writer});

  final AsyncValue<WriterAnalytics> writer;

  @override
  Widget build(BuildContext context) {
    final MostPopularPiece? top = writer.asData?.value.mostPopularPiece;
    if (top == null) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Top performing piece', style: theme.textTheme.titleSmall),
        Gap.v2,
        QCard(
          padding: QCardPadding.md,
          onTap: () => context.push('/analytics/piece/${top.pieceId}'),
          child: Row(
            children: <Widget>[
              Icon(Icons.emoji_events_outlined, color: tokens.colors.accent),
              Gap.h3,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      top.title.isEmpty ? 'Untitled' : top.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Text(
                      '${compactNumber(top.views)} views',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.colors.textMuted),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublishingActivity extends StatelessWidget {
  const _PublishingActivity({required this.writer});

  final AsyncValue<WriterAnalytics> writer;

  @override
  Widget build(BuildContext context) {
    final WriterAnalytics? w = writer.asData?.value;
    if (w == null) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Publishing activity', style: theme.textTheme.titleSmall),
        Gap.v2,
        QCard(
          padding: QCardPadding.md,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _Stat(
                  label: 'Published',
                  value: '${w.piecesPublished}',
                  color: tokens.colors.success,
                ),
              ),
              Container(width: 1, height: 32, color: tokens.colors.border),
              Expanded(
                child: _Stat(
                  label: 'Archived',
                  value: '${w.piecesArchived}',
                  color: tokens.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    return Column(
      children: <Widget>[
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(color: color),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: tokens.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

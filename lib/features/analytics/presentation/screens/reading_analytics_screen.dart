/// Reading Analytics (docs/40 §30, docs/32 screen spec). LOCAL-FIRST: reading
/// streak / time / completed / favourite genres + languages come from the backend
/// reader aggregate, while Continue Reading, Recently Read and Weekly Activity come
/// from device reading history (no backend endpoint). Renders metric cards, a
/// weekly-activity bar chart, genre + language donuts, and a Continue Reading rail —
/// each with an empty state; charts carry semantic labels.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/reading_history/reading_history_entry.dart';
import '../../../../shared/charts/bar_chart.dart';
import '../../../../shared/charts/chart_primitives.dart';
import '../../../../shared/charts/pie_chart.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/content/history_card.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/sync/sync_indicator.dart';
import '../../domain/entities/ranked_item.dart';
import '../../domain/value_objects/reading_insights.dart';
import '../analytics_format.dart';
import '../controllers/reading_analytics_controller.dart';
import '../widgets/analytics_skeletons.dart';
import '../widgets/metric_card.dart';

class ReadingAnalyticsScreen extends ConsumerWidget {
  const ReadingAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ReadingInsights> value = ref.watch(readingInsightsProvider);

    return QScaffold(
      appBar: const QAppBar(
        title: 'Reading Analytics',
        actions: <Widget>[SyncIndicator()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(readingInsightsProvider);
          await ref.read(readingInsightsProvider.future);
        },
        child: value.when(
          skipLoadingOnRefresh: false,
          loading: () => ListView(
            padding: QSpacing.pagePadding,
            children: const <Widget>[MetricGridSkeleton()],
          ),
          // Reading is local-first: even a backend failure degrades to the local
          // view, so any error here is exceptional — show the local-only insights.
          error: (Object _, StackTrace _) =>
              const _Loaded(insights: ReadingInsights.empty),
          data: (ReadingInsights insights) => _Loaded(insights: insights),
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.insights});

  final ReadingInsights insights;

  @override
  Widget build(BuildContext context) {
    final ReadingInsights i = insights;
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final int languageCount = i.backend.favoriteLanguages.isNotEmpty
        ? i.backend.favoriteLanguages.length
        : i.localLanguages;

    return ListView(
      padding: QSpacing.pagePadding,
      children: <Widget>[
        MetricGrid(
          children: <Widget>[
            MetricCard(
              icon: Icons.local_fire_department_outlined,
              label: 'Reading streak',
              value: '${i.backend.currentStreak}d',
              caption: 'Best ${i.backend.longestStreak}d',
              color: tokens.colors.accent,
            ),
            MetricCard(
              icon: Icons.timer_outlined,
              label: 'Reading time',
              value: readDuration(i.backend.readingTimeSeconds),
            ),
            MetricCard(
              icon: Icons.check_circle_outline,
              label: 'Completed',
              value: compactNumber(i.backend.completedReads),
            ),
            MetricCard(
              icon: Icons.menu_book_outlined,
              label: 'Pieces read',
              value: compactNumber(i.backend.piecesRead),
            ),
            MetricCard(
              icon: Icons.bookmark_outline,
              label: 'Bookmarks',
              value: compactNumber(i.bookmarksCount),
            ),
            MetricCard(
              icon: Icons.translate_outlined,
              label: 'Languages',
              value: '$languageCount',
            ),
          ],
        ),
        Gap.v5,
        _WeeklyActivity(weekly: i.weeklyActivity),
        Gap.v5,
        _RankedDonut(
          title: 'Genres read',
          items: i.backend.favoriteGenres,
          tokens: tokens,
        ),
        Gap.v4,
        _RankedDonut(
          title: 'Languages read',
          items: i.backend.favoriteLanguages,
          tokens: tokens,
        ),
        Gap.v5,
        if (i.continueReading.isNotEmpty) ...<Widget>[
          Text('Continue reading', style: theme.textTheme.titleSmall),
          Gap.v2,
          for (final ReadingHistoryEntry e in i.continueReading.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: QSpacing.s2),
              child: HistoryCard(entry: e),
            ),
          Gap.v4,
        ],
      ],
    );
  }
}

class _WeeklyActivity extends StatelessWidget {
  const _WeeklyActivity({required this.weekly});

  final List<WeekdayActivity> weekly;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final bool hasData = weekly.any((WeekdayActivity w) => w.pieces > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('This week', style: theme.textTheme.titleSmall),
        Gap.v2,
        QCard(
          padding: QCardPadding.md,
          child: SizedBox(
            height: 160,
            child: hasData
                ? QBarChart(
                    semanticLabel:
                        'Pieces read per weekday: '
                        '${weekly.map((WeekdayActivity w) => '${w.shortLabel} ${w.pieces}').join(', ')}',
                    bars: <ChartBar>[
                      for (final WeekdayActivity w in weekly)
                        ChartBar(
                          label: w.shortLabel,
                          value: w.pieces.toDouble(),
                        ),
                    ],
                  )
                : Center(
                    child: Text(
                      'No reading yet this week.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _RankedDonut extends StatelessWidget {
  const _RankedDonut({
    required this.title,
    required this.items,
    required this.tokens,
  });

  final String title;
  final List<RankedItem> items;
  final QTokens tokens;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleSmall),
        Gap.v2,
        QCard(
          padding: QCardPadding.md,
          child: items.isEmpty
              ? Text(
                  'Not enough reading yet to show $title.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                )
              : QPieChart(
                  semanticLabel:
                      '$title: ${items.map((RankedItem r) => '${r.label} ${r.count}').join(', ')}',
                  slices: <ChartSlice>[
                    for (int idx = 0; idx < items.length; idx++)
                      ChartSlice(
                        label: items[idx].label.isEmpty
                            ? items[idx].key
                            : items[idx].label,
                        value: items[idx].count.toDouble(),
                        color: chartColorAt(tokens.colors, idx),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

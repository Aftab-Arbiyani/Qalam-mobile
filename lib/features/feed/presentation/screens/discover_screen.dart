/// The Discovery screen (docs/40 §10.2, §6). A calm, vertically-scrolling set of
/// shelves: local Continue Reading, Featured & Recommended pieces, Trending &
/// Featured writers, Trending tags, and Recently Read — each best-effort and
/// cache-then-network. Pull-to-refresh reloads the remote shelves.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/reading_history/reading_history_controller.dart';
import '../../../../core/reading_history/reading_history_entry.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/q_refresh.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/entities/writer_summary.dart';
import '../controllers/discovery_controllers.dart';
import '../widgets/discovery_widgets.dart';
import '../widgets/history_card.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ReadingHistoryEntry> continueList = ref.watch(
      continueReadingListProvider,
    );
    final List<ReadingHistoryEntry> recentList = ref.watch(
      recentlyReadListProvider,
    );
    final AsyncValue<List<TrendingTag>> tags = ref.watch(
      trendingTagsShelfProvider,
    );

    return QScaffold(
      appBar: const QAppBar(title: 'Discover'),
      body: QRefresh(
        onRefresh: () async {
          ref
            ..invalidate(discoverPiecesShelfProvider)
            ..invalidate(discoverWritersShelfProvider)
            ..invalidate(trendingTagsShelfProvider);
          await ref.read(
            discoverPiecesShelfProvider(DiscoverPieceKind.featured).future,
          );
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: QSpacing.s6),
          children: <Widget>[
            if (continueList.isNotEmpty)
              _LocalShelf(
                title: 'Continue reading',
                entries: continueList.take(3).toList(),
              ),
            DiscoveryShelf<PieceSummary>(
              title: 'Featured',
              state: ref.watch(
                discoverPiecesShelfProvider(DiscoverPieceKind.featured),
              ),
              itemWidth: 240,
              height: 232,
              itemBuilder: (_, PieceSummary p) => PieceShelfCard(piece: p),
            ),
            DiscoveryShelf<PieceSummary>(
              title: 'Recommended',
              state: ref.watch(
                discoverPiecesShelfProvider(DiscoverPieceKind.mostClapped),
              ),
              itemWidth: 240,
              height: 232,
              itemBuilder: (_, PieceSummary p) => PieceShelfCard(piece: p),
            ),
            DiscoveryShelf<WriterSummary>(
              title: 'Popular writers',
              state: ref.watch(
                discoverWritersShelfProvider(WriterKind.popular),
              ),
              itemWidth: 100,
              height: 128,
              itemBuilder: (_, WriterSummary w) => WriterShelfCard(writer: w),
            ),
            DiscoveryShelf<WriterSummary>(
              title: 'Featured writers',
              state: ref.watch(
                discoverWritersShelfProvider(WriterKind.featured),
              ),
              itemWidth: 100,
              height: 128,
              itemBuilder: (_, WriterSummary w) => WriterShelfCard(writer: w),
            ),
            _TagsShelf(state: tags),
            if (recentList.isNotEmpty)
              _LocalShelf(
                title: 'Recently read',
                entries: recentList.take(5).toList(),
              ),
            if (continueList.isEmpty &&
                recentList.isEmpty &&
                tags.asData?.value.isEmpty == true)
              const Padding(
                padding: EdgeInsets.only(top: QSpacing.s7),
                child: QEmptyState(
                  icon: Icons.explore_outlined,
                  title: 'Nothing to discover yet.',
                  message:
                      'As the community publishes, fresh writing will gather here.',
                  minHeight: 240,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocalShelf extends StatelessWidget {
  const _LocalShelf({required this.title, required this.entries});

  final String title;
  final List<ReadingHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ShelfSection(
      title: title,
      child: Column(
        children: <Widget>[
          for (final ReadingHistoryEntry entry in entries)
            HistoryCard(entry: entry),
        ],
      ),
    );
  }
}

class _TagsShelf extends StatelessWidget {
  const _TagsShelf({required this.state});

  final AsyncValue<List<TrendingTag>> state;

  @override
  Widget build(BuildContext context) {
    return state.maybeWhen(
      data: (List<TrendingTag> tags) => tags.isEmpty
          ? const SizedBox.shrink()
          : ShelfSection(
              title: 'Trending tags',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
                child: Wrap(
                  spacing: QSpacing.s2,
                  runSpacing: QSpacing.s2,
                  children: <Widget>[
                    for (final TrendingTag tag in tags)
                      if (tag.name.isNotEmpty)
                        QChip(label: '#${tag.name}', tone: QChipTone.accent),
                  ],
                ),
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// The search discovery landing (docs/40 §6, E8) — the empty-query state. Reuses
/// the shared discovery shelves (`DiscoveryShelf`, `PieceShelfCard`,
/// `WriterShelfCard`), the shared reading-history cards, and the search trending
/// snapshot, composed for a search-first entry point: recent searches, **saved
/// searches**, trending searches, featured & recently-published shelves, popular
/// writers, popular genres/languages, and "continue discovering". Pull-to-refresh
/// reloads the remote shelves; everything is best-effort and cached for offline.
///
/// **D5 brought saved searches here.** They were reachable only from the
/// semantic-search screen behind the `/ai` prefix, which D5 deleted — so without a
/// home on this landing they would have become data a reader owns and cannot see.
/// The section is signed-in only and hides itself when empty, so a signed-out reader
/// never triggers the authenticated read that would 401 their session
/// (`platfrom/docs/48` §3.25).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/reading_history/reading_history_controller.dart';
import '../../../../core/reading_history/reading_history_entry.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/discovery/discovery_providers.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/retrieval/domain/saved_search.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/content/history_card.dart';
import '../../../../shared/widgets/discovery/discovery_widgets.dart';
import '../../../../shared/widgets/feedback/q_dialog.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/list/q_refresh.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../domain/entities/recent_search.dart';
import '../../domain/entities/trending_searches.dart';
import '../controllers/recent_searches_controller.dart';
import '../controllers/saved_searches_controller.dart';
import '../controllers/search_controller.dart';
import '../controllers/search_suggestions_controller.dart';

class SearchDiscoveryView extends ConsumerWidget {
  const SearchDiscoveryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<RecentSearch> recents = ref.watch(
      recentSearchesControllerProvider,
    );
    final AsyncValue<TrendingSearches> trending = ref.watch(
      trendingSearchesProvider,
    );
    final List<ReadingHistoryEntry> continueList = ref.watch(
      continueReadingListProvider,
    );
    final bool showDiscovery = ref
        .watch(preferencesStoreProvider)
        .searchShowDiscovery;

    final TrendingSearches trend =
        trending.asData?.value ?? const TrendingSearches();

    // Empty for a signed-out reader without reaching the network — the controller's
    // own auth gate, not a render check here.
    final List<SavedSearch> saved = ref.watch(savedSearchesControllerProvider);

    final bool everythingEmpty =
        recents.isEmpty &&
        saved.isEmpty &&
        trend.isEmpty &&
        continueList.isEmpty;

    return QRefresh(
      onRefresh: () async {
        ref
          ..invalidate(trendingSearchesProvider)
          ..invalidate(discoverPiecesShelfProvider)
          ..invalidate(discoverWritersShelfProvider);
        await ref
            .read(trendingSearchesProvider.future)
            .catchError((_) => const TrendingSearches());
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: QSpacing.s7),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: <Widget>[
          if (recents.isNotEmpty) _RecentSearches(recents: recents),
          if (saved.isNotEmpty) _SavedSearches(saved: saved),
          if (trend.keywords.isNotEmpty)
            _ChipShelf(
              title: l10n.searchTrendingTitle,
              children: <Widget>[
                for (final TrendingKeyword k in trend.keywords)
                  QChip(
                    label: k.keyword,
                    icon: Icons.trending_up,
                    onTap: () => _submit(ref, k.keyword, SearchType.all),
                  ),
              ],
            ),
          if (showDiscovery) ...<Widget>[
            DiscoveryShelf<PieceSummary>(
              title: l10n.searchDiscoverFeatured,
              state: ref.watch(
                discoverPiecesShelfProvider(DiscoverPieceKind.featured),
              ),
              itemWidth: 240,
              height: 232,
              itemBuilder: (_, PieceSummary p) => PieceShelfCard(piece: p),
            ),
            DiscoveryShelf<WriterSummary>(
              title: l10n.searchDiscoverPopularWriters,
              state: ref.watch(
                discoverWritersShelfProvider(WriterKind.popular),
              ),
              itemWidth: 100,
              height: 128,
              itemBuilder: (_, WriterSummary w) => WriterShelfCard(writer: w),
            ),
            DiscoveryShelf<PieceSummary>(
              title: l10n.searchDiscoverRecent,
              state: ref.watch(
                discoverPiecesShelfProvider(DiscoverPieceKind.recent),
              ),
              itemWidth: 240,
              height: 232,
              itemBuilder: (_, PieceSummary p) => PieceShelfCard(piece: p),
            ),
            if (trend.tags.isNotEmpty)
              _ChipShelf(
                title: l10n.searchTrendingTags,
                children: <Widget>[
                  for (final TrendingTag t in trend.tags)
                    if (t.name.isNotEmpty)
                      QChip(
                        label: '#${t.name}',
                        tone: QChipTone.accent,
                        onTap: () => _submit(ref, t.name, SearchType.tags),
                      ),
                ],
              ),
            if (trend.genres.isNotEmpty)
              _ChipShelf(
                title: l10n.searchDiscoverPopularGenres,
                children: <Widget>[
                  for (final TrendingGenre g in trend.genres)
                    if (g.name.isNotEmpty)
                      QChip(
                        label: g.name,
                        onTap: () => _submit(ref, g.name, SearchType.genres),
                      ),
                ],
              ),
          ],
          if (continueList.isNotEmpty)
            ShelfSection(
              title: l10n.searchDiscoverContinue,
              child: Column(
                children: <Widget>[
                  for (final ReadingHistoryEntry e in continueList.take(3))
                    HistoryCard(entry: e),
                ],
              ),
            ),
          if (everythingEmpty)
            Padding(
              padding: const EdgeInsets.only(top: QSpacing.s7),
              child: QEmptyState(
                icon: Icons.search,
                title: l10n.searchDiscoverEmptyTitle,
                message: l10n.searchDiscoverEmptyBody,
                minHeight: 240,
              ),
            ),
        ],
      ),
    );
  }

  void _submit(WidgetRef ref, String query, SearchType type) =>
      ref.read(searchQueryControllerProvider.notifier).submit(query, type);
}

/// The reader's saved searches. Tapping one re-runs it; the trailing action removes
/// it locally first and on the server best-effort, matching the recents shelf above.
class _SavedSearches extends ConsumerWidget {
  const _SavedSearches({required this.saved});

  final List<SavedSearch> saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ShelfSection(
      title: l10n.searchSavedTitle,
      child: Column(
        children: <Widget>[
          for (final SavedSearch entry in saved)
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text(entry.name),
              subtitle: entry.query == entry.name ? null : Text(entry.query),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.searchSavedRemove,
                onPressed: () async {
                  await ref
                      .read(savedSearchesControllerProvider.notifier)
                      .remove(entry);
                  if (!context.mounted) return;
                  QSnackbar.show(context, message: l10n.searchSavedRemoved);
                },
              ),
              onTap: () => ref
                  .read(searchQueryControllerProvider.notifier)
                  .submit(entry.query, SearchType.all),
            ),
        ],
      ),
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches({required this.recents});

  final List<RecentSearch> recents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ShelfSection(
      title: l10n.searchRecentTitle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: QSpacing.s2,
              runSpacing: QSpacing.s2,
              children: <Widget>[
                for (final RecentSearch r in recents)
                  QChip(
                    label: r.query,
                    icon: Icons.history,
                    onTap: () => ref
                        .read(searchQueryControllerProvider.notifier)
                        .submit(r.query, r.searchType),
                    onRemove: () => ref
                        .read(recentSearchesControllerProvider.notifier)
                        .remove(r),
                  ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => _confirmClear(context, ref, l10n),
                child: Text(l10n.searchRecentClear),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    // Clearing wipes the server-side history too — irreversible, so confirm.
    final bool ok = await QDialog.confirm(
      context,
      title: l10n.searchClearHistoryTitle,
      message: l10n.searchClearHistoryBody,
      confirmLabel: l10n.searchRecentClear,
      destructive: true,
    );
    if (ok) {
      await ref.read(recentSearchesControllerProvider.notifier).clear();
    }
  }
}

class _ChipShelf extends StatelessWidget {
  const _ChipShelf({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ShelfSection(
      title: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
        child: Wrap(
          spacing: QSpacing.s2,
          runSpacing: QSpacing.s2,
          children: children,
        ),
      ),
    );
  }
}

/// The tabbed search results (docs/40 §13.7, §44). A scrollable scope strip
/// (All · Pieces · Writers · Tags · Genres · Languages) over a body that reuses
/// the shared infinite-scroll `PagedFeedView` for each per-type search and the
/// shared `PieceCard` / result tiles for rows. The "All" tab renders the grouped
/// preview with per-group "See all" jumps. Tapping a tag/genre/language result
/// pivots to filtered piece results. Pull-to-refresh + load-more come for free.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/content/piece_card.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/loading/feed_skeleton_list.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/global_search_result.dart';
import '../../domain/value_objects/search_filters.dart';
import '../../domain/value_objects/search_request.dart';
import '../controllers/search_controller.dart';
import '../controllers/search_filters_controller.dart';
import '../controllers/search_results_controller.dart';
import 'search_result_tiles.dart';

/// The scopes shown as tabs, in order.
const List<SearchType> _tabs = <SearchType>[
  SearchType.all,
  SearchType.pieces,
  SearchType.writers,
  SearchType.tags,
  SearchType.genres,
  SearchType.languages,
];

class SearchResultsView extends ConsumerWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SearchType active = ref.watch(
      searchQueryControllerProvider.select((SearchState s) => s.activeType),
    );

    return Column(
      children: <Widget>[
        _ScopeStrip(active: active),
        const Divider(height: 1),
        Expanded(
          child: active == SearchType.all
              ? const _AllResults()
              : _TypedResults(type: active),
        ),
      ],
    );
  }
}

class _ScopeStrip extends ConsumerWidget {
  const _ScopeStrip({required this.active});

  final SearchType active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: QSpacing.s4,
          vertical: QSpacing.s2,
        ),
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: QSpacing.s2),
        itemBuilder: (BuildContext context, int index) {
          final SearchType type = _tabs[index];
          return QChip(
            label: _tabLabel(l10n, type),
            tone: type == active ? QChipTone.accent : QChipTone.neutral,
            onTap: () => ref
                .read(searchQueryControllerProvider.notifier)
                .setActiveType(type),
          );
        },
      ),
    );
  }
}

String _tabLabel(AppLocalizations l10n, SearchType type) => switch (type) {
  SearchType.all => l10n.searchTabAll,
  SearchType.pieces => l10n.searchTabPieces,
  SearchType.writers => l10n.searchTabWriters,
  SearchType.tags => l10n.searchTabTags,
  SearchType.genres => l10n.searchTabGenres,
  SearchType.languages => l10n.searchTabLanguages,
};

/// A paginated per-type result list, reusing the shared [PagedFeedView].
class _TypedResults extends ConsumerWidget {
  const _TypedResults({required this.type});

  final SearchType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SearchState search = ref.watch(searchQueryControllerProvider);
    final SearchFilters filters = ref.watch(searchFiltersControllerProvider);
    final SearchRequest request = SearchRequest(
      query: search.submittedQuery,
      type: type,
      filters: filters,
    );
    final provider = searchResultsControllerProvider(request);

    return PagedFeedView<Object>(
      state: ref.watch(provider),
      loading: const FeedSkeletonList(),
      staleNotice: l10n.searchOfflineResultsBody,
      empty: QEmptyState(
        icon: Icons.search_off,
        title: l10n.searchEmptyTitle,
        message: l10n.searchEmptyBody,
      ),
      onRefresh: () => ref.read(provider.notifier).refresh(),
      onLoadMore: () => ref.read(provider.notifier).loadMore(),
      itemBuilder: (BuildContext context, Object item, int index) =>
          _resultItem(ref, type, item),
    );
  }
}

Widget _resultItem(WidgetRef ref, SearchType type, Object item) {
  switch (type) {
    case SearchType.pieces:
      return PieceCard(piece: item as PieceSummary);
    case SearchType.writers:
      return WriterResultTile(writer: item as WriterSummary);
    case SearchType.tags:
      final TrendingTag tag = item as TrendingTag;
      return tagResultTile(tag, () => _pivotToTag(ref, tag.slug));
    case SearchType.genres:
      final TrendingGenre genre = item as TrendingGenre;
      return genreResultTile(genre, () => _pivotToGenre(ref, genre.slug));
    case SearchType.languages:
      final TrendingLanguage language = item as TrendingLanguage;
      return languageResultTile(
        language,
        () => _pivotToLanguage(ref, language.code),
      );
    case SearchType.all:
      return const SizedBox.shrink();
  }
}

void _pivotToTag(WidgetRef ref, String slug) {
  ref.read(searchFiltersControllerProvider.notifier).setTag(slug);
  ref
      .read(searchQueryControllerProvider.notifier)
      .setActiveType(SearchType.pieces);
}

void _pivotToGenre(WidgetRef ref, String slug) {
  ref.read(searchFiltersControllerProvider.notifier).setGenres(<String>[slug]);
  ref
      .read(searchQueryControllerProvider.notifier)
      .setActiveType(SearchType.pieces);
}

void _pivotToLanguage(WidgetRef ref, String code) {
  ref.read(searchFiltersControllerProvider.notifier).setLanguages(<String>[
    code,
  ]);
  ref
      .read(searchQueryControllerProvider.notifier)
      .setActiveType(SearchType.pieces);
}

/// The "All" tab — the grouped preview, each non-empty group a short section with
/// a "See all" jump to that scope's tab.
class _AllResults extends ConsumerWidget {
  const _AllResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String query = ref.watch(
      searchQueryControllerProvider.select((SearchState s) => s.submittedQuery),
    );
    final AsyncValue<GlobalSearchResult> async = ref.watch(
      globalSearchProvider(query),
    );

    return async.when(
      skipLoadingOnRefresh: true,
      loading: () => const FeedSkeletonList(),
      error: (Object error, StackTrace _) => QErrorView(
        failure: error is Failure
            ? error
            : Failure.unexpected(
                code: ErrorCodes.apiUnexpected,
                message: '$error',
              ),
        onRetry: () => ref.invalidate(globalSearchProvider(query)),
      ),
      data: (GlobalSearchResult result) {
        if (result.isEmpty) {
          return QEmptyState(
            icon: Icons.search_off,
            title: l10n.searchEmptyTitle,
            message: l10n.searchEmptyBody,
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: QSpacing.s6),
          children: <Widget>[
            if (result.writers.isNotEmpty)
              _Group(
                title: l10n.searchTabWriters,
                onSeeAll: () => _see(ref, SearchType.writers),
                children: <Widget>[
                  for (final WriterSummary w in result.writers)
                    WriterResultTile(writer: w),
                ],
              ),
            if (result.pieces.isNotEmpty)
              _Group(
                title: l10n.searchTabPieces,
                onSeeAll: () => _see(ref, SearchType.pieces),
                children: <Widget>[
                  for (final PieceSummary p in result.pieces)
                    PieceCard(piece: p),
                ],
              ),
            if (result.tags.isNotEmpty)
              _Group(
                title: l10n.searchTabTags,
                onSeeAll: () => _see(ref, SearchType.tags),
                children: <Widget>[
                  for (final TrendingTag t in result.tags)
                    tagResultTile(t, () => _pivotToTag(ref, t.slug)),
                ],
              ),
            if (result.genres.isNotEmpty)
              _Group(
                title: l10n.searchTabGenres,
                onSeeAll: () => _see(ref, SearchType.genres),
                children: <Widget>[
                  for (final TrendingGenre g in result.genres)
                    genreResultTile(g, () => _pivotToGenre(ref, g.slug)),
                ],
              ),
            if (result.languages.isNotEmpty)
              _Group(
                title: l10n.searchTabLanguages,
                onSeeAll: () => _see(ref, SearchType.languages),
                children: <Widget>[
                  for (final TrendingLanguage lang in result.languages)
                    languageResultTile(
                      lang,
                      () => _pivotToLanguage(ref, lang.code),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  void _see(WidgetRef ref, SearchType type) =>
      ref.read(searchQueryControllerProvider.notifier).setActiveType(type);
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.onSeeAll,
    required this.children,
  });

  final String title;
  final VoidCallback onSeeAll;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s4,
            QSpacing.s4,
            QSpacing.s2,
            QSpacing.s1,
          ),
          child: Row(
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  l10n.searchSeeAll,
                  style: TextStyle(color: tokens.colors.accent),
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

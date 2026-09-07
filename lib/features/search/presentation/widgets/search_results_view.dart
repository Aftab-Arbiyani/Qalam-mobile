/// The tabbed search results (docs/40 §13.7, §44). A scrollable scope strip
/// (All · Pieces · Writers · Tags · Genres · Languages) over a body that reuses
/// the shared infinite-scroll `PagedFeedView` for each per-type search and the
/// shared `PieceCard` / result tiles for rows. Tapping a tag/genre/language result
/// pivots to filtered piece results. Pull-to-refresh + load-more come for free.
///
/// **D5 replaced what the "All" tab runs.** There used to be two engines behind
/// search: this screen's E8 grouped preview, and a separate "Semantic search" screen
/// on the `/ai` prefix. Offering both asked the reader to pick an implementation,
/// which is a question they have no way to answer. So "All" is the ranked retrieval
/// engine now — public, grounded, and explaining each result — and the narrower tabs
/// stay exactly as they were, because a *scope* refines the reader's own intent
/// rather than asking them to choose a mechanism.
///
/// Nothing here reads `GET /ai/features`. That is deliberate and load-bearing:
/// search is public, the flag read is not, and a 401 on a public page is terminal to
/// the api client (`platfrom/docs/48` §3.25).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/retrieval/domain/retrieval.dart';
import '../../../../shared/retrieval/retrieval_providers.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/content/piece_card.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/loading/feed_skeleton_list.dart';
import '../../../../shared/widgets/retrieval/retrieval_cards.dart';
import '../../../../shared/widgets/retrieval/retrieval_navigation.dart';
import '../../../../shared/widgets/retrieval/search_result_sheet.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
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

/// The "All" tab — ranked, grounded results from the retrieval engine.
///
/// Every card carries the ranker's own reason for surfacing it, so the reader can see
/// *why* rather than being asked to trust an ordering. A result with a route opens it;
/// one without (a graph node, say) opens the detail sheet in place, so nothing is a
/// dead end.
class _AllResults extends ConsumerWidget {
  const _AllResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String query = ref.watch(
      searchQueryControllerProvider.select((SearchState s) => s.submittedQuery),
    );
    final AsyncValue<SemanticSearchResponse> async = ref.watch(
      retrievalResultsProvider((query: query, storyId: null)),
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
        onRetry: () => ref.invalidate(
          retrievalResultsProvider((query: query, storyId: null)),
        ),
      ),
      data: (SemanticSearchResponse result) {
        if (result.results.isEmpty) {
          return QEmptyState(
            icon: Icons.search_off,
            title: l10n.searchEmptyTitle,
            message: l10n.searchEmptyBody,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s4,
            QSpacing.s3,
            QSpacing.s4,
            QSpacing.s6,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: result.results.length,
          separatorBuilder: (_, _) => Gap.v3,
          itemBuilder: (BuildContext context, int i) {
            final SearchResultItem item = result.results[i];
            return SearchResultCard(
              item: item,
              onOpen: () {
                if (!navigateToTarget(context, item.navigation)) {
                  unawaited(showSearchResultSheet(context, item));
                }
              },
              // A related entity has no navigation target of its own — it names a
              // neighbour in the graph. Opening the parent result's sheet, which lists
              // those neighbours, is the only honest destination.
              onRelatedTap: (RelatedEntity _) =>
                  unawaited(showSearchResultSheet(context, item)),
            );
          },
        );
      },
    );
  }
}

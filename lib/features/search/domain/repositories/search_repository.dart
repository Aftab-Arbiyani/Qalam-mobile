/// The search feature boundary (docs/40 §16, E8). One repository over the frozen
/// `/search/*` endpoints: the grouped preview, the five paginated per-type
/// searches, autocomplete, trending, and recent-search management. Per-type
/// results are cache-then-network (offline replay of the last query); the grouped
/// preview and trending are cached too; autocomplete never is (ephemeral). Returns
/// domain [Result]s — never a DTO, `DioException`, or HTTP status. Reuses the
/// shared read models (`PieceSummary`, `WriterSummary`, trend items) so results
/// render identically to the feed and discovery surfaces (docs/40 §7.3).
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../entities/autocomplete_result.dart';
import '../entities/global_search_result.dart';
import '../entities/recent_search.dart';
import '../entities/trending_searches.dart';
import '../value_objects/search_filters.dart';

abstract interface class SearchRepository {
  /// The grouped global preview across all five groups (`GET /search`).
  Future<Result<GlobalSearchResult>> globalSearch(String query, {int limit});

  /// Full-text piece search with filters (`GET /search/pieces`), cursor-paginated.
  Future<Result<CachedPage<PieceSummary>>> searchPieces(
    String query,
    SearchFilters filters, {
    String? cursor,
  });

  /// Writer search (`GET /search/writers`), cursor-paginated. Private accounts
  /// appear as teasers (`isPrivate == true`).
  Future<Result<CachedPage<WriterSummary>>> searchWriters(
    String query,
    SearchFilters filters, {
    String? cursor,
  });

  /// Tag search (`GET /search/tags`); `query` empty browses by usage.
  Future<Result<CachedPage<TrendingTag>>> searchTags(
    String query, {
    String? cursor,
  });

  /// Genre search (`GET /search/genres`); `query` empty browses by popularity.
  Future<Result<CachedPage<TrendingGenre>>> searchGenres(
    String query, {
    String? cursor,
  });

  /// Language search (`GET /search/languages`); `query` empty browses.
  Future<Result<CachedPage<TrendingLanguage>>> searchLanguages(
    String query, {
    String? cursor,
  });

  /// Prefix-first suggestions (`GET /search/autocomplete`). Cancellable so a
  /// stale keystroke's request is dropped when a newer one starts.
  Future<Result<AutocompleteResult>> autocomplete(
    String query, {
    SearchType type,
    int limit,
  });

  /// Trending keywords / tags / genres / writers (`GET /search/trending`), cached.
  Future<Result<TrendingSearches>> trending({int limit});

  /// The signed-in user's server-recorded recent searches (`GET /search/recent`).
  Future<Result<List<RecentSearch>>> serverRecents();

  /// Delete one server recent search (`DELETE /search/recent/:id`).
  Future<Result<Unit>> deleteServerRecent(String id);

  /// Clear all server recent searches (`DELETE /search/recent`).
  Future<Result<Unit>> clearServerRecents();
}

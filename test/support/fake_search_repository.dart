/// A canned [SearchRepository] for widget/provider tests — returns seeded results
/// with no network. Every surface can be seeded independently; defaults are empty.
library;

import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/search/domain/entities/autocomplete_result.dart';
import 'package:qalam_mobile/features/search/domain/entities/global_search_result.dart';
import 'package:qalam_mobile/features/search/domain/entities/recent_search.dart';
import 'package:qalam_mobile/features/search/domain/entities/trending_searches.dart';
import 'package:qalam_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:qalam_mobile/features/search/domain/value_objects/search_filters.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/shared/domain/entities/trend_item.dart';
import 'package:qalam_mobile/shared/domain/entities/writer_summary.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/pagination/cached_page.dart';

class FakeSearchRepository implements SearchRepository {
  FakeSearchRepository({
    this.global = const GlobalSearchResult(),
    this.pieces = const <PieceSummary>[],
    this.writers = const <WriterSummary>[],
    this.tags = const <TrendingTag>[],
    this.genres = const <TrendingGenre>[],
    this.languages = const <TrendingLanguage>[],
    this.autocompleteResult = const AutocompleteResult(),
    this.trendingResult = const TrendingSearches(),
    this.recents = const <RecentSearch>[],
    this.hasMore = false,
    this.nextCursor,
  });

  final GlobalSearchResult global;
  final List<PieceSummary> pieces;
  final List<WriterSummary> writers;
  final List<TrendingTag> tags;
  final List<TrendingGenre> genres;
  final List<TrendingLanguage> languages;
  final AutocompleteResult autocompleteResult;
  final TrendingSearches trendingResult;
  final List<RecentSearch> recents;
  final bool hasMore;
  final String? nextCursor;

  int autocompleteCalls = 0;
  int deleteRecentCalls = 0;
  int clearRecentCalls = 0;

  CachedPage<T> _page<T>(List<T> items) => CachedPage<T>(
    page: CursorPage<T>(
      items: items,
      meta: CursorMeta(hasMore: hasMore, nextCursor: nextCursor),
    ),
  );

  @override
  Future<Result<GlobalSearchResult>> globalSearch(String query, {int limit = 5}) async =>
      Ok<GlobalSearchResult>(global);

  @override
  Future<Result<CachedPage<PieceSummary>>> searchPieces(
    String query,
    SearchFilters filters, {
    String? cursor,
  }) async => Ok<CachedPage<PieceSummary>>(_page(pieces));

  @override
  Future<Result<CachedPage<WriterSummary>>> searchWriters(
    String query,
    SearchFilters filters, {
    String? cursor,
  }) async => Ok<CachedPage<WriterSummary>>(_page(writers));

  @override
  Future<Result<CachedPage<TrendingTag>>> searchTags(
    String query, {
    String? cursor,
  }) async => Ok<CachedPage<TrendingTag>>(_page(tags));

  @override
  Future<Result<CachedPage<TrendingGenre>>> searchGenres(
    String query, {
    String? cursor,
  }) async => Ok<CachedPage<TrendingGenre>>(_page(genres));

  @override
  Future<Result<CachedPage<TrendingLanguage>>> searchLanguages(
    String query, {
    String? cursor,
  }) async => Ok<CachedPage<TrendingLanguage>>(_page(languages));

  @override
  Future<Result<AutocompleteResult>> autocomplete(
    String query, {
    SearchType type = SearchType.all,
    int limit = 10,
  }) async {
    autocompleteCalls++;
    return Ok<AutocompleteResult>(autocompleteResult);
  }

  @override
  Future<Result<TrendingSearches>> trending({int limit = 10}) async =>
      Ok<TrendingSearches>(trendingResult);

  @override
  Future<Result<List<RecentSearch>>> serverRecents() async =>
      Ok<List<RecentSearch>>(recents);

  @override
  Future<Result<Unit>> deleteServerRecent(String id) async {
    deleteRecentCalls++;
    return const Ok<Unit>(unit);
  }

  @override
  Future<Result<Unit>> clearServerRecents() async {
    clearRecentCalls++;
    return const Ok<Unit>(unit);
  }
}

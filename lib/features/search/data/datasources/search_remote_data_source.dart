/// Search remote data source (docs/40 §17.1) — the only place the search feature
/// touches the wire. Grouped/autocomplete/trending are single decoded objects;
/// the five per-type searches are cursor pages. `q` is sent only when non-empty
/// (tag/genre/language browse omits it). Autocomplete takes a [CancelToken] so a
/// superseded keystroke's request is aborted. Throws [ApiException] for the
/// repository to translate; knows nothing of caching or `Failure`.
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/data/entity_mappers.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/autocomplete_result.dart';
import '../../domain/entities/global_search_result.dart';
import '../../domain/entities/recent_search.dart';
import '../../domain/entities/trending_searches.dart';
import '../mappers/search_mappers.dart';

class SearchRemoteDataSource {
  SearchRemoteDataSource(this._api);

  final ApiClient _api;

  static const int _limit = 20;

  Future<GlobalSearchResult> globalSearch(String query, {int limit = 5}) =>
      _api.get<GlobalSearchResult>(
        ApiPaths.search,
        query: <String, dynamic>{'q': query, 'limit': limit},
        decode: globalSearchFromJson,
      );

  Future<CursorPage<PieceSummary>> searchPieces(
    String query,
    Json filterParams, {
    String? cursor,
  }) => _api.getPage<PieceSummary>(
    ApiPaths.searchPieces,
    query: <String, dynamic>{'q': query, ...filterParams, 'cursor': ?cursor, 'limit': _limit},
    decodeItem: pieceSummaryFromJson,
  );

  Future<CursorPage<WriterSummary>> searchWriters(
    String query,
    Json filterParams, {
    String? cursor,
  }) => _api.getPage<WriterSummary>(
    ApiPaths.searchWriters,
    query: <String, dynamic>{'q': query, ...filterParams, 'cursor': ?cursor, 'limit': _limit},
    decodeItem: writerSummaryFromJson,
  );

  Future<CursorPage<TrendingTag>> searchTags(String query, {String? cursor}) =>
      _api.getPage<TrendingTag>(
        ApiPaths.searchTags,
        query: _taxonomyQuery(query, cursor),
        decodeItem: trendingTagFromJson,
      );

  Future<CursorPage<TrendingGenre>> searchGenres(
    String query, {
    String? cursor,
  }) => _api.getPage<TrendingGenre>(
    ApiPaths.searchGenres,
    query: _taxonomyQuery(query, cursor),
    decodeItem: trendingGenreFromJson,
  );

  Future<CursorPage<TrendingLanguage>> searchLanguages(
    String query, {
    String? cursor,
  }) => _api.getPage<TrendingLanguage>(
    ApiPaths.searchLanguages,
    query: _taxonomyQuery(query, cursor),
    decodeItem: trendingLanguageFromJson,
  );

  Future<AutocompleteResult> autocomplete(
    String query, {
    SearchType type = SearchType.all,
    int limit = 10,
    CancelToken? cancelToken,
  }) => _api.get<AutocompleteResult>(
    ApiPaths.searchAutocomplete,
    query: <String, dynamic>{'q': query, 'type': type.wire, 'limit': limit},
    decode: autocompleteFromJson,
    cancelToken: cancelToken,
    deduplicate: false,
  );

  Future<TrendingSearches> trending({int limit = 10}) =>
      _api.get<TrendingSearches>(
        ApiPaths.searchTrending,
        query: <String, dynamic>{'limit': limit},
        decode: trendingSearchesFromJson,
      );

  Future<List<RecentSearch>> recent() => _api.getList<RecentSearch>(
    ApiPaths.searchRecent,
    decodeItem: recentSearchFromJson,
  );

  Future<void> deleteRecent(String id) =>
      _api.delete(ApiPaths.searchRecentById(id));

  Future<void> clearRecent() => _api.delete(ApiPaths.searchRecent);

  /// Tag/genre/language browse: `q` optional; omit it entirely when blank so the
  /// backend browses by popularity.
  Json _taxonomyQuery(String query, String? cursor) {
    final String trimmed = query.trim();
    return <String, dynamic>{
      if (trimmed.isNotEmpty) 'q': trimmed,
      'cursor': ?cursor,
      'limit': _limit,
    };
  }
}

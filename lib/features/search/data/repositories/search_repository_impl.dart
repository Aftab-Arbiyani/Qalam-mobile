/// Search repository implementation (docs/40 §16, §23, E8). Per-type searches
/// delegate to the shared [loadCachedPage] engine (offline replay of the last
/// query). The grouped preview and trending are cached as whole objects through
/// the shared [loadCachedObject] with the same stale-on-failure fallback.
/// Autocomplete is never cached and is single-flight-cancellable: each call
/// cancels the previous in-flight request so a stale keystroke never lands.
/// All transport errors become domain [Failure]s.
///
/// Cache keys embed the normalized query, so each scope keeps only its most
/// recent query's entry ([_retirePrevious]) — distinct searches must not
/// accumulate unbounded rows in the cache box.
library;

import 'package:dio/dio.dart';

import '../../../../core/error/result_guard.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/data/cache_list_data_source.dart';
import '../../../../shared/data/cached_page_loader.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../../domain/entities/autocomplete_result.dart';
import '../../domain/entities/global_search_result.dart';
import '../../domain/entities/recent_search.dart';
import '../../domain/entities/trending_searches.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/value_objects/search_filters.dart';
import '../datasources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._remote, this._pageCache, this._objectCache);

  final SearchRemoteDataSource _remote;
  final CacheListDataSource _pageCache;
  final CacheStore _objectCache;

  /// The in-flight autocomplete request; cancelled when a newer one starts.
  CancelToken? _autocompleteToken;

  @override
  Future<Result<GlobalSearchResult>> globalSearch(
    String query, {
    int limit = 5,
  }) async {
    final String cacheKey = 'search:all:${_norm(query)}';
    final Result<GlobalSearchResult> result =
        await loadCachedObject<GlobalSearchResult>(
          cache: _objectCache,
          cacheKey: cacheKey,
          fetch: () => _remote.globalSearch(query, limit: limit),
          toJson: (GlobalSearchResult r) => r.toJson(),
          fromJson: GlobalSearchResult.fromJson,
          tier: CacheTier.live,
        );
    if (result.isOk) await _retirePrevious('all', cacheKey);
    return result;
  }

  @override
  Future<Result<CachedPage<PieceSummary>>> searchPieces(
    String query,
    SearchFilters filters, {
    String? cursor,
  }) => _loadScopedPage<PieceSummary>(
    scope: 'pieces',
    cacheKey: 'search:pieces:${_norm(query)}:${filters.signature}',
    cursor: cursor,
    fetch: (String? c) =>
        _remote.searchPieces(query, filters.toPieceParams(), cursor: c),
    toJson: (PieceSummary p) => p.toJson(),
    fromJson: PieceSummary.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<CachedPage<WriterSummary>>> searchWriters(
    String query,
    SearchFilters filters, {
    String? cursor,
  }) => _loadScopedPage<WriterSummary>(
    scope: 'writers',
    cacheKey: 'search:writers:${_norm(query)}:${filters.signature}',
    cursor: cursor,
    fetch: (String? c) =>
        _remote.searchWriters(query, filters.toWriterParams(), cursor: c),
    toJson: (WriterSummary w) => w.toJson(),
    fromJson: WriterSummary.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<CachedPage<TrendingTag>>> searchTags(
    String query, {
    String? cursor,
  }) => _loadScopedPage<TrendingTag>(
    scope: 'tags',
    cacheKey: 'search:tags:${_norm(query)}',
    cursor: cursor,
    fetch: (String? c) => _remote.searchTags(query, cursor: c),
    toJson: (TrendingTag t) => t.toJson(),
    fromJson: TrendingTag.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<CachedPage<TrendingGenre>>> searchGenres(
    String query, {
    String? cursor,
  }) => _loadScopedPage<TrendingGenre>(
    scope: 'genres',
    cacheKey: 'search:genres:${_norm(query)}',
    cursor: cursor,
    fetch: (String? c) => _remote.searchGenres(query, cursor: c),
    toJson: (TrendingGenre g) => g.toJson(),
    fromJson: TrendingGenre.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<CachedPage<TrendingLanguage>>> searchLanguages(
    String query, {
    String? cursor,
  }) => _loadScopedPage<TrendingLanguage>(
    scope: 'languages',
    cacheKey: 'search:languages:${_norm(query)}',
    cursor: cursor,
    fetch: (String? c) => _remote.searchLanguages(query, cursor: c),
    toJson: (TrendingLanguage l) => l.toJson(),
    fromJson: TrendingLanguage.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<AutocompleteResult>> autocomplete(
    String query, {
    SearchType type = SearchType.all,
    int limit = 10,
  }) {
    _autocompleteToken?.cancel('superseded');
    final CancelToken token = CancelToken();
    _autocompleteToken = token;
    return guardResult<AutocompleteResult>(() async {
      try {
        return await _remote.autocomplete(
          query,
          type: type,
          limit: limit,
          cancelToken: token,
        );
      } finally {
        if (identical(_autocompleteToken, token)) _autocompleteToken = null;
      }
    });
  }

  @override
  Future<Result<TrendingSearches>> trending({int limit = 10}) =>
      loadCachedObject<TrendingSearches>(
        cache: _objectCache,
        cacheKey: 'search:trending',
        fetch: () => _remote.trending(limit: limit),
        toJson: (TrendingSearches t) => t.toJson(),
        fromJson: TrendingSearches.fromJson,
        tier: CacheTier.content,
      );

  @override
  Future<Result<List<RecentSearch>>> serverRecents() =>
      guardResult<List<RecentSearch>>(_remote.recent);

  @override
  Future<Result<Unit>> deleteServerRecent(String id) =>
      guardUnit(() => _remote.deleteRecent(id));

  @override
  Future<Result<Unit>> clearServerRecents() => guardUnit(_remote.clearRecent);

  // ── helpers ──────────────────────────────────────────────────────────────

  /// [loadCachedPage] plus scope bookkeeping: when a fresh page one lands, the
  /// previous query's entry for [scope] is evicted so the cache holds at most
  /// one entry per scope.
  Future<Result<CachedPage<T>>> _loadScopedPage<T>({
    required String scope,
    required String cacheKey,
    required String? cursor,
    required Future<CursorPage<T>> Function(String? cursor) fetch,
    required Json Function(T) toJson,
    required T Function(Json) fromJson,
    required CacheTier tier,
  }) async {
    final Result<CachedPage<T>> result = await loadCachedPage<T>(
      cache: _pageCache,
      cacheKey: cacheKey,
      cursor: cursor,
      fetch: fetch,
      toJson: toJson,
      fromJson: fromJson,
      tier: tier,
    );
    final bool freshFirstPage =
        cursor == null && (result.valueOrNull?.isStale ?? true) == false;
    if (freshFirstPage) await _retirePrevious(scope, cacheKey);
    return result;
  }

  /// Point [scope] at [activeKey], evicting the entry the scope pointed at
  /// before. Best-effort bookkeeping — never lets a cache error fail a search.
  Future<void> _retirePrevious(String scope, String activeKey) async {
    try {
      final String pointerKey = 'search:current:$scope';
      final CacheEntry? pointer = await _objectCache.read(pointerKey);
      final Object? previous = pointer?.value['key'];
      if (previous == activeKey) return;
      if (previous is String) await _objectCache.evict(previous);
      await _objectCache.write(pointerKey, <String, dynamic>{
        'key': activeKey,
      }, tier: CacheTier.content);
    } on Object {
      // Bookkeeping only — an orphaned entry is cleaned up on logout.
    }
  }

  String _norm(String query) => query.trim().toLowerCase();
}

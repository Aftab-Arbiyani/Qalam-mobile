/// Feed repository implementation (docs/40 §16, §23) — one cache-then-network
/// engine ([_load]) drives every feed + discovery surface, so there is zero
/// duplicated pagination/caching logic. Page 1 caches its items and, on a network
/// failure, falls back to the cached page marked stale (offline reading, docs/40
/// §23.2); later pages are network-only. All transport errors become domain
/// [Failure]s; no DTO/`DioException`/HTTP status escapes upward.
library;

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../domain/entities/bookmark_item.dart';
import '../../domain/entities/cached_page.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/entities/writer_summary.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../domain/value_objects/feed_query.dart';
import '../datasources/feed_local_data_source.dart';
import '../datasources/feed_remote_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._remote, this._local);

  final FeedRemoteDataSource _remote;
  final FeedLocalDataSource _local;

  @override
  Future<Result<CachedPage<PieceSummary>>> pieceFeed(
    FeedTab tab, {
    FeedQuery query = FeedQuery.none,
    String? cursor,
  }) => _load<PieceSummary>(
    cacheKey: tab.cacheKey,
    cursor: cursor,
    fetch: (String? c) => _remote.pieceFeed(tab, query: query, cursor: c),
    toJson: (PieceSummary p) => p.toJson(),
    fromJson: PieceSummary.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<CachedPage<PieceSummary>>> discoverPieces(
    DiscoverPieceKind kind, {
    String? cursor,
  }) => _load<PieceSummary>(
    cacheKey: 'discover:pieces:${kind.wire}',
    cursor: cursor,
    fetch: (String? c) => _remote.discoverPieces(kind, cursor: c),
    toJson: (PieceSummary p) => p.toJson(),
    fromJson: PieceSummary.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<CachedPage<WriterSummary>>> discoverWriters(
    WriterKind kind, {
    String? cursor,
  }) => _load<WriterSummary>(
    cacheKey: 'discover:writers:${kind.wire}',
    cursor: cursor,
    fetch: (String? c) => _remote.discoverWriters(kind, cursor: c),
    toJson: (WriterSummary w) => w.toJson(),
    fromJson: WriterSummary.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<CachedPage<TrendingTag>>> trendingTags({String? cursor}) =>
      _load<TrendingTag>(
        cacheKey: 'discover:tags',
        cursor: cursor,
        fetch: (String? c) => _remote.trendingTags(cursor: c),
        toJson: (TrendingTag t) => t.toJson(),
        fromJson: TrendingTag.fromJson,
        tier: CacheTier.content,
      );

  @override
  Future<Result<CachedPage<TrendingGenre>>> trendingGenres({String? cursor}) =>
      _load<TrendingGenre>(
        cacheKey: 'discover:genres',
        cursor: cursor,
        fetch: (String? c) => _remote.trendingGenres(cursor: c),
        toJson: (TrendingGenre g) => g.toJson(),
        fromJson: TrendingGenre.fromJson,
        tier: CacheTier.content,
      );

  @override
  Future<Result<CachedPage<TrendingLanguage>>> trendingLanguages({
    String? cursor,
  }) => _load<TrendingLanguage>(
    cacheKey: 'discover:languages',
    cursor: cursor,
    fetch: (String? c) => _remote.trendingLanguages(cursor: c),
    toJson: (TrendingLanguage l) => l.toJson(),
    fromJson: TrendingLanguage.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<CachedPage<BookmarkItem>>> bookmarks({String? cursor}) =>
      _load<BookmarkItem>(
        cacheKey: 'bookmarks:list',
        cursor: cursor,
        fetch: (String? c) => _remote.bookmarks(cursor: c),
        toJson: (BookmarkItem b) => b.toJson(),
        fromJson: BookmarkItem.fromJson,
        tier: CacheTier.live,
      );

  /// The shared cache-then-network engine. Page 1 writes the cache and falls back
  /// to it (stale) on failure; later pages are network-only.
  Future<Result<CachedPage<T>>> _load<T>({
    required String cacheKey,
    required String? cursor,
    required Future<CursorPage<T>> Function(String? cursor) fetch,
    required Json Function(T) toJson,
    required T Function(Json) fromJson,
    required CacheTier tier,
  }) async {
    final bool firstPage = cursor == null;
    try {
      final CursorPage<T> page = await fetch(cursor);
      if (firstPage) {
        await _local.writeList<T>(cacheKey, page.items, toJson, tier: tier);
      }
      return Ok<CachedPage<T>>(CachedPage<T>(page: page));
    } on ApiException catch (e) {
      if (firstPage) {
        final CachedList<T>? cached = await _local.readList<T>(
          cacheKey,
          fromJson,
        );
        if (cached != null) {
          return Ok<CachedPage<T>>(
            CachedPage<T>(
              page: CursorPage<T>(
                items: cached.items,
                meta: const CursorMeta(),
              ),
              isStale: true,
            ),
          );
        }
      }
      return Err<CachedPage<T>>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<CachedPage<T>>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }
}

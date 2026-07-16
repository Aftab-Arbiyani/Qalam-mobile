/// Feed repository implementation (docs/40 §16, §23). Both surfaces delegate to
/// the shared cache-then-network engine ([loadCachedPage]) so there is zero
/// duplicated pagination/caching logic (docs/40 §44). Page 1 caches its items and
/// falls back to the cached page (stale) on a network failure (offline reading,
/// docs/40 §23.2); later pages are network-only. All transport errors become
/// domain [Failure]s; no DTO/`DioException`/HTTP status escapes upward.
library;

import '../../../../core/storage/cache_policy.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/data/cache_list_data_source.dart';
import '../../../../shared/data/cached_page_loader.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../../domain/entities/bookmark_item.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../domain/value_objects/feed_query.dart';
import '../datasources/feed_remote_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._remote, this._cache);

  final FeedRemoteDataSource _remote;
  final CacheListDataSource _cache;

  @override
  Future<Result<CachedPage<PieceSummary>>> pieceFeed(
    FeedTab tab, {
    FeedQuery query = FeedQuery.none,
    String? cursor,
  }) => loadCachedPage<PieceSummary>(
    cache: _cache,
    cacheKey: tab.cacheKey,
    cursor: cursor,
    fetch: (String? c) => _remote.pieceFeed(tab, query: query, cursor: c),
    toJson: (PieceSummary p) => p.toJson(),
    fromJson: PieceSummary.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<CachedPage<BookmarkItem>>> bookmarks({String? cursor}) =>
      loadCachedPage<BookmarkItem>(
        cache: _cache,
        cacheKey: 'bookmarks:list',
        cursor: cursor,
        fetch: (String? c) => _remote.bookmarks(cursor: c),
        toJson: (BookmarkItem b) => b.toJson(),
        fromJson: BookmarkItem.fromJson,
        tier: CacheTier.live,
      );
}

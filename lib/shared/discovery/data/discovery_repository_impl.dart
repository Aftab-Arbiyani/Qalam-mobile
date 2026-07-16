/// Discovery repository implementation (docs/40 §16, §23). Every surface delegates
/// to the shared [loadCachedPage] engine — zero duplicated pagination/caching
/// logic. Pieces are the Live tier (they turn over fast); writers and trends are
/// the Content tier. Page-1 failures fall back to the stale cache for offline
/// discovery (docs/40 §23.2).
library;

import '../../../core/storage/cache_policy.dart';
import '../../../core/utils/result.dart';
import '../../data/cache_list_data_source.dart';
import '../../data/cached_page_loader.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/entities/writer_summary.dart';
import '../../domain/enums.dart';
import '../../pagination/cached_page.dart';
import '../domain/discovery_repository.dart';
import 'discovery_remote_data_source.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl(this._remote, this._cache);

  final DiscoveryRemoteDataSource _remote;
  final CacheListDataSource _cache;

  @override
  Future<Result<CachedPage<PieceSummary>>> discoverPieces(
    DiscoverPieceKind kind, {
    String? cursor,
  }) => loadCachedPage<PieceSummary>(
    cache: _cache,
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
  }) => loadCachedPage<WriterSummary>(
    cache: _cache,
    cacheKey: 'discover:writers:${kind.wire}',
    cursor: cursor,
    fetch: (String? c) => _remote.discoverWriters(kind, cursor: c),
    toJson: (WriterSummary w) => w.toJson(),
    fromJson: WriterSummary.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<CachedPage<TrendingTag>>> trendingTags({String? cursor}) =>
      loadCachedPage<TrendingTag>(
        cache: _cache,
        cacheKey: 'discover:tags',
        cursor: cursor,
        fetch: (String? c) => _remote.trendingTags(cursor: c),
        toJson: (TrendingTag t) => t.toJson(),
        fromJson: TrendingTag.fromJson,
        tier: CacheTier.content,
      );

  @override
  Future<Result<CachedPage<TrendingGenre>>> trendingGenres({String? cursor}) =>
      loadCachedPage<TrendingGenre>(
        cache: _cache,
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
  }) => loadCachedPage<TrendingLanguage>(
    cache: _cache,
    cacheKey: 'discover:languages',
    cursor: cursor,
    fetch: (String? c) => _remote.trendingLanguages(cursor: c),
    toJson: (TrendingLanguage l) => l.toJson(),
    fromJson: TrendingLanguage.fromJson,
    tier: CacheTier.content,
  );
}

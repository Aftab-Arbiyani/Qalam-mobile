/// Analytics repository (docs/40 §17.2) — translates the remote data source's
/// [ApiException]s to domain [Failure]s and adds OFFLINE TOLERANCE: every read
/// writes a fresh cache mirror, and a transport failure serves the last cached
/// aggregate instead of an error so the dashboard still paints when the wire is
/// down. Growth series are keyed by (period, points) so switching the range never
/// serves a stale window.
library;

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/growth_series.dart';
import '../../domain/entities/piece_analytics.dart';
import '../../domain/entities/reader_analytics.dart';
import '../../domain/entities/writer_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._remote, this._cache);

  final AnalyticsRemoteDataSource _remote;
  final CacheStore _cache;

  static const String _writerKey = 'analytics:writer';
  static const String _readerKey = 'analytics:reader';
  String _growthKey(String period, int points) =>
      'analytics:growth:$period:$points';
  String _pieceKey(String id) => 'analytics:piece:$id';

  @override
  Future<Result<WriterAnalytics>> writerAnalytics() => _cachedFetch<WriterAnalytics>(
    cacheKey: _writerKey,
    fetch: _remote.writerAnalytics,
    fromCache: WriterAnalytics.fromJson,
    toJson: (WriterAnalytics v) => v.toJson(),
  );

  @override
  Future<Result<GrowthSeries>> writerGrowth({
    required String period,
    required int points,
  }) => _cachedFetch<GrowthSeries>(
    cacheKey: _growthKey(period, points),
    fetch: () => _remote.writerGrowth(period: period, points: points),
    fromCache: GrowthSeries.fromJson,
    toJson: (GrowthSeries v) => v.toJson(),
  );

  @override
  Future<Result<ReaderAnalytics>> readerAnalytics() => _cachedFetch<ReaderAnalytics>(
    cacheKey: _readerKey,
    fetch: _remote.readerAnalytics,
    fromCache: ReaderAnalytics.fromJson,
    toJson: (ReaderAnalytics v) => v.toJson(),
  );

  @override
  Future<Result<PieceAnalytics>> pieceAnalytics(String pieceId) =>
      _cachedFetch<PieceAnalytics>(
        cacheKey: _pieceKey(pieceId),
        fetch: () => _remote.pieceAnalytics(pieceId),
        fromCache: PieceAnalytics.fromJson,
        toJson: (PieceAnalytics v) => v.toJson(),
      );

  /// Fetch from the wire, mirror to cache, and on a TRANSPORT failure fall back to
  /// a non-expired cached copy so the surface degrades gracefully offline.
  Future<Result<T>> _cachedFetch<T>({
    required String cacheKey,
    required Future<T> Function() fetch,
    required T Function(Json) fromCache,
    required Json Function(T) toJson,
  }) async {
    try {
      final T value = await fetch();
      await _cache.write(cacheKey, toJson(value), tier: CacheTier.content);
      return Ok<T>(value);
    } on ApiException catch (e) {
      final Failure failure = mapApiExceptionToFailure(e);
      if (failure is NetworkFailure) {
        final CacheEntry? entry = await _cache.read(cacheKey);
        if (entry != null && !entry.isExpired(DateTime.now())) {
          try {
            return Ok<T>(fromCache(entry.value));
          } on Object {
            // Stale/incompatible cache shape — fall through to the failure.
          }
        }
      }
      return Err<T>(failure);
    }
  }
}

/// Piece local data source (docs/40 §17.2, §25) — the only place the reading
/// feature touches the Hive cache. Caches single objects (piece detail, engagement
/// snapshot, writer profile) keyed by data-shaped keys so opened pieces read back
/// instantly and offline (docs/40 §23, §36). Generic over the entity's own codec.
library;

import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/utils/typedefs.dart';

/// A cached object plus whether it is past its freshness tier.
typedef CachedObject<T> = ({T value, bool isStale});

class PieceLocalDataSource {
  PieceLocalDataSource(this._cache);

  final CacheStore _cache;

  static String pieceKey(String id) => 'pieces:detail:$id';
  static String engagementKey(String id) => 'pieces:engagement:$id';
  static String profileKey(String username) => 'profiles:detail:$username';

  Future<CachedObject<T>?> read<T>(
    String key,
    T Function(Json) fromJson,
  ) async {
    final CacheEntry? entry = await _cache.read(key);
    if (entry == null) return null;
    final DateTime now = DateTime.now();
    if (entry.isExpired(now)) {
      await _cache.evict(key);
      return null;
    }
    return (value: fromJson(entry.value), isStale: entry.isStale(now));
  }

  Future<void> write<T>(
    String key,
    T value,
    Json Function(T) toJson, {
    required CacheTier tier,
  }) => _cache.write(key, toJson(value), tier: tier);
}

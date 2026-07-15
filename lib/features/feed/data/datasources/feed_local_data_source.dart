/// Feed local data source (docs/40 §17.2, §25) — the only place the feed feature
/// touches the Hive cache. Caches the FIRST page of each feed/discovery surface
/// (cursors are opaque and never cached, docs/40 §25.4) so a cold or offline start
/// paints instantly. Generic over the item type; the caller supplies the entity's
/// own JSON codec (cache round-trips the ENTITY shape, not the wire shape).
library;

import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/utils/typedefs.dart';

/// A cached list plus whether it is past its freshness tier.
typedef CachedList<T> = ({List<T> items, bool isStale});

class FeedLocalDataSource {
  FeedLocalDataSource(this._cache);

  final CacheStore _cache;

  /// Read a cached list, or null if absent/hard-expired (expired entries are
  /// evicted). [isStale] reflects the entry's freshness tier for the offline UX.
  Future<CachedList<T>?> readList<T>(
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
    final Object? raw = entry.value['items'];
    if (raw is! List) return null;
    final List<T> items = raw
        .whereType<Map<dynamic, dynamic>>()
        .map(Json.from)
        .map(fromJson)
        .toList(growable: false);
    return (items: items, isStale: entry.isStale(now));
  }

  Future<void> writeList<T>(
    String key,
    List<T> items,
    Json Function(T) toJson, {
    required CacheTier tier,
  }) => _cache.write(key, <String, dynamic>{
    'items': items.map(toJson).toList(growable: false),
  }, tier: tier);
}

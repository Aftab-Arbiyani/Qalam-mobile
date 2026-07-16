/// Shared list cache (docs/40 §17.2, §25) — the one place any feature's data
/// layer round-trips a cursor-page's FIRST page through the Hive cache. Cursors
/// are opaque and never cached (docs/40 §25.4), so only page one is stored, which
/// is what a cold or offline start needs to paint instantly. Generic over the
/// item type; the caller supplies the entity's own JSON codec (the cache stores
/// the ENTITY shape, not the wire shape). Reused by feed, discovery, and search
/// — never re-implemented per feature (docs/40 §7.3).
library;

import '../../core/storage/cache_policy.dart';
import '../../core/storage/cache_store.dart';
import '../../core/utils/typedefs.dart';

/// A cached list plus whether it is past its freshness tier.
typedef CachedList<T> = ({List<T> items, bool isStale});

class CacheListDataSource {
  CacheListDataSource(this._cache);

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
    try {
      final List<T> items = raw
          .whereType<Map<dynamic, dynamic>>()
          .map(Json.from)
          .map(fromJson)
          .toList(growable: false);
      return (items: items, isStale: entry.isStale(now));
    } on Object {
      // Schema drift — an entry written by an older app version may no longer
      // decode. A cache is disposable: evict it instead of throwing.
      await _cache.evict(key);
      return null;
    }
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

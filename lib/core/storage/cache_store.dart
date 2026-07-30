/// Cache abstraction (docs/40 §25) — a read mirror of server state, NOT a source
/// of truth. Repositories use it for cache-then-network reads and offline
/// tolerance. Keyed by data-shaped keys (mirrors the web query-key factory).
///
/// The interface keeps repositories independent of Hive; [HiveCacheStore] is the
/// M1 implementation and is swappable in tests.
library;

import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../utils/typedefs.dart';
import 'cache_policy.dart';

/// A cached value plus the metadata needed to reason about its freshness.
class CacheEntry {
  const CacheEntry({
    required this.value,
    required this.writtenAt,
    required this.tier,
  });

  final Json value;
  final DateTime writtenAt;
  final CacheTier tier;

  bool isStale(DateTime now) => now.difference(writtenAt) > tier.ttl;
  bool isExpired(DateTime now) => now.difference(writtenAt) > tier.hardExpiry;
}

abstract interface class CacheStore {
  Future<CacheEntry?> read(String key);
  Future<void> write(String key, Json value, {required CacheTier tier});
  Future<void> evict(String key);
  Future<void> clear();
}

class HiveCacheStore implements CacheStore {
  HiveCacheStore(this._box);

  final Box<dynamic> _box;

  @override
  Future<CacheEntry?> read(String key) async {
    final Object? raw = _box.get(key);
    if (raw is! Map) return null;
    final Map<dynamic, dynamic> record = raw;
    final int? writtenMs = record['w'] as int?;
    final String? valueJson = record['v'] as String?;
    final String? tierName = record['t'] as String?;
    if (writtenMs == null || valueJson == null || tierName == null) return null;

    final CacheTier tier = CacheTier.values.firstWhere(
      (CacheTier t) => t.name == tierName,
      orElse: () => CacheTier.content,
    );
    return CacheEntry(
      value: Json.from(jsonDecode(valueJson) as Map<dynamic, dynamic>),
      writtenAt: DateTime.fromMillisecondsSinceEpoch(writtenMs, isUtc: true),
      tier: tier,
    );
  }

  @override
  Future<void> write(String key, Json value, {required CacheTier tier}) {
    return _box.put(key, <String, Object?>{
      'w': DateTime.now().toUtc().millisecondsSinceEpoch,
      't': tier.name,
      'v': jsonEncode(value),
    });
  }

  @override
  Future<void> evict(String key) => _box.delete(key);

  @override
  Future<void> clear() => _box.clear();
}

/// Cache manager (docs/40 §25, §26, §37) — the one place that reasons about local
/// storage as a whole: how much each Hive box holds, how many cache entries have
/// expired, and the two maintenance actions the UI exposes — evict expired entries
/// (automatic cleanup) and clear the disposable cache (manual refresh). It NEVER
/// touches the durable user boxes' contents (reading history, offline drafts, the
/// sync outbox) — those are the user's own data and are only measured, never wiped.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import 'cache_policy.dart';

/// Approximate on-disk usage for one Hive box.
class BoxUsage {
  const BoxUsage({
    required this.name,
    required this.label,
    required this.entries,
    required this.approxBytes,
    required this.clearable,
  });

  final String name;
  final String label;
  final int entries;
  final int approxBytes;

  /// Whether this box is disposable TTL cache (safe to clear) vs. user data.
  final bool clearable;
}

/// A snapshot of local storage for the cache-management surface.
class CacheStats {
  const CacheStats({
    required this.boxes,
    required this.totalBytes,
    required this.cacheEntries,
    required this.expiredEntries,
  });

  final List<BoxUsage> boxes;
  final int totalBytes;
  final int cacheEntries;
  final int expiredEntries;

  static const CacheStats empty = CacheStats(
    boxes: <BoxUsage>[],
    totalBytes: 0,
    cacheEntries: 0,
    expiredEntries: 0,
  );
}

class CacheManager {
  CacheManager({
    required Box<dynamic> cacheBox,
    required Box<dynamic> prefsBox,
    required Box<dynamic> readingBox,
    required Box<dynamic> draftsBox,
  }) : _cache = cacheBox,
       _prefs = prefsBox,
       _reading = readingBox,
       _drafts = draftsBox;

  final Box<dynamic> _cache;
  final Box<dynamic> _prefs;
  final Box<dynamic> _reading;
  final Box<dynamic> _drafts;

  /// Measure every box + how many cache entries have hard-expired.
  CacheStats stats({DateTime? now}) {
    final DateTime at = now ?? DateTime.now();
    int expired = 0;
    for (final dynamic key in _cache.keys) {
      if (_isExpired(_cache.get(key), at)) expired++;
    }
    final List<BoxUsage> boxes = <BoxUsage>[
      _usage(_cache, 'Cached content', clearable: true),
      _usage(_reading, 'Reading history', clearable: false),
      _usage(_drafts, 'Offline drafts', clearable: false),
      _usage(_prefs, 'Preferences & queue', clearable: false),
    ];
    final int total = boxes.fold<int>(0, (int s, BoxUsage b) => s + b.approxBytes);
    return CacheStats(
      boxes: boxes,
      totalBytes: total,
      cacheEntries: _cache.length,
      expiredEntries: expired,
    );
  }

  /// Evict every hard-expired cache entry. Returns the number removed. Cheap:
  /// a single pass over the disposable cache box only.
  Future<int> cleanupExpired({DateTime? now}) async {
    final DateTime at = now ?? DateTime.now();
    final List<dynamic> stale = <dynamic>[
      for (final dynamic key in _cache.keys)
        if (_isExpired(_cache.get(key), at)) key,
    ];
    for (final dynamic key in stale) {
      await _cache.delete(key);
    }
    return stale.length;
  }

  /// Clear the entire disposable cache (manual refresh). User data is untouched.
  Future<void> clearCache() => _cache.clear();

  BoxUsage _usage(Box<dynamic> box, String label, {required bool clearable}) {
    int bytes = 0;
    for (final dynamic key in box.keys) {
      bytes += _approxBytes(box.get(key));
    }
    return BoxUsage(
      name: box.name,
      label: label,
      entries: box.length,
      approxBytes: bytes,
      clearable: clearable,
    );
  }

  /// A best-effort byte estimate for a stored value (JSON string or map).
  int _approxBytes(Object? value) {
    if (value == null) return 0;
    if (value is String) return value.length;
    try {
      return jsonEncode(value).length;
    } on Object {
      return value.toString().length;
    }
  }

  /// A cache record is `{w: writtenMs, t: tierName, v: json}` — hard-expired when
  /// older than the tier's hard-expiry multiple (docs/40 §25.2).
  bool _isExpired(Object? record, DateTime now) {
    if (record is! Map) return false;
    final int? writtenMs = record['w'] as int?;
    final String? tierName = record['t'] as String?;
    if (writtenMs == null || tierName == null) return false;
    final CacheTier tier = CacheTier.values.firstWhere(
      (CacheTier t) => t.name == tierName,
      orElse: () => CacheTier.content,
    );
    final DateTime writtenAt = DateTime.fromMillisecondsSinceEpoch(
      writtenMs,
      isUtc: true,
    );
    return now.difference(writtenAt) > tier.hardExpiry;
  }
}

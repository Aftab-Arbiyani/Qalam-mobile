import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/core/storage/cache_manager.dart';
import 'package:qalam_mobile/core/storage/cache_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late Box<dynamic> cache;
  late Box<dynamic> prefs;
  late Box<dynamic> reading;
  late Box<dynamic> drafts;
  late CacheManager manager;

  final DateTime now = DateTime.utc(2026, 7, 17, 12);

  Map<String, Object?> record(DateTime writtenAt, {CacheTier tier = CacheTier.content}) =>
      <String, Object?>{
        'w': writtenAt.millisecondsSinceEpoch,
        't': tier.name,
        'v': '{"payload":"x"}',
      };

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('cache_mgr');
    Hive.init(dir.path);
    final String s = dir.path.hashCode.toRadixString(16);
    cache = await Hive.openBox<dynamic>('cache_$s');
    prefs = await Hive.openBox<dynamic>('prefs_$s');
    reading = await Hive.openBox<dynamic>('reading_$s');
    drafts = await Hive.openBox<dynamic>('drafts_$s');

    // One fresh, one hard-expired (content hard-expiry is 5min*24 = 2h).
    await cache.put('fresh', record(now.subtract(const Duration(minutes: 1))));
    await cache.put('stale', record(now.subtract(const Duration(hours: 5))));
    await reading.put('h:p1', '{"pieceId":"p1"}');
    await drafts.put('d:1', '{"localId":"1"}');

    manager = CacheManager(
      cacheBox: cache,
      prefsBox: prefs,
      readingBox: reading,
      draftsBox: drafts,
    );
  });

  tearDown(() async {
    for (final Box<dynamic> b in <Box<dynamic>>[cache, prefs, reading, drafts]) {
      await b.deleteFromDisk();
    }
    await dir.delete(recursive: true);
  });

  test('stats count entries, expired items, and mark cache clearable', () {
    final CacheStats stats = manager.stats(now: now);
    expect(stats.cacheEntries, 2);
    expect(stats.expiredEntries, 1);
    expect(stats.totalBytes, greaterThan(0));

    final BoxUsage cacheUsage =
        stats.boxes.firstWhere((BoxUsage b) => b.label == 'Cached content');
    expect(cacheUsage.clearable, isTrue);
    final BoxUsage readingUsage =
        stats.boxes.firstWhere((BoxUsage b) => b.label == 'Reading history');
    expect(readingUsage.clearable, isFalse);
    expect(readingUsage.entries, 1);
  });

  test('cleanupExpired removes only hard-expired entries', () async {
    final int removed = await manager.cleanupExpired(now: now);
    expect(removed, 1);
    expect(cache.containsKey('fresh'), isTrue);
    expect(cache.containsKey('stale'), isFalse);
  });

  test('clearCache empties the cache but keeps user data', () async {
    await manager.clearCache();
    expect(cache.isEmpty, isTrue);
    expect(reading.isNotEmpty, isTrue);
    expect(drafts.isNotEmpty, isTrue);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/core/storage/cache_policy.dart';
import 'package:qalam_mobile/core/storage/cache_store.dart';

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late HiveCacheStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qalam_cache_test');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>(
      'cache_${dir.path.hashCode.toRadixString(16)}',
    );
    store = HiveCacheStore(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('write then read round-trips the value + tier', () async {
    await store.write('feed:list', <String, dynamic>{
      'a': 1,
    }, tier: CacheTier.live);
    final CacheEntry? entry = await store.read('feed:list');
    expect(entry, isNotNull);
    expect(entry!.value['a'], 1);
    expect(entry.tier, CacheTier.live);
  });

  test('missing key returns null', () async {
    expect(await store.read('nope'), isNull);
  });

  test('staleness follows the tier TTL', () async {
    await store.write('k', <String, dynamic>{'x': true}, tier: CacheTier.live);
    final CacheEntry entry = (await store.read('k'))!;
    final DateTime now = entry.writtenAt;
    expect(entry.isStale(now.add(const Duration(seconds: 10))), isFalse);
    expect(entry.isStale(now.add(const Duration(seconds: 31))), isTrue);
  });

  test('evict removes one key; clear removes all', () async {
    await store.write('a', <String, dynamic>{'v': 1}, tier: CacheTier.content);
    await store.write('b', <String, dynamic>{'v': 2}, tier: CacheTier.content);
    await store.evict('a');
    expect(await store.read('a'), isNull);
    expect(await store.read('b'), isNotNull);
    await store.clear();
    expect(await store.read('b'), isNull);
  });
}

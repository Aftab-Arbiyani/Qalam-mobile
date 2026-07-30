import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/features/search/data/datasources/search_recents_store.dart';
import 'package:qalam_mobile/features/search/domain/entities/recent_search.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

RecentSearch _entry(String q, {SearchType type = SearchType.all, int day = 1}) =>
    RecentSearch(query: q, searchType: type, searchedAt: DateTime.utc(2026, 1, day));

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late SearchRecentsStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qalam_recents');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('prefs_${dir.path.hashCode}');
    store = SearchRecentsStore(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('add prepends newest-first and dedupes by query+scope', () async {
    await store.add(_entry('alpha'));
    await store.add(_entry('beta'));
    final List<RecentSearch> after = await store.add(_entry('alpha', day: 2));
    expect(after.map((RecentSearch e) => e.query), <String>['alpha', 'beta']);
    expect(after.length, 2); // 'alpha' moved to top, not duplicated.
  });

  test('caps history at 20 entries', () async {
    for (int i = 0; i < 25; i++) {
      await store.add(_entry('q$i'));
    }
    expect(store.readAll().length, 20);
    // Newest (q24) retained; oldest (q0) evicted.
    expect(store.readAll().first.query, 'q24');
    expect(store.readAll().any((RecentSearch e) => e.query == 'q0'), isFalse);
  });

  test('remove drops one by key; clear empties', () async {
    await store.add(_entry('alpha'));
    await store.add(_entry('beta'));
    final after = await store.remove(_entry('alpha').key);
    expect(after.map((RecentSearch e) => e.query), <String>['beta']);
    await store.clear();
    expect(store.readAll(), isEmpty);
  });

  test('replaceAll dedupes keeping first occurrence and caps', () async {
    final result = await store.replaceAll(<RecentSearch>[
      _entry('a'),
      _entry('b'),
      _entry('a', day: 5), // duplicate key — dropped.
    ]);
    expect(result.map((RecentSearch e) => e.query), <String>['a', 'b']);
  });

  test('survives a reopen (persisted as JSON)', () async {
    await store.add(_entry('kept'));
    final SearchRecentsStore reopened = SearchRecentsStore(box);
    expect(reopened.readAll().single.query, 'kept');
  });
}

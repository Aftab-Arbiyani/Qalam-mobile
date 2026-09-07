/// The device-local stores behind retrieval and Story Map.
///
/// **M2 deleted `AiSearchHistoryStore` and its test.** It held recent semantic-search
/// queries for the screen D5 removed — and `features/search` already keeps recents of
/// its own, in `SearchRecentsStore`, shown on the same landing. Two histories of the
/// same searches, one of them unreachable, was the duplication the merge existed to
/// end.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/features/ai/data/local/explorer_cache_store.dart';
import 'package:qalam_mobile/features/ai/domain/entities/story_graph.dart';
import 'package:qalam_mobile/shared/retrieval/data/saved_searches_store.dart';
import 'package:qalam_mobile/shared/retrieval/domain/saved_search.dart';

void main() {
  late Box<dynamic> box;

  setUpAll(() async {
    Hive.init(
      '${Directory.systemTemp.path}/qalam_af4_stores_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  setUp(() async {
    box = await Hive.openBox<dynamic>(
      'af4_test_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  test(
    'SavedSearchesStore: replaceAll dedupes by key, readAll round-trips',
    () async {
      final SavedSearchesStore store = SavedSearchesStore(box);
      final SavedSearch a = SavedSearch(
        id: '1',
        name: 'Villains',
        query: 'antagonist',
        queryType: null,
        storyId: 'piece-1',
        createdAt: DateTime.utc(2026),
      );
      final SavedSearch dup = SavedSearch(
        id: '2',
        name: 'villains', // same key (case-insensitive)
        query: 'other',
        queryType: null,
        storyId: null,
        createdAt: DateTime.utc(2026),
      );
      await store.replaceAll(<SavedSearch>[a, dup]);
      final List<SavedSearch> all = store.readAll();
      expect(all, hasLength(1));
      expect(all.first.query, 'antagonist'); // first wins
    },
  );

  test('ExplorerCacheStore: writes + reads a view; misses cleanly', () async {
    final ExplorerCacheStore store = ExplorerCacheStore(box);
    expect(store.read('piece-1', 'characters'), isNull);
    await store.write(
      const ExplorerViewResult(
        storyId: 'piece-1',
        view: 'characters',
        nodes: <StoryGraphNode>[],
        edges: <StoryGraphEdge>[],
        nodeCount: 0,
        edgeCount: 0,
      ),
    );
    expect(store.read('piece-1', 'characters')?.storyId, 'piece-1');
    expect(store.read('piece-1', 'timeline'), isNull);
  });
}

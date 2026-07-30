import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/search/domain/entities/global_search_result.dart';
import 'package:qalam_mobile/features/search/domain/value_objects/search_request.dart';
import 'package:qalam_mobile/features/search/presentation/controllers/recent_searches_controller.dart';
import 'package:qalam_mobile/features/search/presentation/controllers/search_controller.dart';
import 'package:qalam_mobile/features/search/presentation/controllers/search_results_controller.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/domain/entities/writer_summary.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

import '../../support/fake_search_repository.dart';
import '../../support/harness.dart';

PieceSummary _piece(String id) => PieceSummary(
  id: id,
  title: id,
  author: const Author(username: 'a'),
  language: const LanguageRef(code: 'en'),
);

void main() {
  group('SearchQueryController', () {
    test('submit sets the submitted query, results phase, and records a recent',
        () async {
      final ProviderContainer c = await buildTestContainer(
        searchRepository: FakeSearchRepository(),
      );
      addTearDown(c.dispose);
      c.listen(searchQueryControllerProvider, (_, _) {});
      c.listen(recentSearchesControllerProvider, (_, _) {});

      c.read(searchQueryControllerProvider.notifier).submit('barish');
      final SearchState state = c.read(searchQueryControllerProvider);
      expect(state.submittedQuery, 'barish');
      expect(state.phase, SearchPhase.results);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(
        c.read(recentSearchesControllerProvider).map((r) => r.query),
        contains('barish'),
      );
    });

    test('submit is rejected below the minimum query length', () async {
      final ProviderContainer c = await buildTestContainer(
        searchRepository: FakeSearchRepository(),
      );
      addTearDown(c.dispose);
      c.listen(searchQueryControllerProvider, (_, _) {});
      c.read(searchQueryControllerProvider.notifier).submit('a');
      expect(c.read(searchQueryControllerProvider).hasSubmitted, isFalse);
    });

    test('onQueryChanged sets the debounced query after the window', () async {
      final ProviderContainer c = await buildTestContainer(
        searchRepository: FakeSearchRepository(),
      );
      addTearDown(c.dispose);
      c.listen(searchQueryControllerProvider, (_, _) {});
      c.read(searchQueryControllerProvider.notifier).onQueryChanged('ba');
      expect(c.read(searchQueryControllerProvider).debouncedQuery, '');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(c.read(searchQueryControllerProvider).debouncedQuery, 'ba');
    });

    test('clear returns to the discovery phase', () async {
      final ProviderContainer c = await buildTestContainer(
        searchRepository: FakeSearchRepository(),
      );
      addTearDown(c.dispose);
      c.listen(searchQueryControllerProvider, (_, _) {});
      c.listen(recentSearchesControllerProvider, (_, _) {});
      c.read(searchQueryControllerProvider.notifier).submit('barish');
      c.read(searchQueryControllerProvider.notifier).clear();
      expect(c.read(searchQueryControllerProvider).phase, SearchPhase.discovery);
      // Let the fire-and-forget recents write settle before teardown.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  });

  group('SearchResultsController', () {
    test('first page returns seeded items; loadMore appends', () async {
      final ProviderContainer c = await buildTestContainer(
        searchRepository: FakeSearchRepository(
          pieces: <PieceSummary>[_piece('a'), _piece('b')],
          hasMore: true,
          nextCursor: 'c2',
        ),
      );
      addTearDown(c.dispose);
      const SearchRequest request = SearchRequest(
        query: 'barish',
        type: SearchType.pieces,
      );
      final provider = searchResultsControllerProvider(request);
      final first = await c.read(provider.future);
      expect(first.items.length, 2);
      expect(first.hasMore, isTrue);

      await c.read(provider.notifier).loadMore();
      expect(c.read(provider).asData!.value.items.length, 4);
    });

    test('writer results widen to Object and stay typed', () async {
      final ProviderContainer c = await buildTestContainer(
        searchRepository: FakeSearchRepository(
          writers: <WriterSummary>[const WriterSummary(username: 'meera_k')],
        ),
      );
      addTearDown(c.dispose);
      const SearchRequest request = SearchRequest(
        query: 'meera',
        type: SearchType.writers,
      );
      final first = await c.read(searchResultsControllerProvider(request).future);
      expect(first.items.single, isA<WriterSummary>());
    });
  });

  group('globalSearch provider', () {
    test('returns the seeded grouped preview', () async {
      final ProviderContainer c = await buildTestContainer(
        searchRepository: FakeSearchRepository(
          global: GlobalSearchResult(pieces: <PieceSummary>[_piece('g')]),
        ),
      );
      addTearDown(c.dispose);
      final result = await c.read(globalSearchProvider('barish').future);
      expect(result.pieces.single.id, 'g');
    });

    test('an empty query short-circuits to an empty preview', () async {
      final ProviderContainer c = await buildTestContainer(
        searchRepository: FakeSearchRepository(),
      );
      addTearDown(c.dispose);
      final result = await c.read(globalSearchProvider('').future);
      expect(result.isEmpty, isTrue);
    });
  });
}

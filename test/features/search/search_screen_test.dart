/// The search screen end to end (**D5**, M2).
///
/// The engine behind the "All" tab changed: it was the grouped E8 preview, it is the
/// ranked retrieval one now. So this file arranges a `FakeRetrievalRepository` where it
/// used to arrange a grouped `GlobalSearchResult` — the surface is the same, what it
/// runs is not.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/search/domain/entities/autocomplete_result.dart';
import 'package:qalam_mobile/features/search/domain/entities/trending_searches.dart';
import 'package:qalam_mobile/features/search/search.dart';
import 'package:qalam_mobile/shared/retrieval/domain/retrieval.dart';
import 'package:qalam_mobile/shared/widgets/inputs/q_search_field.dart';

import '../../support/fake_feed_repository.dart';
import '../../support/fake_retrieval_repository.dart';
import '../../support/fake_search_repository.dart';
import '../../support/harness.dart';

Future<void> _openSearch(
  WidgetTester tester,
  FakeSearchRepository search, {
  FakeRetrievalRepository? retrieval,
}) async {
  await pumpTestApp(
    tester,
    feedRepository: FakeFeedRepository(),
    discoveryRepository: FakeDiscoveryRepository(),
    searchRepository: search,
    retrievalRepository: retrieval ?? FakeRetrievalRepository(),
  );
  await tester.tap(find.text('Search'));
  await settleFrames(tester);
}

SemanticSearchResponse _ranked(String title) => SemanticSearchResponse(
  query: 'barish',
  intent: 'search',
  queryType: 'natural_language',
  results: <SearchResultItem>[
    SearchResultItem(
      id: 'p1',
      type: 'piece',
      sourceType: 'keyword',
      title: title,
      summary: 'A poem about rain.',
      object: const <String, dynamic>{},
      confidence: 0.9,
      relevanceScore: 0.92,
      reason: 'Shares the tag "barish"',
      ranking: const RankingExplanation(
        score: 0.92,
        summary: 'keyword match',
        signals: <RankingSignalContribution>[],
      ),
      relatedEntities: const <RelatedEntity>[],
      evidence: const <RetrievalEvidence>[],
      navigation: const NavigationTarget(kind: 'piece', ref: 'p1'),
    ),
  ],
  evidence: const <RetrievalEvidence>[],
  meta: const RetrievalResponseMeta(
    sources: <String>['keyword'],
    totalCandidates: 1,
    returned: 1,
    confidence: 0.9,
    degraded: false,
  ),
);

void main() {
  testWidgets('discovery landing shows a trending search chip', (
    WidgetTester tester,
  ) async {
    await _openSearch(
      tester,
      FakeSearchRepository(
        trendingResult: const TrendingSearches(
          keywords: <TrendingKeyword>[
            TrendingKeyword(keyword: 'barish', searchCount: 9),
          ],
        ),
      ),
    );
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('barish'), findsOneWidget);
  });

  testWidgets('typing a query surfaces autocomplete suggestions', (
    WidgetTester tester,
  ) async {
    await _openSearch(
      tester,
      FakeSearchRepository(
        autocompleteResult: const AutocompleteResult(
          tags: <TagSuggestion>[TagSuggestion(slug: 'ishq', name: 'ishq')],
        ),
      ),
    );
    await tester.enterText(find.byType(QSearchField), 'ishq');
    await settleFrames(tester); // clears the 300ms debounce window
    expect(find.byIcon(Icons.tag), findsWidgets);
  });

  testWidgets('submitting a query shows ranked, grounded results', (
    WidgetTester tester,
  ) async {
    final FakeRetrievalRepository retrieval = FakeRetrievalRepository(
      search: _ranked('Barish'),
    );
    await _openSearch(tester, FakeSearchRepository(), retrieval: retrieval);
    await tester.enterText(find.byType(QSearchField), 'barish');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await settleFrames(tester);

    expect(find.text('Barish'), findsOneWidget);
    // Grounded: the ranker's own reason rides along, so the reader can see why this
    // surfaced rather than being asked to trust the ordering.
    expect(find.textContaining('Shares the tag'), findsOneWidget);
    expect(retrieval.lastSearchRequest?.query, 'barish');
  });

  testWidgets('offline still renders the search surface gracefully', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      online: false,
      feedRepository: FakeFeedRepository(),
      discoveryRepository: FakeDiscoveryRepository(),
      searchRepository: FakeSearchRepository(),
    );
    await tester.tap(find.text('Search'));
    await settleFrames(tester);
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.textContaining('offline'), findsWidgets);
  });
}

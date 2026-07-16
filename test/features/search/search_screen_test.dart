import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/search/domain/entities/autocomplete_result.dart';
import 'package:qalam_mobile/features/search/domain/entities/global_search_result.dart';
import 'package:qalam_mobile/features/search/domain/entities/trending_searches.dart';
import 'package:qalam_mobile/features/search/search.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/widgets/content/piece_card.dart';
import 'package:qalam_mobile/shared/widgets/inputs/q_search_field.dart';

import '../../support/fake_feed_repository.dart';
import '../../support/fake_search_repository.dart';
import '../../support/harness.dart';

PieceSummary _piece(String id) => PieceSummary(
  id: id,
  title: 'Piece $id',
  author: const Author(username: 'a'),
  language: const LanguageRef(code: 'en'),
);

Future<void> _openSearch(WidgetTester tester, FakeSearchRepository search) async {
  await pumpTestApp(
    tester,
    feedRepository: FakeFeedRepository(),
    discoveryRepository: FakeDiscoveryRepository(),
    searchRepository: search,
  );
  await tester.tap(find.text('Search'));
  await settleFrames(tester);
}

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

  testWidgets('submitting a query shows grouped piece results', (
    WidgetTester tester,
  ) async {
    await _openSearch(
      tester,
      FakeSearchRepository(
        global: GlobalSearchResult(pieces: <PieceSummary>[_piece('a')]),
      ),
    );
    await tester.enterText(find.byType(QSearchField), 'barish');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await settleFrames(tester);
    expect(find.byType(PieceCard), findsOneWidget);
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

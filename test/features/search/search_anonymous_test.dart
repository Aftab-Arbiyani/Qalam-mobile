/// Search, signed out (**D5**, M2).
///
/// **This is the file that would have caught the defect the equivalent web change
/// shipped** (`platfrom/docs/48` §3.25). There, a feature flag had been *incidentally*
/// keeping authenticated reads off a public page; removing the flag — the correct
/// change — fired those reads for anonymous visitors, and a 401 outside `/auth/*` is
/// terminal to the api client: it ends the session and clears the caches. The symptom
/// was a page that stopped rendering, nowhere near the cause.
///
/// Mobile's version of that trap is sharper still, because `AiFeatures.isEnabled`
/// answers **false for a flag it cannot find**. So this asserts three things, in
/// descending order of what they would cost to get wrong:
///
/// 1. **`aiFeaturesProvider` is never read.** Arranged with an override that *throws* —
///    a render-only check cannot see the difference between "not shown" and "requested
///    and failed", which is precisely how the web version passed its tests.
/// 2. The authenticated retrieval calls are never made.
/// 3. The controls that need a session are absent rather than merely inert.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/session/session_controller.dart';
import 'package:qalam_mobile/core/session/session_state.dart';
import 'package:qalam_mobile/features/ai/presentation/providers/ai_providers.dart';
import 'package:qalam_mobile/features/search/search.dart';
import 'package:qalam_mobile/shared/retrieval/domain/retrieval.dart';
import 'package:qalam_mobile/shared/widgets/inputs/q_search_field.dart';

import '../../support/fake_feed_repository.dart';
import '../../support/fake_retrieval_repository.dart';
import '../../support/fake_search_repository.dart';
import '../../support/harness.dart';

class _AnonSession extends SessionController {
  @override
  Future<SessionState> build() async => const SessionState.anonymous();
}

SemanticSearchResponse _ranked() => const SemanticSearchResponse(
  query: 'barish',
  intent: 'search',
  queryType: 'natural_language',
  results: <SearchResultItem>[
    SearchResultItem(
      id: 'p1',
      type: 'piece',
      sourceType: 'keyword',
      title: 'Barish',
      summary: 'A poem about rain.',
      object: <String, dynamic>{},
      confidence: 0.9,
      relevanceScore: 0.92,
      reason: 'Shares the tag "barish"',
      ranking: RankingExplanation(
        score: 0.92,
        summary: 'keyword match',
        signals: <RankingSignalContribution>[],
      ),
      relatedEntities: <RelatedEntity>[],
      evidence: <RetrievalEvidence>[],
      navigation: NavigationTarget(kind: 'piece', ref: 'p1'),
    ),
  ],
  evidence: <RetrievalEvidence>[],
  meta: RetrievalResponseMeta(
    sources: <String>['keyword'],
    totalCandidates: 1,
    returned: 1,
    confidence: 0.9,
    degraded: false,
  ),
);

Future<FakeRetrievalRepository> _openSearch(WidgetTester tester) async {
  final FakeRetrievalRepository retrieval = FakeRetrievalRepository(
    search: _ranked(),
  );
  await pumpTestApp(
    tester,
    feedRepository: FakeFeedRepository(),
    discoveryRepository: FakeDiscoveryRepository(),
    searchRepository: FakeSearchRepository(),
    retrievalRepository: retrieval,
    sessionOverride: _AnonSession.new,
    // ⚠️ The load-bearing arrangement. Anything on this surface that reaches for the
    // AI feature flags fails the test loudly instead of silently 401ing in production.
    extraOverrides: <dynamic>[
      aiFeaturesProvider.overrideWith(
        (_) async => throw StateError(
          'search must not read GET /ai/features — it is authenticated, search is '
          'public, and a 401 outside /auth ends the reader’s session',
        ),
      ),
    ],
  );
  await tester.tap(find.text('Search'));
  await settleFrames(tester);
  return retrieval;
}

void main() {
  testWidgets('an anonymous reader gets ranked results, with no sign-in wall', (
    WidgetTester tester,
  ) async {
    final FakeRetrievalRepository retrieval = await _openSearch(tester);

    await tester.enterText(find.byType(QSearchField), 'barish');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await settleFrames(tester);

    expect(find.text('Barish'), findsOneWidget);
    expect(retrieval.searchCalls, 1);
    // The search itself is public; nothing that needs a session was touched.
    expect(retrieval.listSavedCalls, 0);
    expect(retrieval.recommendationCalls, 0);
  });

  testWidgets('nothing that needs a session is offered', (
    WidgetTester tester,
  ) async {
    final FakeRetrievalRepository retrieval = await _openSearch(tester);

    // The landing is where the saved section would render.
    expect(find.text('Saved searches'), findsNothing);

    await tester.enterText(find.byType(QSearchField), 'barish');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await settleFrames(tester);

    // Absent, not disabled: nothing invites a request the server would refuse.
    expect(find.byTooltip('Save this search'), findsNothing);
    expect(retrieval.listSavedCalls, 0);
  });

  testWidgets('the scope tabs work signed out too', (
    WidgetTester tester,
  ) async {
    await _openSearch(tester);

    await tester.enterText(find.byType(QSearchField), 'barish');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await settleFrames(tester);

    // The narrower scopes are the frozen `/search/*` endpoints, public as they always
    // were — D5 changed the "All" engine, not the tabs.
    expect(find.text('Pieces'), findsWidgets);
    await tester.tap(find.text('Pieces').first);
    await settleFrames(tester);
    expect(find.byType(SearchScreen), findsOneWidget);
  });
}

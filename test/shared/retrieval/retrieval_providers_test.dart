/// The shared retrieval providers (**M2**).
///
/// This was `test/features/ai/retrieval_controllers_test.dart`. It moved with the code:
/// D5 lifted search, saved searches and recommendations out of `features/ai` into
/// `lib/shared/retrieval/`, because three separate features consume them and features
/// never import features.
///
/// Two things left with the old semantic-search screen and are gone from here:
/// `RetrievalSessionController` (the search screen owns query state now) and the
/// device-local search-history store (recents already exist on the search screen).
///
/// **The auth split is what this file is really for.** Two of the six calls are public
/// and four need a session, and the difference is invisible to a render-only test —
/// which is exactly how an authenticated read reached a public page on web
/// (`platfrom/docs/48` §3.25). So the recommendation tests here assert whether the
/// repository was *called*, not what was drawn.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/session/session_controller.dart';
import 'package:qalam_mobile/core/session/session_state.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/ai/domain/entities/story_graph.dart';
import 'package:qalam_mobile/features/ai/presentation/controllers/story_explorer_controller.dart';
import 'package:qalam_mobile/features/search/presentation/controllers/saved_searches_controller.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/retrieval/domain/retrieval.dart';
import 'package:qalam_mobile/shared/retrieval/domain/retrieval_vocab.dart';
import 'package:qalam_mobile/shared/retrieval/domain/saved_search.dart';
import 'package:qalam_mobile/shared/retrieval/retrieval_providers.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/fake_retrieval_repository.dart';
import '../../support/harness.dart';

const RetrievalResponseMeta _meta = RetrievalResponseMeta(
  sources: <String>['knowledge_graph'],
  totalCandidates: 3,
  returned: 3,
  confidence: 0.7,
  degraded: false,
);

class _AuthedSession extends SessionController {
  @override
  Future<SessionState> build() async =>
      const SessionState.authenticated(role: Role.user);
}

class _AnonSession extends SessionController {
  @override
  Future<SessionState> build() async => const SessionState.anonymous();
}

void main() {
  test(
    'retrievalResults returns the ranked response from the repository',
    () async {
      final container = await buildTestContainer(
        retrievalRepository: FakeRetrievalRepository(
          search: const SemanticSearchResponse(
            query: 'aria',
            intent: 'search',
            queryType: 'character',
            results: <SearchResultItem>[],
            evidence: <RetrievalEvidence>[],
            meta: _meta,
          ),
        ),
      );
      addTearDown(container.dispose);

      final SemanticSearchResponse r = await container.read(
        retrievalResultsProvider((query: 'aria', storyId: 'piece-1')).future,
      );
      expect(r.meta.totalCandidates, 3);
      expect(r.meta.sources, contains('knowledge_graph'));
    },
  );

  /// The public half, asserted as a *request*: no session is arranged at all, and the
  /// search still has to reach the repository. B1 made `POST /ai/search` public
  /// precisely so an anonymous reader gets results.
  test('retrievalResults reaches the network with no session', () async {
    final FakeRetrievalRepository fake = FakeRetrievalRepository();
    final container = await buildTestContainer(
      retrievalRepository: fake,
      sessionOverride: _AnonSession.new,
    );
    addTearDown(container.dispose);

    await container.read(
      retrievalResultsProvider((query: 'aria', storyId: null)).future,
    );
    expect(fake.searchCalls, 1);
  });

  test(
    'retrievalSuggestions is public, and silent below two characters',
    () async {
      final FakeRetrievalRepository fake = FakeRetrievalRepository(
        suggestions: <String>['aria the cartographer'],
      );
      final container = await buildTestContainer(
        retrievalRepository: fake,
        sessionOverride: _AnonSession.new,
      );
      addTearDown(container.dispose);

      expect(
        await container.read(
          retrievalSuggestionsProvider((prefix: 'a', storyId: null)).future,
        ),
        isEmpty,
      );
      expect(
        fake.suggestionCalls,
        0,
        reason: 'a one-letter prefix is not a query',
      );

      expect(
        await container.read(
          retrievalSuggestionsProvider((prefix: 'ar', storyId: null)).future,
        ),
        contains('aria the cartographer'),
      );
      expect(fake.suggestionCalls, 1);
    },
  );

  group('recommendations are authenticated', () {
    test('a signed-in reader gets explained items', () async {
      final FakeRetrievalRepository fake = FakeRetrievalRepository(
        recommendations: const RecommendationResponse(
          kind: 'trending',
          items: <RecommendationItem>[
            RecommendationItem(
              id: 'p1',
              kind: 'trending',
              targetType: 'piece',
              title: 'A Story',
              summary: '',
              object: <String, dynamic>{},
              score: 0.9,
              confidence: 0.9,
              reason: 'Trending now',
              influencedBy: <RelatedEntity>[],
              evidence: <RetrievalEvidence>[],
              navigation: NavigationTarget(kind: 'piece', ref: 's1'),
            ),
          ],
          meta: _meta,
        ),
      );
      final container = await buildTestContainer(
        retrievalRepository: fake,
        sessionOverride: _AuthedSession.new,
      );
      addTearDown(container.dispose);
      // Hold it open: the provider is autoDispose and now AWAITS the session before
      // deciding, so an unlistened `read` can be swept mid-load.
      container.listen(
        recommendationsProvider((
          kind: RecommendationKind.trending,
          storyId: null,
          pieceId: null,
        )),
        (_, _) {},
      );

      final RecommendationResponse r = await container.read(
        recommendationsProvider((
          kind: RecommendationKind.trending,
          storyId: null,
          pieceId: null,
        )).future,
      );
      expect(r.items.single.reason, 'Trending now');
      expect(fake.recommendationCalls, 1);
    });

    /// **The assertion that has to be about the request.** An anonymous reader gets an
    /// empty response — but the point is not the emptiness, it is that the repository
    /// was never reached. A 401 here would be terminal: `ApiClient` ends the session
    /// and clears the caches for any 401 outside `/auth/*`, so a recommendation shelf
    /// on a public page would sign the reader out of the page they were reading.
    test('an anonymous reader triggers NO request at all', () async {
      final FakeRetrievalRepository fake = FakeRetrievalRepository();
      final container = await buildTestContainer(
        retrievalRepository: fake,
        sessionOverride: _AnonSession.new,
      );
      addTearDown(container.dispose);
      container.listen(
        recommendationsProvider((
          kind: RecommendationKind.feed,
          storyId: null,
          pieceId: null,
        )),
        (_, _) {},
      );

      final RecommendationResponse r = await container.read(
        recommendationsProvider((
          kind: RecommendationKind.feed,
          storyId: null,
          pieceId: null,
        )).future,
      );
      expect(r.items, isEmpty);
      expect(fake.recommendationCalls, 0);
    });
  });

  group('SavedSearchesController', () {
    test('saves through the retrieval repository and updates state', () async {
      final FakeRetrievalRepository fake = FakeRetrievalRepository();
      final container = await buildTestContainer(
        retrievalRepository: fake,
        sessionOverride: _AuthedSession.new,
      );
      addTearDown(container.dispose);
      container.listen(savedSearchesControllerProvider, (_, _) {});

      final Result<SavedSearch> result = await container
          .read(savedSearchesControllerProvider.notifier)
          .save(name: 'Villains', query: 'antagonist', storyId: 'piece-1');

      expect(result, isA<Ok<SavedSearch>>());
      expect(fake.savedSearchNames, contains('Villains'));
      expect(
        container
            .read(savedSearchesControllerProvider)
            .map((SavedSearch s) => s.name),
        contains('Villains'),
      );
    });

    /// Same shape as the recommendation case, and for the same reason: every saved-
    /// search route needs a session, so the sync must not even be attempted without
    /// one. It is also the pre-D5 hazard in miniature — this list used to be reachable
    /// only from a screen behind the `/ai` prefix, which was authenticated by the
    /// router; on the public search landing, nothing else stops it.
    test('does not sync for an anonymous reader', () async {
      final FakeRetrievalRepository fake = FakeRetrievalRepository(
        savedSearches: <SavedSearch>[
          SavedSearch(
            id: 's1',
            name: 'Lanterns',
            query: 'lantern',
            queryType: null,
            storyId: null,
            createdAt: DateTime(2026),
          ),
        ],
      );
      final container = await buildTestContainer(
        retrievalRepository: fake,
        sessionOverride: _AnonSession.new,
      );
      addTearDown(container.dispose);
      container.listen(savedSearchesControllerProvider, (_, _) {});

      await container
          .read(savedSearchesControllerProvider.notifier)
          .syncFromServer();

      expect(fake.listSavedCalls, 0);
      expect(container.read(savedSearchesControllerProvider), isEmpty);
    });
  });

  /// Story Map's own read still belongs to the AI feature — it is a graph view, not a
  /// search — so it still resolves through `AiRepository`. Kept here as the boundary
  /// marker: if this ever needs `FakeRetrievalRepository`, the split has drifted.
  test('explorerView returns the graph view for a story + view', () async {
    final container = await buildTestContainer(
      aiRepository: FakeAiRepository(
        explorer: const ExplorerViewResult(
          storyId: 'piece-1',
          view: 'characters',
          nodes: <StoryGraphNode>[
            StoryGraphNode(
              id: 'c1',
              type: 'character',
              name: 'Aria',
              aliases: <String>[],
              summary: 'hero',
              data: <String, dynamic>{},
              confidence: 0.8,
              mentionCount: 3,
              firstChapter: null,
              evidence: <StoryGraphEvidence>[],
            ),
          ],
          edges: <StoryGraphEdge>[],
          nodeCount: 1,
          edgeCount: 0,
        ),
      ),
    );
    addTearDown(container.dispose);

    final ExplorerViewResult v = await container.read(
      explorerViewProvider((
        storyId: 'piece-1',
        view: ExplorerView.characters,
      )).future,
    );
    expect(v.nodes.single.name, 'Aria');
  });
}

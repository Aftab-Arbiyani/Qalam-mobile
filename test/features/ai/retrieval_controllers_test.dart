import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/harness.dart';

void main() {
  test(
    'semanticSearchResults returns the ranked response from the repository',
    () async {
      final container = await buildTestContainer(
        aiRepository: FakeAiRepository(
          search: const SemanticSearchResponse(
            query: 'aria',
            intent: 'search',
            queryType: 'character',
            answer: null,
            results: <SearchResultItem>[],
            evidence: <RetrievalEvidence>[],
            meta: RetrievalResponseMeta(
              sources: <String>['knowledge_graph'],
              totalCandidates: 3,
              returned: 3,
              confidence: 0.7,
              degraded: false,
            ),
          ),
        ),
      );
      addTearDown(container.dispose);

      final SemanticSearchResponse r = await container.read(
        semanticSearchResultsProvider((
          query: 'aria',
          storyId: 'piece-1',
          synthesize: false,
        )).future,
      );
      expect(r.meta.totalCandidates, 3);
      expect(r.meta.sources, contains('knowledge_graph'));
    },
  );

  test(
    'AskBookController streams deltas into an accumulated, cited answer',
    () async {
      final container = await buildTestContainer(
        aiRepository: FakeAiRepository(
          askStreamEvents: <AskStreamEvent>[
            const AskStreamEvent(
              type: AskStreamEventType.sources,
              confidence: 0.8,
              citations: <AskCitation>[
                AskCitation(ref: 'n1', label: 'Aria', quote: 'brave'),
              ],
            ),
            const AskStreamEvent(
              type: AskStreamEventType.start,
              conversationId: 'c1',
            ),
            const AskStreamEvent(type: AskStreamEventType.delta, text: 'Aria '),
            const AskStreamEvent(
              type: AskStreamEventType.delta,
              text: 'is the hero.',
            ),
            const AskStreamEvent(
              type: AskStreamEventType.done,
              usage: AiTokenUsage(
                inputTokens: 1,
                outputTokens: 2,
                totalTokens: 3,
              ),
            ),
          ],
        ),
      );
      addTearDown(container.dispose);
      container.listen(askBookControllerProvider, (_, _) {});

      await container
          .read(askBookControllerProvider.notifier)
          .ask(
            const AskBookRequest(
              storyId: 'piece-1',
              question: 'who is aria?',
              scope: AskScope.character,
            ),
          );

      final AskBookState state = container.read(askBookControllerProvider);
      expect(state.status, AskStatus.done);
      expect(state.answer, 'Aria is the hero.');
      expect(state.citations, hasLength(1));
      expect(state.conversationId, 'c1');
    },
  );

  test(
    'AskBookController surfaces a stream error event as an error state',
    () async {
      final container = await buildTestContainer(
        aiRepository: FakeAiRepository(
          askStreamEvents: <AskStreamEvent>[
            const AskStreamEvent(
              type: AskStreamEventType.error,
              code: 'AI_FEATURE_DISABLED',
            ),
          ],
        ),
      );
      addTearDown(container.dispose);
      container.listen(askBookControllerProvider, (_, _) {});

      await container
          .read(askBookControllerProvider.notifier)
          .ask(const AskBookRequest(storyId: 'piece-1', question: 'x'));
      final AskBookState state = container.read(askBookControllerProvider);
      expect(state.status, AskStatus.error);
      expect(state.errorCode, 'AI_FEATURE_DISABLED');
    },
  );

  test(
    'SavedSearchesController.save records the search and updates state',
    () async {
      final fake = FakeAiRepository();
      final container = await buildTestContainer(aiRepository: fake);
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
    },
  );

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

  test('recommendations returns explained items for a kind', () async {
    final container = await buildTestContainer(
      aiRepository: FakeAiRepository(
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
          meta: RetrievalResponseMeta(
            sources: <String>[],
            totalCandidates: 1,
            returned: 1,
            confidence: 0.9,
            degraded: false,
          ),
        ),
      ),
    );
    addTearDown(container.dispose);

    final RecommendationResponse r = await container.read(
      recommendationsProvider((
        kind: RecommendationKind.trending,
        storyId: null,
        pieceId: null,
      )).future,
    );
    expect(r.items.single.reason, 'Trending now');
  });

  test('RetrievalSessionController.submit commits a valid query', () async {
    final container = await buildTestContainer(
      aiRepository: FakeAiRepository(),
    );
    addTearDown(container.dispose);
    container.listen(retrievalSessionControllerProvider, (_, _) {});

    final bool ok = container
        .read(retrievalSessionControllerProvider.notifier)
        .submit('aria');
    expect(ok, isTrue);
    expect(
      container.read(retrievalSessionControllerProvider).submitted,
      isTrue,
    );

    // `submit` fires an unawaited history write (`record`, a real Hive box put).
    // Left dangling, it can still be in flight when this test returns and
    // `addTearDown` disposes the container — a fire-and-forget Future racing
    // disposal, with nothing here to flush it. Hardening for the failure class
    // M-5 (docs/48 §3.22c) describes; not a confirmed fix — see the ledger note.
    await pumpEventQueue();

    final bool tooShort = container
        .read(retrievalSessionControllerProvider.notifier)
        .submit('a');
    expect(tooShort, isFalse);
  });
}

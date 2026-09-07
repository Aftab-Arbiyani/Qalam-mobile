/// A configurable in-memory [AiRepository] for AF2/AF3 tests. Replays fixed stream
/// scripts, returns canned completions, and records the requests it received so tests
/// can assert what the client sent (feature, promptKey, context).
///
/// **D5** cut the conversation, usage and Ask surfaces out of it and added the Story
/// Map run; **M2** cut retrieval out entirely — search, saved searches and
/// recommendations are `FakeRetrievalRepository`'s now, because the contract they
/// belong to moved to `lib/shared/retrieval/`. Five methods left, matching the five on
/// `AiRepository`.
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

class FakeAiRepository implements AiRepository {
  FakeAiRepository({
    List<AiStreamEvent>? streamEvents,
    AiCompletionResult? completion,
    AiFeatures? features,
    this.failure,
    // AF3 canned responses.
    List<StoryMapEvent>? mapEvents,
    this.mapHold,
    ExplorerViewResult? explorer,
  }) : streamEvents = streamEvents ?? const <AiStreamEvent>[],
       _completion = completion,
       _features = features,
       mapEvents = mapEvents ?? const <StoryMapEvent>[],
       _explorer = explorer;

  final List<AiStreamEvent> streamEvents;
  final AiCompletionResult? _completion;
  final AiFeatures? _features;
  final List<StoryMapEvent> mapEvents;

  /// When set, [mapStory] waits on this after replaying [mapEvents] instead of closing.
  /// A map run that drains in microtasks never paints its progress, so a test that wants
  /// to observe a frame mid-run has to hold the stream open the way a real one is.
  final Future<void>? mapHold;
  final ExplorerViewResult? _explorer;

  /// When set, every call fails with this failure.
  final Failure? failure;

  // Recorded inputs for assertions.
  AiCompletionRequest? lastCompletionRequest;
  AiCompletionRequest? lastStreamRequest;

  /// What the last "Map this story" run was asked to map. Recorded because the
  /// endpoint takes the CONTENT, so a test can prove the editor's text reached it —
  /// a run that sent the id and no text would 400, not merely under-deliver.
  /// How many explorer view reads the fake served. A finished map run has to make the
  /// screen refetch — a mapped story that still renders the pre-map graph is
  /// indistinguishable from the hollow-graph defect D5's trigger exists to fix.
  int explorerCallCount = 0;

  String? lastMappedStoryId;
  String? lastMappedContent;
  String? lastMappedTitle;

  @override
  Future<Result<AiFeatures>> features() async => failure != null
      ? Err<AiFeatures>(failure!)
      : Ok<AiFeatures>(
          _features ??
              const AiFeatures(aiEnabled: true, features: <AiFeatureFlag>[]),
        );

  @override
  Future<Result<AiCompletionResult>> complete(
    AiCompletionRequest request,
  ) async {
    lastCompletionRequest = request;
    if (failure != null) return Err<AiCompletionResult>(failure!);
    return Ok<AiCompletionResult>(
      _completion ??
          const AiCompletionResult(
            content: 'ok',
            provider: 'openai',
            model: 'gpt-4o',
            finishReason: 'stop',
            estimatedCostUsd: 0,
          ),
    );
  }

  @override
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request) async* {
    lastStreamRequest = request;
    for (final AiStreamEvent event in streamEvents) {
      yield event;
    }
  }

  @override
  Future<Result<ExplorerViewResult>> explorer(
    String storyId,
    String view,
  ) async {
    explorerCallCount++;
    return failure != null
        ? Err<ExplorerViewResult>(failure!)
        : Ok<ExplorerViewResult>(
            _explorer ??
                ExplorerViewResult(
                  storyId: storyId,
                  view: view,
                  nodes: const <StoryGraphNode>[],
                  edges: const <StoryGraphEdge>[],
                  nodeCount: 0,
                  edgeCount: 0,
                ),
          );
  }

  @override
  Stream<StoryMapEvent> mapStory(
    String storyId, {
    required String content,
    String? storyTitle,
  }) async* {
    lastMappedStoryId = storyId;
    lastMappedContent = content;
    lastMappedTitle = storyTitle;
    for (final StoryMapEvent event in mapEvents) {
      yield event;
    }
    if (mapHold != null) await mapHold;
  }
}

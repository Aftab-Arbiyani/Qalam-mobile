/// A configurable in-memory [AiRepository] for AF2/AF3/AF4 tests. Replays fixed stream
/// scripts, returns canned completions and retrieval results, and records the requests
/// it received so tests can assert what the client sent (feature, promptKey, context).
///
/// **D5** cut the conversation, usage and Ask surfaces out of it, and added the Story
/// Map run.
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

class FakeAiRepository implements AiRepository {
  FakeAiRepository({
    List<AiStreamEvent>? streamEvents,
    AiCompletionResult? completion,
    AiFeatures? features,
    this.failure,
    // AF3 / AF4 canned responses.
    List<StoryMapEvent>? mapEvents,
    this.mapHold,
    SemanticSearchResponse? search,
    List<String>? suggestions,
    List<SavedSearch>? savedSearches,
    ExplorerViewResult? explorer,
    RecommendationResponse? recommendations,
    this.recommendationsFailure,
  }) : streamEvents = streamEvents ?? const <AiStreamEvent>[],
       _completion = completion,
       _features = features,
       mapEvents = mapEvents ?? const <StoryMapEvent>[],
       _search = search,
       _suggestions = suggestions ?? const <String>[],
       _savedSearches = savedSearches ?? const <SavedSearch>[],
       _explorer = explorer,
       _recommendations = recommendations;

  final List<AiStreamEvent> streamEvents;
  final AiCompletionResult? _completion;
  final AiFeatures? _features;
  final List<StoryMapEvent> mapEvents;

  /// When set, [mapStory] waits on this after replaying [mapEvents] instead of closing.
  /// A map run that drains in microtasks never paints its progress, so a test that wants
  /// to observe a frame mid-run has to hold the stream open the way a real one is.
  final Future<void>? mapHold;
  final SemanticSearchResponse? _search;
  final List<String> _suggestions;
  final List<SavedSearch> _savedSearches;
  final ExplorerViewResult? _explorer;
  final RecommendationResponse? _recommendations;

  /// When set, every call fails with this failure.
  final Failure? failure;

  /// When set, ONLY [recommendations] fails with this — lets a test fail the
  /// recommendation fetch specifically while `features()` still succeeds
  /// (falls back to [failure] when unset, so every existing caller is
  /// unaffected).
  final Failure? recommendationsFailure;

  // Recorded inputs for assertions.
  AiCompletionRequest? lastCompletionRequest;
  AiCompletionRequest? lastStreamRequest;
  SemanticSearchRequest? lastSearchRequest;
  RecommendationQuery? lastRecommendationQuery;
  final List<String> savedSearchNames = <String>[];

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

  // ── AF4 ──────────────────────────────────────────────────────────────────────

  @override
  Future<Result<SemanticSearchResponse>> searchSemantic(
    SemanticSearchRequest request,
  ) async {
    lastSearchRequest = request;
    if (failure != null) return Err<SemanticSearchResponse>(failure!);
    return Ok<SemanticSearchResponse>(
      _search ??
          const SemanticSearchResponse(
            query: '',
            intent: 'search',
            queryType: 'natural_language',
            answer: null,
            results: <SearchResultItem>[],
            evidence: <RetrievalEvidence>[],
            meta: RetrievalResponseMeta(
              sources: <String>[],
              totalCandidates: 0,
              returned: 0,
              confidence: 0,
              degraded: false,
            ),
          ),
    );
  }

  @override
  Future<Result<List<String>>> searchSuggestions(
    String query, {
    String? storyId,
  }) async => failure != null
      ? Err<List<String>>(failure!)
      : Ok<List<String>>(_suggestions);

  @override
  Future<Result<List<SavedSearch>>> listSavedSearches() async => failure != null
      ? Err<List<SavedSearch>>(failure!)
      : Ok<List<SavedSearch>>(_savedSearches);

  @override
  Future<Result<SavedSearch>> saveSearch({
    required String name,
    required String query,
    String? queryType,
    String? storyId,
  }) async {
    savedSearchNames.add(name);
    if (failure != null) return Err<SavedSearch>(failure!);
    return Ok<SavedSearch>(
      SavedSearch(
        id: 'ss-$name',
        name: name,
        query: query,
        queryType: queryType,
        storyId: storyId,
        createdAt: DateTime(2026),
      ),
    );
  }

  @override
  Future<Result<Unit>> deleteSavedSearch(String id) async =>
      failure != null ? Err<Unit>(failure!) : const Ok<Unit>(unit);

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

  @override
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  ) async {
    lastRecommendationQuery = query;
    final Failure? effectiveFailure = recommendationsFailure ?? failure;
    if (effectiveFailure != null) {
      return Err<RecommendationResponse>(effectiveFailure);
    }
    return Ok<RecommendationResponse>(
      _recommendations ??
          RecommendationResponse(
            kind: query.kind.wire,
            items: const <RecommendationItem>[],
            meta: const RetrievalResponseMeta(
              sources: <String>[],
              totalCandidates: 0,
              returned: 0,
              confidence: 0,
              degraded: false,
            ),
          ),
    );
  }
}

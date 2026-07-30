/// A configurable in-memory [AiRepository] for AF2 tests. Replays a fixed stream
/// script, returns canned completions/usage/conversations, and records the requests
/// it received so tests can assert what the client sent (feature, promptKey, context).
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/ai/ai.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';

class FakeAiRepository implements AiRepository {
  FakeAiRepository({
    List<AiStreamEvent>? streamEvents,
    AiCompletionResult? completion,
    AiFeatures? features,
    AiUsageSummary? usage,
    List<AiConversationSummary>? conversations,
    AiConversationDetail? detail,
    this.failure,
    // AF4 canned responses.
    SemanticSearchResponse? search,
    List<String>? suggestions,
    List<SavedSearch>? savedSearches,
    AskBookAnswer? askAnswer,
    List<AskStreamEvent>? askStreamEvents,
    ExplorerViewResult? explorer,
    RecommendationResponse? recommendations,
  }) : streamEvents = streamEvents ?? const <AiStreamEvent>[],
       _completion = completion,
       _features = features,
       _usage = usage,
       _conversations = conversations ?? const <AiConversationSummary>[],
       _detail = detail,
       _search = search,
       _suggestions = suggestions ?? const <String>[],
       _savedSearches = savedSearches ?? const <SavedSearch>[],
       _askAnswer = askAnswer,
       askStreamEvents = askStreamEvents ?? const <AskStreamEvent>[],
       _explorer = explorer,
       _recommendations = recommendations;

  final List<AiStreamEvent> streamEvents;
  final AiCompletionResult? _completion;
  final AiFeatures? _features;
  final AiUsageSummary? _usage;
  final List<AiConversationSummary> _conversations;
  final AiConversationDetail? _detail;
  final SemanticSearchResponse? _search;
  final List<String> _suggestions;
  final List<SavedSearch> _savedSearches;
  final AskBookAnswer? _askAnswer;
  final List<AskStreamEvent> askStreamEvents;
  final ExplorerViewResult? _explorer;
  final RecommendationResponse? _recommendations;

  /// When set, every call fails with this failure.
  final Failure? failure;

  // Recorded inputs for assertions.
  AiCompletionRequest? lastCompletionRequest;
  AiCompletionRequest? lastStreamRequest;
  SemanticSearchRequest? lastSearchRequest;
  AskBookRequest? lastAskRequest;
  AskBookRequest? lastAskStreamRequest;
  RecommendationQuery? lastRecommendationQuery;
  final List<String> deletedConversationIds = <String>[];
  final List<String> savedSearchNames = <String>[];

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
  Future<Result<AiUsageSummary>> usage() async => failure != null
      ? Err<AiUsageSummary>(failure!)
      : Ok<AiUsageSummary>(
          _usage ??
              const AiUsageSummary(
                daily: AiUsageWindow.zero,
                monthly: AiUsageWindow.zero,
                total: AiUsageWindow.zero,
                byFeature: <AiFeatureUsage>[],
              ),
        );

  @override
  Future<Result<CursorPage<AiConversationSummary>>> listConversations({
    String? cursor,
    int? limit,
  }) async => failure != null
      ? Err<CursorPage<AiConversationSummary>>(failure!)
      : Ok<CursorPage<AiConversationSummary>>(
          CursorPage<AiConversationSummary>(
            items: _conversations,
            meta: const CursorMeta(),
          ),
        );

  @override
  Future<Result<AiConversationSummary>> createConversation({
    required String feature,
    String? title,
  }) async => failure != null
      ? Err<AiConversationSummary>(failure!)
      : Ok<AiConversationSummary>(
          AiConversationSummary(
            id: 'c-new',
            title: title,
            feature: feature,
            status: AiConversationStatus.active,
            messageCount: 0,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

  @override
  Future<Result<AiConversationDetail>> getConversation(String id) async {
    if (failure != null) return Err<AiConversationDetail>(failure!);
    final AiConversationDetail? detail = _detail;
    if (detail != null) return Ok<AiConversationDetail>(detail);
    return const Err<AiConversationDetail>(
      Failure.notFound(code: 'AI_CONVERSATION_NOT_FOUND'),
    );
  }

  @override
  Future<Result<AiConversationSummary>> renameConversation(
    String id,
    String title,
  ) async => failure != null
      ? Err<AiConversationSummary>(failure!)
      : Ok<AiConversationSummary>(
          _conversations
              .firstWhere((AiConversationSummary c) => c.id == id)
              .copyWith(title: title),
        );

  @override
  Future<Result<AiConversationSummary>> setConversationStatus(
    String id,
    AiConversationStatus status,
  ) async => failure != null
      ? Err<AiConversationSummary>(failure!)
      : Ok<AiConversationSummary>(
          _conversations
              .firstWhere((AiConversationSummary c) => c.id == id)
              .copyWith(status: status),
        );

  @override
  Future<Result<Unit>> deleteConversation(String id) async {
    if (failure != null) return Err<Unit>(failure!);
    deletedConversationIds.add(id);
    return const Ok<Unit>(unit);
  }

  @override
  Future<Result<Json>> exportConversation(String id) async => failure != null
      ? Err<Json>(failure!)
      : Ok<Json>(<String, dynamic>{'id': id, 'messages': <dynamic>[]});

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
  Future<Result<AskBookAnswer>> ask(AskBookRequest request) async {
    lastAskRequest = request;
    if (failure != null) return Err<AskBookAnswer>(failure!);
    return Ok<AskBookAnswer>(
      _askAnswer ??
          AskBookAnswer(
            storyId: request.storyId,
            scope: request.scope.wire,
            answer: 'A grounded answer.',
            citations: const <AskCitation>[],
            confidence: 0.8,
            usage: const AiTokenUsage(
              inputTokens: 1,
              outputTokens: 1,
              totalTokens: 2,
            ),
            estimatedCostUsd: 0,
            conversationId: null,
          ),
    );
  }

  @override
  Stream<AskStreamEvent> streamAsk(AskBookRequest request) async* {
    lastAskStreamRequest = request;
    for (final AskStreamEvent event in askStreamEvents) {
      yield event;
    }
  }

  @override
  Future<Result<ExplorerViewResult>> explorer(
    String storyId,
    String view,
  ) async => failure != null
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

  @override
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  ) async {
    lastRecommendationQuery = query;
    if (failure != null) return Err<RecommendationResponse>(failure!);
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

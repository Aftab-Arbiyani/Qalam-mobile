/// AI remote data source (AF1 + AF2) — the only place the AI endpoints + `ApiClient`
/// are touched. Maps the streamed JSON maps to typed [AiStreamEvent]s and owns the
/// [CancelToken] so cancelling the returned stream aborts the HTTP request (keeping
/// Dio out of the presentation layer). AF2 adds the conversation + usage endpoints,
/// reusing the same client (envelope unwrap, offline pre-check, error mapping).
library;

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/ai_stream_event.dart';
import '../../domain/entities/ai_usage.dart';
import '../../domain/entities/ask_answer.dart';
import '../../domain/entities/retrieval.dart';
import '../../domain/entities/saved_search.dart';
import '../../domain/entities/story_graph.dart';
import '../../domain/value_objects/retrieval_requests.dart';

class AiRemoteDataSource {
  const AiRemoteDataSource(this._api);

  final ApiClient _api;

  Future<AiFeatures> features({CancelToken? cancelToken}) => _api.get(
    ApiPaths.aiFeatures,
    decode: AiFeatures.fromJson,
    cancelToken: cancelToken,
  );

  Future<AiCompletionResult> complete(
    AiCompletionRequest request, {
    CancelToken? cancelToken,
  }) => _api.post(
    ApiPaths.aiCompletions,
    body: request.toJson(),
    decode: AiCompletionResult.fromJson,
    cancelToken: cancelToken,
  );

  /// Streamed completion. The returned stream owns a [CancelToken]; cancelling the
  /// subscription cancels it (aborting the request) so callers never see Dio.
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request) {
    final CancelToken cancelToken = CancelToken();
    final StreamController<AiStreamEvent> controller =
        StreamController<AiStreamEvent>();
    final StreamSubscription<AiStreamEvent> subscription = _api
        .streamSse(
          ApiPaths.aiCompletionsStream,
          body: request.toJson(),
          cancelToken: cancelToken,
        )
        .map(AiStreamEvent.fromJson)
        .listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
    controller.onCancel = () async {
      cancelToken.cancel();
      await subscription.cancel();
    };
    return controller.stream;
  }

  Future<AiUsageSummary> usage({CancelToken? cancelToken}) => _api.get(
    ApiPaths.aiUsageMe,
    decode: AiUsageSummary.fromJson,
    cancelToken: cancelToken,
  );

  // ── Conversations ────────────────────────────────────────────────────────────

  Future<CursorPage<AiConversationSummary>> listConversations({
    String? cursor,
    int? limit,
    CancelToken? cancelToken,
  }) => _api.getPage(
    ApiPaths.aiConversations,
    query: <String, dynamic>{'cursor': cursor, 'limit': limit},
    decodeItem: AiConversationSummary.fromJson,
    cancelToken: cancelToken,
  );

  Future<AiConversationSummary> createConversation({
    required String feature,
    String? title,
    CancelToken? cancelToken,
  }) => _api.post(
    ApiPaths.aiConversations,
    body: <String, dynamic>{'feature': feature, 'title': ?title},
    decode: AiConversationSummary.fromJson,
    cancelToken: cancelToken,
  );

  Future<AiConversationDetail> getConversation(
    String id, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.aiConversationById(id),
    decode: AiConversationDetail.fromJson,
    cancelToken: cancelToken,
  );

  Future<AiConversationSummary> renameConversation(String id, String title) =>
      _api.patch(
        ApiPaths.aiConversationById(id),
        body: <String, dynamic>{'title': title},
        decode: AiConversationSummary.fromJson,
      );

  Future<AiConversationSummary> setConversationStatus(
    String id,
    AiConversationStatus status,
  ) => _api.patch(
    ApiPaths.aiConversationById(id),
    body: <String, dynamic>{'status': status.wire},
    decode: AiConversationSummary.fromJson,
  );

  Future<void> deleteConversation(String id) =>
      _api.delete(ApiPaths.aiConversationById(id));

  Future<Json> exportConversation(String id, {CancelToken? cancelToken}) =>
      _api.get(
        ApiPaths.aiConversationExport(id),
        decode: (Json json) => json,
        cancelToken: cancelToken,
      );

  // ── AF4 — discovery / search / ask / explorer / recommendations ───────────────

  Future<SemanticSearchResponse> searchSemantic(
    SemanticSearchRequest request, {
    CancelToken? cancelToken,
  }) => _api.post(
    ApiPaths.aiSearch,
    body: request.toJson(),
    decode: SemanticSearchResponse.fromJson,
    cancelToken: cancelToken,
  );

  Future<List<String>> searchSuggestions(
    String query, {
    String? storyId,
    CancelToken? cancelToken,
  }) async {
    final Json result = await _api.get(
      ApiPaths.aiSearchSuggestions,
      query: <String, dynamic>{'q': query, 'storyId': storyId},
      decode: (Json json) => json,
      cancelToken: cancelToken,
      deduplicate: false,
    );
    return (result['suggestions'] as List?)?.whereType<String>().toList() ??
        const <String>[];
  }

  Future<List<SavedSearch>> listSavedSearches({CancelToken? cancelToken}) =>
      _api.getList(
        ApiPaths.aiSearchSaved,
        decodeItem: SavedSearch.fromJson,
        cancelToken: cancelToken,
      );

  Future<SavedSearch> saveSearch(Json body, {CancelToken? cancelToken}) =>
      _api.post(
        ApiPaths.aiSearchSaved,
        body: body,
        decode: SavedSearch.fromJson,
        cancelToken: cancelToken,
      );

  Future<void> deleteSavedSearch(String id) =>
      _api.delete(ApiPaths.aiSearchSavedById(id));

  Future<AskBookAnswer> ask(
    AskBookRequest request, {
    CancelToken? cancelToken,
  }) => _api.post(
    ApiPaths.aiAsk,
    body: request.toJson(),
    decode: AskBookAnswer.fromJson,
    cancelToken: cancelToken,
  );

  /// Streamed Ask answer. Owns a [CancelToken]; cancelling the returned stream's
  /// subscription aborts the request (Dio never reaches presentation). Same pattern as
  /// [streamCompletion]; only the event type ([AskStreamEvent]) differs.
  Stream<AskStreamEvent> streamAsk(AskBookRequest request) {
    final CancelToken cancelToken = CancelToken();
    final StreamController<AskStreamEvent> controller =
        StreamController<AskStreamEvent>();
    final StreamSubscription<AskStreamEvent> subscription = _api
        .streamSse(
          ApiPaths.aiAskStream,
          body: request.toJson(),
          cancelToken: cancelToken,
        )
        .map(AskStreamEvent.fromJson)
        .listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
    controller.onCancel = () async {
      cancelToken.cancel();
      await subscription.cancel();
    };
    return controller.stream;
  }

  Future<ExplorerViewResult> explorer(
    String storyId,
    String view, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.aiExplorer(storyId, view),
    decode: ExplorerViewResult.fromJson,
    cancelToken: cancelToken,
  );

  Future<RecommendationResponse> recommendations(
    RecommendationQuery query, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.aiRecommendations,
    query: query.toQuery(),
    decode: RecommendationResponse.fromJson,
    cancelToken: cancelToken,
  );
}

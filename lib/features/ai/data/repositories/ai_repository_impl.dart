/// AI repository implementation (AF1 + AF2). Wraps unary remote calls in
/// [guardResult] / [guardUnit] (ApiException → Failure); passes the stream through
/// (its errors surface to the stream controller in presentation).
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
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
import '../../domain/repositories/ai_repository.dart';
import '../../domain/value_objects/retrieval_requests.dart';
import '../datasources/ai_remote_data_source.dart';

class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl(this._remote);

  final AiRemoteDataSource _remote;

  @override
  Future<Result<AiFeatures>> features() => guardResult(_remote.features);

  @override
  Future<Result<AiCompletionResult>> complete(AiCompletionRequest request) =>
      guardResult(() => _remote.complete(request));

  @override
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request) =>
      _remote.streamCompletion(request);

  @override
  Future<Result<AiUsageSummary>> usage() => guardResult(_remote.usage);

  @override
  Future<Result<CursorPage<AiConversationSummary>>> listConversations({
    String? cursor,
    int? limit,
    AiConversationStatus? status,
  }) => guardResult(
    () => _remote.listConversations(
      cursor: cursor,
      limit: limit,
      status: status,
    ),
  );

  @override
  Future<Result<AiConversationSummary>> createConversation({
    required String feature,
    String? title,
  }) => guardResult(
    () => _remote.createConversation(feature: feature, title: title),
  );

  @override
  Future<Result<AiConversationDetail>> getConversation(String id) =>
      guardResult(() => _remote.getConversation(id));

  @override
  Future<Result<AiConversationSummary>> renameConversation(
    String id,
    String title,
  ) => guardResult(() => _remote.renameConversation(id, title));

  @override
  Future<Result<AiConversationSummary>> setConversationStatus(
    String id,
    AiConversationStatus status,
  ) => guardResult(() => _remote.setConversationStatus(id, status));

  @override
  Future<Result<Unit>> deleteConversation(String id) =>
      guardUnit(() => _remote.deleteConversation(id));

  @override
  Future<Result<Json>> exportConversation(String id) =>
      guardResult(() => _remote.exportConversation(id));

  // ── AF4 ──────────────────────────────────────────────────────────────────────

  @override
  Future<Result<SemanticSearchResponse>> searchSemantic(
    SemanticSearchRequest request,
  ) => guardResult(() => _remote.searchSemantic(request));

  @override
  Future<Result<List<String>>> searchSuggestions(
    String query, {
    String? storyId,
  }) => guardResult(() => _remote.searchSuggestions(query, storyId: storyId));

  @override
  Future<Result<List<SavedSearch>>> listSavedSearches() =>
      guardResult(_remote.listSavedSearches);

  @override
  Future<Result<SavedSearch>> saveSearch({
    required String name,
    required String query,
    String? queryType,
    String? storyId,
  }) => guardResult(
    () => _remote.saveSearch(<String, dynamic>{
      'name': name,
      'query': query,
      'queryType': ?queryType,
      'storyId': ?storyId,
    }),
  );

  @override
  Future<Result<Unit>> deleteSavedSearch(String id) =>
      guardUnit(() => _remote.deleteSavedSearch(id));

  @override
  Future<Result<AskBookAnswer>> ask(AskBookRequest request) =>
      guardResult(() => _remote.ask(request));

  @override
  Stream<AskStreamEvent> streamAsk(AskBookRequest request) =>
      _remote.streamAsk(request);

  @override
  Future<Result<ExplorerViewResult>> explorer(String storyId, String view) =>
      guardResult(() => _remote.explorer(storyId, view));

  @override
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  ) => guardResult(() => _remote.recommendations(query));
}

/// AI repository implementation (AF1 + AF2 + AF3). Wraps unary remote calls in
/// [guardResult] / [guardUnit] (ApiException → Failure); passes the stream through
/// (its errors surface to the stream controller in presentation).
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/ai_stream_event.dart';
import '../../domain/entities/retrieval.dart';
import '../../domain/entities/saved_search.dart';
import '../../domain/entities/story_graph.dart';
import '../../domain/entities/story_map_event.dart';
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
  Future<Result<ExplorerViewResult>> explorer(String storyId, String view) =>
      guardResult(() => _remote.explorer(storyId, view));

  @override
  Stream<StoryMapEvent> mapStory(
    String storyId, {
    required String content,
    String? storyTitle,
  }) => _remote.mapStory(storyId, content: content, storyTitle: storyTitle);

  @override
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  ) => guardResult(() => _remote.recommendations(query));
}

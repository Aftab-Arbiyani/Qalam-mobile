/// AI repository implementation (AF1 + AF2 + AF3). Wraps unary remote calls in
/// [guardResult] / [guardUnit] (ApiException → Failure); passes the stream through
/// (its errors surface to the stream controller in presentation).
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/ai_stream_event.dart';
import '../../domain/entities/story_graph.dart';
import '../../domain/entities/story_map_event.dart';
import '../../domain/repositories/ai_repository.dart';
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
  Future<Result<ExplorerViewResult>> explorer(String storyId, String view) =>
      guardResult(() => _remote.explorer(storyId, view));

  @override
  Stream<StoryMapEvent> mapStory(
    String storyId, {
    required String content,
    String? storyTitle,
  }) => _remote.mapStory(storyId, content: content, storyTitle: storyTitle);
}

/// AI repository implementation (AF1). Wraps unary remote calls in [guardResult]
/// (ApiException → Failure); passes the stream through (its errors surface to the
/// stream controller in presentation).
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/ai_stream_event.dart';
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
}

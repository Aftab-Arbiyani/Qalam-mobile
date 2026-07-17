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
  Future<Result<AiUsageSummary>> usage() => guardResult(_remote.usage);

  @override
  Future<Result<CursorPage<AiConversationSummary>>> listConversations({
    String? cursor,
    int? limit,
  }) =>
      guardResult(() => _remote.listConversations(cursor: cursor, limit: limit));

  @override
  Future<Result<AiConversationSummary>> createConversation({
    required String feature,
    String? title,
  }) =>
      guardResult(() => _remote.createConversation(feature: feature, title: title));

  @override
  Future<Result<AiConversationDetail>> getConversation(String id) =>
      guardResult(() => _remote.getConversation(id));

  @override
  Future<Result<AiConversationSummary>> renameConversation(String id, String title) =>
      guardResult(() => _remote.renameConversation(id, title));

  @override
  Future<Result<AiConversationSummary>> setConversationStatus(
    String id,
    AiConversationStatus status,
  ) =>
      guardResult(() => _remote.setConversationStatus(id, status));

  @override
  Future<Result<Unit>> deleteConversation(String id) =>
      guardUnit(() => _remote.deleteConversation(id));

  @override
  Future<Result<Json>> exportConversation(String id) =>
      guardResult(() => _remote.exportConversation(id));
}

/// AI remote data source (AF1) — the only place the AI endpoints + `ApiClient` are
/// touched. Maps the streamed JSON maps to typed [AiStreamEvent]s and owns the
/// [CancelToken] so cancelling the returned stream aborts the HTTP request
/// (keeping Dio out of the presentation layer).
library;

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/ai_stream_event.dart';

class AiRemoteDataSource {
  const AiRemoteDataSource(this._api);

  final ApiClient _api;

  Future<AiFeatures> features({CancelToken? cancelToken}) =>
      _api.get(ApiPaths.aiFeatures, decode: AiFeatures.fromJson, cancelToken: cancelToken);

  Future<AiCompletionResult> complete(AiCompletionRequest request, {CancelToken? cancelToken}) =>
      _api.post(
        ApiPaths.aiCompletions,
        body: request.toJson(),
        decode: AiCompletionResult.fromJson,
        cancelToken: cancelToken,
      );

  /// Streamed completion. The returned stream owns a [CancelToken]; cancelling the
  /// subscription cancels it (aborting the request) so callers never see Dio.
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request) {
    final CancelToken cancelToken = CancelToken();
    final StreamController<AiStreamEvent> controller = StreamController<AiStreamEvent>();
    final StreamSubscription<AiStreamEvent> subscription = _api
        .streamSse(ApiPaths.aiCompletionsStream, body: request.toJson(), cancelToken: cancelToken)
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
}

/// AI remote data source (AF1 + AF2 + AF3) — the only place the AI endpoints +
/// `ApiClient` are touched. Maps the streamed JSON maps to typed events and owns the
/// [CancelToken] so cancelling the returned stream aborts the HTTP request (keeping
/// Dio out of the presentation layer).
///
/// **D5** removed the conversation and usage endpoints (deleted by B2) and Ask My Book,
/// and added the Story Map batch trigger — the first client call that can actually
/// spend an analysis. **M2** moved the retrieval endpoints out to
/// `lib/shared/retrieval/`, leaving this file with only what the AI feature itself owns.
library;

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/ai_stream_event.dart';
import '../../domain/entities/story_graph.dart';
import '../../domain/entities/story_map_event.dart';

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

  // ── AF3 — Story Map ─────────────────────────────────────────────────────────

  Future<ExplorerViewResult> explorer(
    String storyId,
    String view, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.aiExplorer(storyId, view),
    decode: ExplorerViewResult.fromJson,
    cancelToken: cancelToken,
  );

  /// Streamed "Map this story". Owns a [CancelToken]; cancelling the returned stream's
  /// subscription aborts the request. That abort is not merely tidy here: the server
  /// watches the connection and stops running analyses when it closes, so a writer who
  /// walks away stops paying for work they will never see.
  Stream<StoryMapEvent> mapStory(
    String storyId, {
    required String content,
    String? storyTitle,
  }) {
    final CancelToken cancelToken = CancelToken();
    final StreamController<StoryMapEvent> controller =
        StreamController<StoryMapEvent>();
    final StreamSubscription<StoryMapEvent> subscription = _api
        .streamSse(
          ApiPaths.storyMapStream(storyId),
          body: <String, dynamic>{
            'content': content,
            'storyTitle': ?storyTitle,
          },
          cancelToken: cancelToken,
        )
        .map(StoryMapEvent.fromJson)
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

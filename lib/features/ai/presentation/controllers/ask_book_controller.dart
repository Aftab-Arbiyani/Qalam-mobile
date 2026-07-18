/// Ask My Book / Ask Chapter (AF4) — the streaming controller. Subscribes to the
/// repository's `streamAsk` (which reuses the shared `ApiClient.streamSse` transport;
/// no streaming/SSE logic is re-implemented here), accumulates token deltas, captures
/// the citations from the `sources` event, and handles cancellation + errors. Answers
/// always cite retrieved evidence. Global autoDispose; the subscription is cancelled on
/// dispose (which aborts the HTTP request).
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/api_exception.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../domain/entities/ai_stream_event.dart';
import '../../domain/entities/ask_answer.dart';
import '../../domain/value_objects/retrieval_requests.dart';
import '../providers/ai_providers.dart';

part 'ask_book_controller.g.dart';

enum AskStatus { idle, streaming, done, error, cancelled }

class AskBookState {
  const AskBookState({
    this.status = AskStatus.idle,
    this.answer = '',
    this.citations = const <AskCitation>[],
    this.confidence = 0,
    this.conversationId,
    this.usage,
    this.errorCode,
  });

  final AskStatus status;
  final String answer;
  final List<AskCitation> citations;
  final double confidence;
  final String? conversationId;
  final AiTokenUsage? usage;
  final String? errorCode;

  bool get isStreaming => status == AskStatus.streaming;
  bool get isTerminal =>
      status == AskStatus.done ||
      status == AskStatus.error ||
      status == AskStatus.cancelled;

  AskBookState copyWith({
    AskStatus? status,
    String? answer,
    List<AskCitation>? citations,
    double? confidence,
    String? conversationId,
    AiTokenUsage? usage,
    String? errorCode,
  }) => AskBookState(
    status: status ?? this.status,
    answer: answer ?? this.answer,
    citations: citations ?? this.citations,
    confidence: confidence ?? this.confidence,
    conversationId: conversationId ?? this.conversationId,
    usage: usage ?? this.usage,
    errorCode: errorCode ?? this.errorCode,
  );
}

@riverpod
class AskBookController extends _$AskBookController {
  StreamSubscription<AskStreamEvent>? _subscription;

  @override
  AskBookState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const AskBookState();
  }

  /// Ask [request] and stream the grounded answer. Resolves when the stream ends.
  Future<void> ask(AskBookRequest request) {
    _subscription?.cancel();
    state = const AskBookState(status: AskStatus.streaming);
    final Completer<void> completer = Completer<void>();

    _subscription = ref
        .read(aiRepositoryProvider)
        .streamAsk(request)
        .listen(
          _onEvent,
          onError: (Object error) {
            state = state.copyWith(
              status: AskStatus.error,
              errorCode: error is ApiException
                  ? error.code
                  : ErrorCodes.aiStreamError,
            );
            if (!completer.isCompleted) completer.complete();
          },
          onDone: () {
            if (state.status == AskStatus.streaming) {
              state = state.copyWith(status: AskStatus.done);
            }
            if (!completer.isCompleted) completer.complete();
          },
          cancelOnError: true,
        );
    return completer.future;
  }

  void cancel() {
    _subscription?.cancel();
    _subscription = null;
    state = state.copyWith(status: AskStatus.cancelled);
  }

  void reset() => state = const AskBookState();

  void _onEvent(AskStreamEvent event) {
    switch (event.type) {
      case AskStreamEventType.sources:
        state = state.copyWith(
          citations: event.citations,
          confidence: event.confidence ?? 0,
        );
      case AskStreamEventType.start:
        state = state.copyWith(
          status: AskStatus.streaming,
          conversationId: event.conversationId,
        );
      case AskStreamEventType.delta:
        state = state.copyWith(answer: state.answer + (event.text ?? ''));
      case AskStreamEventType.done:
        state = state.copyWith(
          status: AskStatus.done,
          usage: event.usage,
          conversationId: event.conversationId ?? state.conversationId,
        );
      case AskStreamEventType.error:
        state = state.copyWith(
          status: AskStatus.error,
          errorCode: event.code ?? ErrorCodes.aiStreamError,
        );
      case AskStreamEventType.unknown:
        break;
    }
  }
}

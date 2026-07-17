/// The AI streaming controller (AF1) — a Riverpod notifier that drives token-by-
/// token completion state. Streamed tokens are transient UI state; the settled
/// conversation is server-persisted and read back separately (docs/34 §9).
/// Cancellation cancels the subscription, which aborts the underlying request.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/api_exception.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_stream_event.dart';
import '../providers/ai_providers.dart';

part 'ai_stream_controller.g.dart';

enum AiStreamStatus { idle, streaming, done, error, cancelled }

/// Immutable streaming state (the accumulating assistant text + terminal info).
class AiStreamState {
  const AiStreamState({
    this.status = AiStreamStatus.idle,
    this.text = '',
    this.model,
    this.provider,
    this.errorCode,
    this.usage,
  });

  final AiStreamStatus status;
  final String text;
  final String? model;
  final String? provider;
  final String? errorCode;
  final AiTokenUsage? usage;

  AiStreamState copyWith({
    AiStreamStatus? status,
    String? text,
    String? model,
    String? provider,
    String? errorCode,
    AiTokenUsage? usage,
  }) => AiStreamState(
    status: status ?? this.status,
    text: text ?? this.text,
    model: model ?? this.model,
    provider: provider ?? this.provider,
    errorCode: errorCode ?? this.errorCode,
    usage: usage ?? this.usage,
  );
}

@riverpod
class AiStreamController extends _$AiStreamController {
  StreamSubscription<AiStreamEvent>? _subscription;

  @override
  AiStreamState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const AiStreamState();
  }

  /// Start streaming a completion; the future resolves when the stream ends.
  Future<void> start(AiCompletionRequest request) {
    _subscription?.cancel();
    state = const AiStreamState(status: AiStreamStatus.streaming);
    final Completer<void> completer = Completer<void>();
    _subscription = ref.read(aiRepositoryProvider).streamCompletion(request).listen(
      _onEvent,
      onError: (Object error) {
        state = state.copyWith(
          status: AiStreamStatus.error,
          errorCode: error is ApiException ? error.code : ErrorCodes.aiStreamError,
        );
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        if (state.status == AiStreamStatus.streaming) {
          state = state.copyWith(status: AiStreamStatus.done);
        }
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );
    return completer.future;
  }

  /// Cancel the in-flight stream (aborts the request).
  void cancel() {
    _subscription?.cancel();
    _subscription = null;
    state = state.copyWith(status: AiStreamStatus.cancelled);
  }

  void reset() => state = const AiStreamState();

  void _onEvent(AiStreamEvent event) {
    switch (event.type) {
      case AiStreamEventType.start:
        state = state.copyWith(model: event.model, provider: event.provider);
      case AiStreamEventType.delta:
        state = state.copyWith(text: state.text + (event.text ?? ''));
      case AiStreamEventType.done:
        state = state.copyWith(status: AiStreamStatus.done, usage: event.usage);
      case AiStreamEventType.error:
        state = state.copyWith(
          status: AiStreamStatus.error,
          errorCode: event.code ?? ErrorCodes.aiStreamError,
        );
      case AiStreamEventType.progress:
      case AiStreamEventType.unknown:
        break;
    }
  }
}

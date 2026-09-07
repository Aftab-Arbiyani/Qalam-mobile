/// The Polish session controller (AF2). Orchestrates one in-editor Polish
/// interaction: it builds the completion request from a [WritingAction] +
/// [AiWritingContext], DELEGATES the token stream to the reused AF1
/// [aiStreamControllerProvider] (no duplicated streaming/state), and — when the
/// stream settles — packages the result into an immutable [AiSuggestion]. It never
/// touches the document; applying a suggestion is the editor's job (docs/34, AF2).
/// Global autoDispose (one open editor at a time, like the selection controller).
///
/// **D5** removed the two things that made a request stateful: the free-form
/// instruction (there is no free-form action any more) and the `conversationId`
/// binding (B2 deleted the server's conversation layer, and the field is accepted-
/// and-ignored on the wire only until Phase V). Every completion is now standalone.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/value_objects/ai_feature_ids.dart';
import '../../domain/value_objects/ai_writing_context.dart';
import '../../domain/value_objects/writing_action.dart';
import 'ai_stream_controller.dart';

part 'assistant_session_controller.g.dart';

enum AssistantPhase { idle, streaming, ready, error }

class AssistantSessionState {
  const AssistantSessionState({
    this.phase = AssistantPhase.idle,
    this.action,
    this.suggestion,
    this.errorCode,
  });

  final AssistantPhase phase;
  final WritingAction? action;

  /// The finalized suggestion (present only when [phase] is ready). Immutable.
  final AiSuggestion? suggestion;
  final String? errorCode;

  bool get isBusy => phase == AssistantPhase.streaming;
  bool get hasSuggestion => suggestion != null;

  AssistantSessionState copyWith({
    AssistantPhase? phase,
    WritingAction? action,
    AiSuggestion? suggestion,
    String? errorCode,
    bool clearSuggestion = false,
    bool clearError = false,
  }) => AssistantSessionState(
    phase: phase ?? this.phase,
    action: action ?? this.action,
    suggestion: clearSuggestion ? null : (suggestion ?? this.suggestion),
    errorCode: clearError ? null : (errorCode ?? this.errorCode),
  );
}

@riverpod
class AssistantSessionController extends _$AssistantSessionController {
  WritingAction? _lastAction;
  AiWritingContext? _lastContext;

  @override
  AssistantSessionState build() {
    // Hold the stream controller open for as long as a session exists.
    //
    // [runAction] only ever `read`s it, which mounts it without depending on it — and
    // it is `autoDispose`, so with no listener it can be swept between starting the
    // stream and the sheet's first rebuild (the only place that watches it). Its
    // `onDispose` cancels the subscription, so neither an event nor `onDone` ever
    // arrives: the run hangs in `streaming` forever with an empty buffer, and a second
    // instance is mounted for the view. The window is invisible against a real network
    // but wide open against a fake that answers in microtasks, which is how a widget
    // test found it. Listening is the honest statement of the dependency — this
    // controller does not merely read the stream, it needs it alive.
    ref.listen(aiStreamControllerProvider, (_, _) {});
    return const AssistantSessionState();
  }

  /// Run a Polish action, streaming the result. The operand text — the selection if
  /// there is one, else the whole chapter — is the message.
  Future<void> runAction(WritingAction action, AiWritingContext context) async {
    _lastAction = action;
    _lastContext = context;

    final String message = context.operand;
    if (message.isEmpty) {
      state = state.copyWith(
        phase: AssistantPhase.error,
        action: action,
        errorCode: 'AI_EMPTY_INPUT',
        clearSuggestion: true,
        clearError: true,
      );
      return;
    }

    final AiCompletionRequest request = AiCompletionRequest(
      feature: AiFeatureIds.writingAssistant,
      promptKey: action.promptKey,
      promptVariables: action.promptVariables.isEmpty
          ? null
          : action.promptVariables,
      messages: <AiMessage>[AiMessage(role: 'user', content: message)],
      context: context.contextRequests(),
    );

    state = AssistantSessionState(
      phase: AssistantPhase.streaming,
      action: action,
    );
    ref.read(aiStreamControllerProvider.notifier).reset();
    await ref.read(aiStreamControllerProvider.notifier).start(request);

    final AiStreamState streamState = ref.read(aiStreamControllerProvider);
    _finalize(action, context, message, streamState);
  }

  /// Re-run the last action ("Try again").
  Future<void> regenerate() async {
    final WritingAction? action = _lastAction;
    final AiWritingContext? context = _lastContext;
    if (action == null || context == null) return;
    await runAction(action, context);
  }

  /// Cancel the in-flight generation (aborts the request).
  void cancel() {
    ref.read(aiStreamControllerProvider.notifier).cancel();
    state = state.copyWith(phase: AssistantPhase.idle, clearSuggestion: true);
  }

  /// Mark the current suggestion as applied (after the editor accepts it).
  void markApplied() {
    final AiSuggestion? current = state.suggestion;
    if (current == null) return;
    state = state.copyWith(
      suggestion: current.withStatus(AiSuggestionStatus.applied),
    );
  }

  /// Discard the current suggestion (leaves the document untouched).
  void discard() {
    final AiSuggestion? current = state.suggestion;
    state = AssistantSessionState(
      suggestion: current?.withStatus(AiSuggestionStatus.discarded),
    ).copyWith(clearSuggestion: true);
  }

  void reset() {
    ref.read(aiStreamControllerProvider.notifier).reset();
    state = const AssistantSessionState();
  }

  void _finalize(
    WritingAction action,
    AiWritingContext context,
    String message,
    AiStreamState streamState,
  ) {
    switch (streamState.status) {
      case AiStreamStatus.done:
        final String content = streamState.text.trim();
        if (content.isEmpty) {
          state = state.copyWith(
            phase: AssistantPhase.error,
            errorCode: 'AI_EMPTY_OUTPUT',
          );
          return;
        }
        final AiSuggestion suggestion = AiSuggestion(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          sourceFeature: AiFeatureIds.writingAssistant,
          sourceLabel: action.label,
          promptKey: action.promptKey,
          contextSnapshot: <String, dynamic>{
            'action': action.kind.name,
            if (action.aspect != null) 'aspect': action.aspect!.name,
            'usedSelection': context.hasSelection,
            'language': context.language,
            if (context.genre != null) 'genre': context.genre,
          },
          content: content,
          // Every surviving action transforms an operand, so there is always an original
          // to diff against — `isContinuation` went with the generation actions (D5).
          originalText: context.operand,
          placement: action.defaultPlacement(
            hasSelection: context.hasSelection,
          ),
          createdAt: DateTime.now(),
          status: AiSuggestionStatus.ready,
          provider: streamState.provider ?? '',
          model: streamState.model ?? '',
          usage: streamState.usage,
        );
        state = AssistantSessionState(
          phase: AssistantPhase.ready,
          action: action,
          suggestion: suggestion,
        );
      case AiStreamStatus.error:
        state = state.copyWith(
          phase: AssistantPhase.error,
          errorCode: streamState.errorCode ?? 'AI_STREAM_ERROR',
        );
      case AiStreamStatus.cancelled:
        state = state.copyWith(
          phase: AssistantPhase.idle,
          clearSuggestion: true,
        );
      case AiStreamStatus.idle:
      case AiStreamStatus.streaming:
        state = state.copyWith(phase: AssistantPhase.idle);
    }
  }
}

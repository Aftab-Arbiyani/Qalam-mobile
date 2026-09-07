/// "Map this story" — the run controller (**D5**, AF3).
///
/// One batch that runs all five analyses server-side and folds each into the story's
/// knowledge graph. This is the client half of the trigger that had been missing since
/// AF3 shipped: the graph platform was complete and **no client could put anything in
/// it** (`platfrom/docs/48` §3.22d), so every Story Map view could only say "nothing
/// here yet".
///
/// Deliberately NOT modelled on [AiStreamController]. That one accumulates text; this
/// one tracks a step counter and, on success, tells the views to refetch — a mapped
/// story is a change to server state, not a message.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/api_exception.dart';
import '../../domain/entities/story_map_event.dart';
import '../providers/ai_providers.dart';

part 'story_map_controller.g.dart';

/// How many analyses one full map run spends. Mirrors the server's
/// `STORY_MAP_ANALYSIS_COUNT`; used to price the run before starting it.
const int kStoryMapAnalysisCount = 5;

enum StoryMapPhase { idle, running, done, error }

class StoryMapState {
  const StoryMapState({
    this.phase = StoryMapPhase.idle,
    this.step = 0,
    this.total = kStoryMapAnalysisCount,
    this.analysis,
    this.completed = const <String>[],
    this.errorCode,
  });

  final StoryMapPhase phase;

  /// 1-based position of the analysis in flight, 0 before the first `progress`.
  final int step;
  final int total;

  /// The `StoryAnalysisKind` wire value currently running.
  final String? analysis;

  /// What the run folded in. Populated on `done`, and short of [total] when the run
  /// stopped early — whatever landed stays in the graph.
  final List<String> completed;
  final String? errorCode;

  bool get isRunning => phase == StoryMapPhase.running;

  /// How many analyses actually landed in the graph.
  ///
  /// On `done` the server names them. On a failure it does not, so this reads the step
  /// counter instead — and the arithmetic turns on WHEN the server emits `progress`: it
  /// yields the event *before* running that analysis, so a run that died at step N
  /// folded in N-1. Reading it as N would tell the writer one more analysis survived
  /// than did, and they would skip re-running the one that failed.
  int get foldedIn =>
      completed.isNotEmpty ? completed.length : (step > 0 ? step - 1 : 0);
}

@riverpod
class StoryMapController extends _$StoryMapController {
  StreamSubscription<StoryMapEvent>? _sub;

  @override
  StoryMapState build() {
    ref.onDispose(() => unawaited(_sub?.cancel()));
    return const StoryMapState();
  }

  /// Run the map for [storyId] over [content].
  ///
  /// The text comes from the caller rather than from the server's copy of the piece,
  /// exactly as the endpoint's DTO intends: a writer in the editor has the draft in
  /// hand and it may not be saved yet. That is also why a deep-linked Story Map screen
  /// cannot offer this — it has a story id and no text.
  Future<void> run(
    String storyId, {
    required String content,
    String? storyTitle,
  }) async {
    if (state.isRunning) return;
    await _sub?.cancel();
    state = const StoryMapState(phase: StoryMapPhase.running);

    final Completer<void> finished = Completer<void>();
    _sub = ref
        .read(aiRepositoryProvider)
        .mapStory(storyId, content: content, storyTitle: storyTitle)
        .listen(
          _onEvent,
          onError: (Object error) {
            state = StoryMapState(
              phase: StoryMapPhase.error,
              step: state.step,
              completed: state.completed,
              errorCode: _codeOf(error),
            );
            if (!finished.isCompleted) finished.complete();
          },
          onDone: () {
            // A stream that ends without `done` — the socket dropped mid-run — is a
            // failure, not a success. Reporting it as one would leave the writer
            // believing a partly-built graph is finished.
            if (state.phase == StoryMapPhase.running) {
              state = StoryMapState(
                phase: StoryMapPhase.error,
                step: state.step,
                completed: state.completed,
                errorCode: 'STORY_MAP_FAILED',
              );
            }
            if (!finished.isCompleted) finished.complete();
          },
          cancelOnError: true,
        );
    await finished.future;
  }

  /// Stop the run. The server notices the closed connection and stops spending
  /// analyses; everything already folded into the graph stays there.
  void cancel() {
    unawaited(_sub?.cancel());
    _sub = null;
    state = const StoryMapState();
  }

  void reset() => state = const StoryMapState();

  void _onEvent(StoryMapEvent event) {
    switch (event.type) {
      case StoryMapEventType.progress:
        state = StoryMapState(
          phase: StoryMapPhase.running,
          step: event.step ?? state.step,
          total: event.total ?? state.total,
          analysis: event.analysis,
          completed: state.completed,
        );
      case StoryMapEventType.done:
        state = StoryMapState(
          phase: StoryMapPhase.done,
          step: state.total,
          total: state.total,
          completed: event.completed,
        );
      case StoryMapEventType.error:
        state = StoryMapState(
          phase: StoryMapPhase.error,
          step: state.step,
          completed: state.completed,
          errorCode: event.code ?? 'STORY_MAP_FAILED',
        );
      case StoryMapEventType.unknown:
        break;
    }
  }

  /// A transport-level failure (a 402/429 before the stream opened, an offline
  /// pre-check) arrives as an [ApiException] carrying the real domain code — the same
  /// route `AiStreamController` takes. Keeping the code is what lets `AiErrorCopy`
  /// pick the allowance remedy over a generic "something went wrong".
  static String _codeOf(Object error) =>
      error is ApiException ? error.code : 'STORY_MAP_FAILED';
}

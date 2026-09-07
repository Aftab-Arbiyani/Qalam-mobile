/// "Map this story" streaming events (**D5**, AF3).
///
/// `POST /story-intelligence/:storyId/map/stream` runs all five analysis kinds in one
/// action and folds each into the story's knowledge graph as it lands. Before D5 the
/// graph was **hollow**: `POST /story-intelligence/:storyId/analyze` existed and no
/// client anywhere could reach it (`platfrom/docs/48` §3.22d), so Story Map's own
/// screen could only ever say "nothing here yet". This is the trigger that fills it,
/// and it is why Story Map can headline the Pro tier.
///
/// The wire discriminator is `type`, not `kind`: the server strips its internal `kind`
/// before sending, because `sendSse` already stamps the event name onto the payload as
/// `type` and two names for one discriminator is how a client ends up trusting the
/// wrong half.
///
/// Plain immutable value types with `fromJson`, no codegen — the same shape as
/// [AiStreamEvent], which this deliberately does NOT reuse: a completion stream carries
/// text deltas and token usage, a map run carries a step counter, and collapsing them
/// would put six always-null fields on both.
library;

import '../../../../core/utils/typedefs.dart';

/// The kinds of map-run event (`unknown` = forward-compatible).
enum StoryMapEventType { progress, done, error, unknown }

class StoryMapEvent {
  const StoryMapEvent({
    required this.type,
    this.step,
    this.total,
    this.analysis,
    this.completed = const <String>[],
    this.code,
    this.message,
  });

  final StoryMapEventType type;

  /// 1-based position of the analysis that just completed, and how many there are.
  final int? step;
  final int? total;

  /// The `StoryAnalysisKind` wire value this step covered.
  final String? analysis;

  /// On `done`: every kind the run actually folded in. Short of [total] when the run
  /// stopped early — the graph keeps whatever it managed to build.
  final List<String> completed;

  /// On `error`: a real domain code. `QUOTA_EXCEEDED` is the one worth naming — the
  /// server reserves the whole run up front, so a writer without enough allowance is
  /// refused before the first call rather than left with a half-built graph.
  final String? code;
  final String? message;

  factory StoryMapEvent.fromJson(Json json) => StoryMapEvent(
    type: _typeFromWire(json['type'] as String?),
    step: (json['step'] as num?)?.toInt(),
    total: (json['total'] as num?)?.toInt(),
    analysis: json['analysis'] as String?,
    completed:
        (json['completed'] as List?)?.whereType<String>().toList(
          growable: false,
        ) ??
        const <String>[],
    code: json['code'] as String?,
    message: json['message'] as String?,
  );

  static StoryMapEventType _typeFromWire(String? wire) => switch (wire) {
    'progress' => StoryMapEventType.progress,
    'done' => StoryMapEventType.done,
    'error' => StoryMapEventType.error,
    _ => StoryMapEventType.unknown,
  };
}

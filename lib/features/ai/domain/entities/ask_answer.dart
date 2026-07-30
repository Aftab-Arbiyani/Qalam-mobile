/// AF4 "Ask My Book" entities — grounded answers that cite retrieved evidence, plus
/// the streaming event the SSE endpoint emits (docs 36). Plain value types with
/// `fromJson` (matching the AI feature's stream-event style). The Ask stream reuses
/// the shared `ApiClient.streamSse` transport; only the event mapping is AF4-specific
/// (it adds a `sources` event carrying citations before the token deltas).
library;

import '../../../../core/utils/typedefs.dart';
import 'ai_stream_event.dart';
import 'retrieval_json.dart';

/// One piece of evidence an answer is grounded in.
class AskCitation {
  const AskCitation({
    required this.ref,
    required this.label,
    required this.quote,
    this.nodeType,
  });

  final String ref;
  final String label;
  final String quote;
  final String? nodeType;

  factory AskCitation.fromJson(Json json) => AskCitation(
    ref: rjString(json['ref']),
    label: rjString(json['label']),
    quote: rjString(json['quote']),
    nodeType: json['nodeType'] as String?,
  );
}

/// A buffered (non-streaming) Ask answer.
class AskBookAnswer {
  const AskBookAnswer({
    required this.storyId,
    required this.scope,
    required this.answer,
    required this.citations,
    required this.confidence,
    required this.usage,
    required this.estimatedCostUsd,
    required this.conversationId,
  });

  final String storyId;
  final String scope;
  final String answer;
  final List<AskCitation> citations;
  final double confidence;
  final AiTokenUsage usage;
  final double estimatedCostUsd;
  final String? conversationId;

  factory AskBookAnswer.fromJson(Json json) => AskBookAnswer(
    storyId: rjString(json['storyId']),
    scope: rjString(json['scope']),
    answer: rjString(json['answer']),
    citations: rjList(json['citations'], AskCitation.fromJson),
    confidence: rjDouble(json['confidence']),
    usage: json['usage'] is Map
        ? AiTokenUsage.fromJson(Json.from(json['usage'] as Map))
        : const AiTokenUsage(inputTokens: 0, outputTokens: 0, totalTokens: 0),
    estimatedCostUsd: rjDouble(json['estimatedCostUsd']),
    conversationId: json['conversationId'] as String?,
  );
}

/// The kinds of Ask stream event. `sources` (citations) precedes the token deltas;
/// `unknown` keeps the client forward-compatible.
enum AskStreamEventType { sources, start, delta, done, error, unknown }

/// One streamed event from `POST /ai/ask/stream` (the `type` field in the SSE `data:`).
class AskStreamEvent {
  const AskStreamEvent({
    required this.type,
    this.text,
    this.citations = const <AskCitation>[],
    this.confidence,
    this.conversationId,
    this.usage,
    this.estimatedCostUsd,
    this.code,
    this.message,
  });

  final AskStreamEventType type;
  final String? text;
  final List<AskCitation> citations;
  final double? confidence;
  final String? conversationId;
  final AiTokenUsage? usage;
  final double? estimatedCostUsd;
  final String? code;
  final String? message;

  factory AskStreamEvent.fromJson(Json json) {
    final Object? usage = json['usage'];
    return AskStreamEvent(
      type: _typeFromWire(json['type'] as String?),
      text: json['text'] as String?,
      citations: rjList(json['citations'], AskCitation.fromJson),
      confidence: (json['confidence'] as num?)?.toDouble(),
      conversationId: json['conversationId'] as String?,
      usage: usage is Map ? AiTokenUsage.fromJson(Json.from(usage)) : null,
      estimatedCostUsd: (json['estimatedCostUsd'] as num?)?.toDouble(),
      code: json['code'] as String?,
      message: json['message'] as String?,
    );
  }

  static AskStreamEventType _typeFromWire(String? wire) => switch (wire) {
    'sources' => AskStreamEventType.sources,
    'start' => AskStreamEventType.start,
    'delta' => AskStreamEventType.delta,
    'done' => AskStreamEventType.done,
    'error' => AskStreamEventType.error,
    _ => AskStreamEventType.unknown,
  };
}

/// AI streaming domain types (AF1). Plain immutable value types with `fromJson`
/// (no codegen) — the provider-independent SSE event the backend emits, mapped by
/// the AI data source. See docs/34 §5.
library;

import '../../../../core/utils/typedefs.dart';

/// Normalized token usage for a call.
class AiTokenUsage {
  const AiTokenUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
  });

  final int inputTokens;
  final int outputTokens;
  final int totalTokens;

  factory AiTokenUsage.fromJson(Json json) => AiTokenUsage(
    inputTokens: (json['inputTokens'] as num?)?.toInt() ?? 0,
    outputTokens: (json['outputTokens'] as num?)?.toInt() ?? 0,
    totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
  );
}

/// The kinds of server-sent stream event (`unknown` = forward-compatible).
enum AiStreamEventType { start, delta, progress, done, error, unknown }

/// One streamed event from `/ai/completions/stream`.
class AiStreamEvent {
  const AiStreamEvent({
    required this.type,
    this.text,
    this.model,
    this.provider,
    this.conversationId,
    this.finishReason,
    this.usage,
    this.code,
    this.message,
  });

  final AiStreamEventType type;
  final String? text;
  final String? model;
  final String? provider;
  final String? conversationId;
  final String? finishReason;
  final AiTokenUsage? usage;
  final String? code;
  final String? message;

  factory AiStreamEvent.fromJson(Json json) {
    final Object? usage = json['usage'];
    return AiStreamEvent(
      type: _typeFromWire(json['type'] as String?),
      text: json['text'] as String?,
      model: json['model'] as String?,
      provider: json['provider'] as String?,
      conversationId: json['conversationId'] as String?,
      finishReason: json['finishReason'] as String?,
      usage: usage is Map ? AiTokenUsage.fromJson(Json.from(usage)) : null,
      code: json['code'] as String?,
      message: json['message'] as String?,
    );
  }

  static AiStreamEventType _typeFromWire(String? wire) => switch (wire) {
    'start' => AiStreamEventType.start,
    'delta' => AiStreamEventType.delta,
    'progress' => AiStreamEventType.progress,
    'done' => AiStreamEventType.done,
    'error' => AiStreamEventType.error,
    _ => AiStreamEventType.unknown,
  };
}

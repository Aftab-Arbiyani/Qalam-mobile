/// AI completion request/result domain types (AF1). Provider-agnostic; the client
/// never talks to a provider (docs/34).
library;

import '../../../../core/utils/typedefs.dart';
import 'ai_stream_event.dart';

/// One chat message on a completion request.
class AiMessage {
  const AiMessage({required this.role, required this.content});

  final String role;
  final String content;

  Json toJson() => <String, dynamic>{'role': role, 'content': content};
}

/// A named context request the server resolves via a context provider (docs/34 §4).
/// The client passes the text/metadata as [params] (offline-safe — the server never
/// reads the unsaved draft); an unregistered [type] is silently dropped server-side.
class AiContextRequest {
  const AiContextRequest({required this.type, this.params});

  final String type;
  final Json? params;

  Json toJson() => <String, dynamic>{
    'type': type,
    if (params != null) 'params': params,
  };
}

/// A completion request. Reference a prompt template by key OR pass raw messages;
/// the server assembles context + prompt. `params` are per-call overrides.
class AiCompletionRequest {
  const AiCompletionRequest({
    required this.feature,
    this.conversationId,
    this.promptKey,
    this.promptVersion,
    this.promptVariables,
    this.messages,
    this.context,
    this.params,
  });

  final String feature;
  final String? conversationId;
  final String? promptKey;
  final int? promptVersion;
  final Json? promptVariables;
  final List<AiMessage>? messages;

  /// Named context requests assembled server-side into the prompt (docs/34 §4).
  final List<AiContextRequest>? context;
  final Json? params;

  Json toJson() => <String, dynamic>{
    'feature': feature,
    if (conversationId != null) 'conversationId': conversationId,
    if (promptKey != null) 'promptKey': promptKey,
    if (promptVersion != null) 'promptVersion': promptVersion,
    if (promptVariables != null) 'promptVariables': promptVariables,
    if (messages != null)
      'messages': messages!.map((AiMessage m) => m.toJson()).toList(growable: false),
    if (context != null && context!.isNotEmpty)
      'context': context!.map((AiContextRequest c) => c.toJson()).toList(growable: false),
    if (params != null) 'params': params,
  };
}

/// A buffered (non-streamed) completion result.
class AiCompletionResult {
  const AiCompletionResult({
    required this.content,
    required this.provider,
    required this.model,
    required this.finishReason,
    required this.estimatedCostUsd,
    this.conversationId,
    this.usage,
  });

  final String content;
  final String provider;
  final String model;
  final String finishReason;
  final double estimatedCostUsd;
  final String? conversationId;
  final AiTokenUsage? usage;

  factory AiCompletionResult.fromJson(Json json) {
    final Object? message = json['message'];
    final Object? usage = json['usage'];
    return AiCompletionResult(
      content: message is Map ? (message['content'] as String? ?? '') : '',
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      finishReason: json['finishReason'] as String? ?? 'stop',
      estimatedCostUsd: (json['estimatedCostUsd'] as num?)?.toDouble() ?? 0,
      conversationId: json['conversationId'] as String?,
      usage: usage is Map ? AiTokenUsage.fromJson(Json.from(usage)) : null,
    );
  }
}

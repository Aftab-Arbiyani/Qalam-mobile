/// AI conversation domain types (AF2) — the client view of the server-owned
/// `ai_conversations` + `ai_messages` (docs/34 §6). Plain immutable value types
/// with `fromJson` (no codegen), mirroring the AF1 completion/stream entities.
/// Conversations are the platform's memory: history, continuation, and export all
/// go through these — no feature re-implements conversation storage.
library;

import '../../../../core/utils/typedefs.dart';
import 'ai_stream_event.dart';

/// Conversation lifecycle (soft state; archived is hidden from the default list).
enum AiConversationStatus {
  active,
  archived;

  String get wire => name;

  static AiConversationStatus fromWire(String? wire) =>
      wire == 'archived' ? AiConversationStatus.archived : AiConversationStatus.active;
}

/// One stored message in a conversation (append-only server-side). Assistant
/// messages carry token [usage]; user/system messages do not.
class AiConversationMessage {
  const AiConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.usage,
  });

  final String id;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime createdAt;
  final AiTokenUsage? usage;

  bool get isAssistant => role == 'assistant';
  bool get isUser => role == 'user';

  factory AiConversationMessage.fromJson(Json json) {
    final Object? usage = json['usage'];
    return AiConversationMessage(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? 'assistant',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      usage: usage is Map ? AiTokenUsage.fromJson(Json.from(usage)) : null,
    );
  }
}

/// A conversation list-row (no messages).
class AiConversationSummary {
  const AiConversationSummary({
    required this.id,
    required this.title,
    required this.feature,
    required this.status,
    required this.messageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? title;
  final String feature;
  final AiConversationStatus status;
  final int messageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// A human title, falling back to a stable placeholder when the server has none.
  String get displayTitle {
    final String? t = title?.trim();
    return (t == null || t.isEmpty) ? 'Untitled conversation' : t;
  }

  AiConversationSummary copyWith({String? title, AiConversationStatus? status}) =>
      AiConversationSummary(
        id: id,
        title: title ?? this.title,
        feature: feature,
        status: status ?? this.status,
        messageCount: messageCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory AiConversationSummary.fromJson(Json json) => AiConversationSummary(
        id: json['id'] as String? ?? '',
        title: json['title'] as String?,
        feature: json['feature'] as String? ?? '',
        status: AiConversationStatus.fromWire(json['status'] as String?),
        messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

/// A full conversation with its message history.
class AiConversationDetail {
  const AiConversationDetail({required this.summary, required this.messages});

  final AiConversationSummary summary;
  final List<AiConversationMessage> messages;

  factory AiConversationDetail.fromJson(Json json) => AiConversationDetail(
        summary: AiConversationSummary.fromJson(json),
        messages: (json['messages'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> m) => AiConversationMessage.fromJson(Json.from(m)))
            .toList(growable: false),
      );
}

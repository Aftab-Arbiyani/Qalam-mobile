/// Presence entry (AF6) — one collaborator's live presence on a story
/// (`GET/POST /stories/{id}/presence`). Ephemeral, server-owned; the client renders
/// avatars + a typing hint and sends heartbeats.
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

class PresenceEntry {
  const PresenceEntry({
    required this.userId,
    required this.state,
    this.displayName,
    this.avatarKey,
    this.blockId,
    this.lastSeenAt,
  });

  final String userId;
  final String state;
  final String? displayName;
  final String? avatarKey;
  final String? blockId;
  final DateTime? lastSeenAt;

  bool get isTyping => state == PresenceState.typing;
  bool get isActive => state == PresenceState.active;

  String get label => displayName ?? userId;

  factory PresenceEntry.fromJson(Json json) => PresenceEntry(
    userId: json['userId'] as String? ?? '',
    state: json['state'] as String? ?? PresenceState.active,
    displayName: json['displayName'] as String? ?? json['name'] as String?,
    avatarKey: json['avatarKey'] as String?,
    blockId: json['blockId'] as String?,
    lastSeenAt: _date(json['lastSeenAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

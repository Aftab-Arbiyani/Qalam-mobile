/// Story member entity (AF6) — one collaborator on a story (`GET /stories/{id}/members`).
/// The server owns membership; the client renders roles + drives role/removal actions
/// that the policy engine authorizes.
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

class StoryMember {
  const StoryMember({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.role,
    this.displayName,
    this.username,
    this.avatarKey,
    this.invitedBy,
    this.joinedAt,
  });

  /// Membership id (falls back to [userId] when the wire omits it).
  final String id;
  final String storyId;
  final String userId;
  final String role;
  final String? displayName;
  final String? username;
  final String? avatarKey;
  final String? invitedBy;
  final DateTime? joinedAt;

  bool get isOwner => role == StoryRole.owner;

  /// A best-effort display handle (name, else @username, else a short id).
  String get label => displayName ?? (username != null ? '@$username' : userId);

  factory StoryMember.fromJson(Json json) {
    final String userId =
        json['userId'] as String? ?? json['id'] as String? ?? '';
    return StoryMember(
      id: json['id'] as String? ?? userId,
      storyId: json['storyId'] as String? ?? '',
      userId: userId,
      role: json['role'] as String? ?? StoryRole.betaReader,
      displayName: json['displayName'] as String? ?? json['name'] as String?,
      username: json['username'] as String?,
      avatarKey: json['avatarKey'] as String? ?? json['avatarUrl'] as String?,
      invitedBy: json['invitedBy'] as String?,
      joinedAt: _date(json['joinedAt']),
    );
  }
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

/// Block entry entity (AF6) — one user the current user has blocked or muted
/// (`GET /me/blocks`). The server owns the relationship; the client lists it and
/// drives block / unblock / mute / unmute.
library;

import '../../../../core/utils/typedefs.dart';

class BlockEntry {
  const BlockEntry({
    required this.id,
    required this.userId,
    required this.kind,
    this.username,
    this.displayName,
    this.avatarKey,
    this.createdAt,
  });

  /// Relationship id (falls back to [userId] when the wire omits it).
  final String id;
  final String userId;

  /// `block` (full) or `mute` (feed-only). Defaults to `block`.
  final String kind;
  final String? username;
  final String? displayName;
  final String? avatarKey;
  final DateTime? createdAt;

  bool get isMute => kind == 'mute';

  String get label => displayName ?? (username != null ? '@$username' : userId);

  factory BlockEntry.fromJson(Json json) {
    final String userId =
        json['userId'] as String? ?? json['id'] as String? ?? '';
    return BlockEntry(
      id: json['id'] as String? ?? userId,
      userId: userId,
      kind: json['kind'] as String? ?? 'block',
      username: json['username'] as String?,
      displayName: json['displayName'] as String? ?? json['name'] as String?,
      avatarKey: json['avatarKey'] as String?,
      createdAt: _date(json['createdAt']),
    );
  }
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

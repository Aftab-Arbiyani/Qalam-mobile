/// Block entry entity (AF6) — one user the current user has blocked or muted
/// (`GET /me/blocks`). The server owns the relationship; the client lists it and
/// drives block / unblock / mute / unmute.
library;

import '../../../../core/utils/typedefs.dart';

/// Mirrors `BlockDto` — `{id, blockerId, blockedId, kind, createdAt}`.
///
/// It used to resolve the blocked user as `json['userId'] ?? json['id']`. There is no
/// `userId` on the wire and `blockedId` was never read, so it silently fell through to
/// the **block row's own id**. Both are UUIDs, so `DELETE /users/{id}/block` reached
/// the service and 404'd `BLOCK_NOT_FOUND` — unblocking could never work
/// (defect **T-1**, `docs/56` §2.3). The `username`/`displayName`/`avatarKey` it also
/// parsed are not in the DTO; the wire still carries ids only. Since B3 a UI resolves
/// the person from `blockedId` (`ActorName`, `platfrom/docs/45` §4) instead of showing
/// a shortened id — which is now only the fallback when that lookup cannot answer.
class BlockEntry {
  const BlockEntry({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.kind,
    this.createdAt,
  });

  /// The block relationship's id — NOT the user. Never pass this to
  /// `/users/{id}/block`; use [blockedId].
  final String id;
  final String blockerId;

  /// The user who was blocked or muted — the id the block/mute routes take.
  final String blockedId;

  /// `block` (full) or `mute` (feed-only). Defaults to `block`.
  final String kind;
  final DateTime? createdAt;

  bool get isMute => kind == 'mute';

  factory BlockEntry.fromJson(Json json) => BlockEntry(
    id: json['id'] as String? ?? '',
    blockerId: json['blockerId'] as String? ?? '',
    blockedId: json['blockedId'] as String? ?? '',
    kind: json['kind'] as String? ?? 'block',
    createdAt: _date(json['createdAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

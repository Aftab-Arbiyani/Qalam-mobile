/// Story invitation entity (AF6) — an outstanding or resolved invite to collaborate
/// (`GET /stories/{id}/invitations`, `GET /me/invitations`). The server owns the
/// lifecycle; the client renders it and drives accept / decline / revoke.
///
/// Mirrors `InvitationDto` **field for field**. It previously carried `inviteeEmail`,
/// `inviteeUserId`, `invitedByName` and `storyTitle`, none of which the wire has ever sent — the
/// same email-shaped assumption that made every invitation 400 (defect **M-1**,
/// `platfrom/docs/48` §3.1). They parsed to null forever, so the screens that displayed them showed
/// nothing. The wire gives **ids**, not names: `inviterId` and `inviteeId` — which B3's by-id
/// profile lookup turns into a person at render time (`ActorName`, `platfrom/docs/45` §4).
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

class StoryInvitation {
  const StoryInvitation({
    required this.id,
    required this.storyId,
    required this.role,
    required this.status,
    this.inviterId,
    this.inviteeId,
    this.createdAt,
    this.expiresAt,
    this.respondedAt,
  });

  final String id;
  final String storyId;
  final String role;
  final String status;

  /// Who sent it, and who it is for — **ids**; there is no by-id profile lookup, so a UI shows a
  /// shortened id unless it already knows the handle from context.
  final String? inviterId;
  final String? inviteeId;

  final DateTime? createdAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;

  bool get isPending => status == InvitationStatus.pending;
  bool get isExpired => status == InvitationStatus.expired;

  factory StoryInvitation.fromJson(Json json) => StoryInvitation(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    role: json['role'] as String? ?? StoryRole.betaReader,
    status: json['status'] as String? ?? InvitationStatus.pending,
    inviterId: json['inviterId'] as String?,
    inviteeId: json['inviteeId'] as String?,
    createdAt: _date(json['createdAt']),
    expiresAt: _date(json['expiresAt']),
    respondedAt: _date(json['respondedAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

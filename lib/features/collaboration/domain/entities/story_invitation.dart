/// Story invitation entity (AF6) — an outstanding or resolved invite to collaborate
/// (`GET /stories/{id}/invitations`, `GET /me/invitations`). The server owns the
/// lifecycle; the client renders it and drives accept / decline / revoke.
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

class StoryInvitation {
  const StoryInvitation({
    required this.id,
    required this.storyId,
    required this.role,
    required this.status,
    this.storyTitle,
    this.inviteeEmail,
    this.inviteeUserId,
    this.invitedByName,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String storyId;
  final String role;
  final String status;
  final String? storyTitle;
  final String? inviteeEmail;
  final String? inviteeUserId;
  final String? invitedByName;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  bool get isPending => status == InvitationStatus.pending;
  bool get isExpired => status == InvitationStatus.expired;

  factory StoryInvitation.fromJson(Json json) => StoryInvitation(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    role: json['role'] as String? ?? StoryRole.betaReader,
    status: json['status'] as String? ?? InvitationStatus.pending,
    storyTitle: json['storyTitle'] as String? ?? json['title'] as String?,
    inviteeEmail: json['inviteeEmail'] as String? ?? json['email'] as String?,
    inviteeUserId: json['inviteeUserId'] as String?,
    invitedByName:
        json['invitedByName'] as String? ?? json['inviterName'] as String?,
    createdAt: _date(json['createdAt']),
    expiresAt: _date(json['expiresAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

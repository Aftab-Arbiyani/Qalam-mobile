/// Story member entity (AF6) — one collaborator on a story (`GET /stories/{id}/members`).
/// The server owns membership; the client renders roles + drives role/removal actions
/// that the policy engine authorizes.
library;

import '../../../../core/utils/typedefs.dart';
import '../../../../shared/util/short_actor_id.dart';
import 'collaboration_enums.dart';

/// Mirrors `MemberDto` — `{userId, role, invitedById, joinedAt}` and nothing else.
///
/// It used to parse `displayName`/`name`, `username`, `avatarKey`/`avatarUrl`,
/// `storyId` and `invitedBy` (the wire says **`invitedById`**). None of the name
/// fields exist on the wire, so `label` always fell through to the raw UUID and the
/// collaborators screen rendered ids where names belong (defect **C-9**,
/// `docs/56` §2.1). The backend has no by-id profile lookup — `GET /users/:username`
/// is by handle — so a client cannot resolve names here without a contract change.
/// Until `MemberDto` carries them, [label] is honest about showing an id.
class StoryMember {
  const StoryMember({
    required this.userId,
    required this.role,
    this.invitedById,
    this.joinedAt,
  });

  final String userId;
  final String role;

  /// Who invited them; null for the owner and for a directly-added member.
  final String? invitedById;

  /// Join time — null for the owner, whose row is synthesised from the piece author.
  final DateTime? joinedAt;

  bool get isOwner => role == StoryRole.owner;

  /// The name-less FALLBACK label. `MemberDto` carries no name, so this is a shortened
  /// id — clearly an id rather than a name. Since B3 the screens resolve the person by
  /// id instead (`ActorName`, `platfrom/docs/45` §4); this remains for a caller that has
  /// no `WidgetRef` and cannot look anything up.
  String get label => shortActorId(userId);

  factory StoryMember.fromJson(Json json) => StoryMember(
    userId: json['userId'] as String? ?? '',
    role: json['role'] as String? ?? StoryRole.betaReader,
    invitedById: json['invitedById'] as String?,
    joinedAt: _date(json['joinedAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

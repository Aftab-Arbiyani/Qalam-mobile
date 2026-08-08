/// Collaborator seat allowance (B6, `platfrom/docs/45` §4.11) — how many collaborators a
/// story may hold, by the plan of the author who **owns** it
/// (`GET /stories/{id}/collaborators/limit`).
library;

import '../../../../core/utils/typedefs.dart';

/// Mirrors `CollaboratorLimitDto`.
///
/// The allowance belongs to the STORY and is charged to whoever owns it: a Free author's
/// story has zero seats no matter who is doing the inviting, and a Free collaborator on a
/// Pro author's story costs that author a seat and nothing to themselves.
///
/// **[limit] inverts the usual plan-limit sentinel on purpose: `-1` is unlimited and `0`
/// is none.** Everywhere else in this product `0` means "no cap" — for seats, `0` is the
/// Free tier and means the opposite. Branch on [unlimited], never on `limit == 0`; that
/// test is exactly backwards here and would show a free story as uncapped, which is the
/// one way this row can silently invert its own rule.
class CollaboratorLimit {
  const CollaboratorLimit({
    required this.storyId,
    required this.members,
    required this.pendingInvitations,
    required this.used,
    required this.limit,
    required this.remaining,
    required this.unlimited,
    required this.canInvite,
  });

  final String storyId;

  /// Accepted collaborators. The owner is not one of them — the cap counts
  /// collaborators, not participants.
  final int members;

  /// Invitations still outstanding. Each holds a seat until it is answered, so a story
  /// can be full while its roster looks like it has room.
  final int pendingInvitations;

  /// Seats spent: [members] + [pendingInvitations].
  final int used;

  /// The owner's plan cap. `-1` unlimited, `0` none, `n` seats.
  final int limit;

  /// Seats left, or null when the plan is unlimited.
  final int? remaining;

  final bool unlimited;

  /// The server's own verdict on whether another seat can be offered.
  final bool canInvite;

  /// True when the plan includes no collaborators at all — the Free tier.
  ///
  /// Deliberately expressed as "capped AND zero" rather than `limit == 0`, so it can
  /// never be true for an unlimited plan however the sentinel is written on the wire.
  bool get isFreeTier => !unlimited && limit <= 0;

  /// A defensive fallback for a story whose allowance could not be read.
  ///
  /// Zero seats, not unlimited — the same choice the server makes for an absent limit.
  /// A wrongly-hidden invite button is a support ticket; a wrongly-offered one walks the
  /// writer into a 402. But note this is only reached on an error, and the screen shows
  /// the *count* from it, not a refusal: the invite control stays live unless the server
  /// actually said no.
  static const CollaboratorLimit unknown = CollaboratorLimit(
    storyId: '',
    members: 0,
    pendingInvitations: 0,
    used: 0,
    limit: 0,
    remaining: 0,
    unlimited: false,
    canInvite: false,
  );

  factory CollaboratorLimit.fromJson(Json json) => CollaboratorLimit(
    storyId: json['storyId'] as String? ?? '',
    members: _int(json['members']),
    pendingInvitations: _int(json['pendingInvitations']),
    used: _int(json['used']),
    limit: _int(json['limit']),
    remaining: json['remaining'] == null ? null : _int(json['remaining']),
    unlimited: json['unlimited'] as bool? ?? false,
    // Defaults to false: if the server did not say a seat is available, do not assume one is.
    canInvite: json['canInvite'] as bool? ?? false,
  );
}

int _int(Object? raw) => raw is num ? raw.toInt() : 0;

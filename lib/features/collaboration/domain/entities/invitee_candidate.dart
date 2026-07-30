/// A resolved invite target (AF6) — the person behind a typed `@handle`.
///
/// Exists because `POST /stories/{id}/invitations` takes an `inviteeId` (a UUID) and the backend has
/// **no invite-by-email path at all**. The old invite sent `{role, email}`, which the contract
/// rejects outright (`whitelist` + `forbidNonWhitelisted`), so every invitation 400'd — defect
/// **M-1**, `platfrom/docs/48` §3.1.
///
/// Resolved from `GET /users/{username}`, which returns the id. Only the three fields the invite
/// sheet needs are kept: the id it must send, and a name + handle so the writer can confirm *who*
/// they are inviting before sending.
library;

import '../../../../core/utils/typedefs.dart';

class InviteeCandidate {
  const InviteeCandidate({
    required this.id,
    required this.username,
    this.penName,
  });

  final String id;
  final String username;
  final String? penName;

  /// What to show while confirming — the pen name if the profile has one, else the handle.
  String get label => (penName != null && penName!.trim().isNotEmpty)
      ? penName!.trim()
      : '@$username';

  factory InviteeCandidate.fromJson(Json json) => InviteeCandidate(
    id: json['id'] as String? ?? '',
    username: json['username'] as String? ?? '',
    penName: json['penName'] as String?,
  );
}

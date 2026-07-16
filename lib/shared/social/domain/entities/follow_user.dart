/// A user row in a followers / following / requests list (docs/40 §follows) —
/// mirrors the backend `UserSummaryDto` / `FollowRequestDto`. [id] is the user
/// UUID (the follow target for POST/DELETE /users/:id/follow). A [FollowRequest]
/// carries the follow-edge id (the target of accept/reject).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_user.freezed.dart';
part 'follow_user.g.dart';

@freezed
abstract class FollowUser with _$FollowUser {
  const FollowUser._();

  const factory FollowUser({
    required String id,
    required String username,
    String? penName,
    String? avatarKey,
  }) = _FollowUser;

  factory FollowUser.fromJson(Map<String, dynamic> json) =>
      _$FollowUserFromJson(json);

  String get displayName => (penName != null && penName!.trim().isNotEmpty)
      ? penName!.trim()
      : '@$username';

  String get handle => '@$username';
}

@freezed
abstract class FollowRequest with _$FollowRequest {
  const factory FollowRequest({
    required String id,
    required FollowUser requester,
    DateTime? requestedAt,
  }) = _FollowRequest;

  factory FollowRequest.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestFromJson(json);
}

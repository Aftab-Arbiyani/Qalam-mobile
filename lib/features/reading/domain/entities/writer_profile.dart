/// A writer's public profile as the reader needs it for the Author Card + Follow
/// (docs/40 §19.1) — mirrors the backend `ProfileResponseDto` from
/// `GET /users/:username`. This is the ONLY source of the author's user [id] (the
/// follow target for `POST/DELETE /users/:id/follow`), avatar, bio, counts, and
/// the viewer's follow relation — none of which are on the piece response.
///
/// This is a deliberately minimal slice for the reading author card, NOT the full
/// profile feature (profile screens/editing are a separate epic). Optimistic
/// follow toggles copy [isFollowing]/[hasPendingRequest] and reconcile.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'writer_profile.freezed.dart';
part 'writer_profile.g.dart';

@freezed
abstract class WriterProfile with _$WriterProfile {
  const WriterProfile._();

  const factory WriterProfile({
    required String id,
    required String username,
    @Default('') String penName,
    String? avatarKey,
    String? bio,
    @Default(false) bool isPrivate,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int piecesCount,
    @Default(false) bool isSelf,
    @Default(false) bool isFollowing,
    @Default(false) bool hasPendingRequest,
    @Default(false) bool restricted,
  }) = _WriterProfile;

  factory WriterProfile.fromJson(Map<String, dynamic> json) =>
      _$WriterProfileFromJson(json);

  String get displayName =>
      penName.trim().isNotEmpty ? penName.trim() : '@$username';

  String get handle => '@$username';
}

/// A full user profile (docs/40 §19.1) — mirrors the backend `ProfileResponseDto`
/// returned by both `GET /me` (own profile) and `GET /users/:username` (public).
/// This is the M5 profile feature's own richer entity; it is deliberately separate
/// from the reader author-card's minimal `WriterProfile` slice (features never
/// import each other).
///
/// When a stranger views a private account the server returns [restricted]`=true`
/// and OMITS the detail fields (bio/cover/website/location/socialLinks/language/
/// genres) — those stay null/empty and the UI shows a teaser. JSON round-trippable
/// so the profile caches for offline viewing (docs/40 §26).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/entities/taxonomy.dart';
import 'profile_counts.dart';
import 'viewer_relation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    required String username,
    @Default('') String penName,
    String? avatarKey,
    String? coverKey,
    @Default(false) bool isPrivate,
    @Default(false) bool restricted,
    String? bio,
    String? websiteUrl,
    String? location,
    @Default(<String, String>{}) Map<String, String> socialLinks,
    String? defaultLanguageId,
    @Default(<GenreRef>[]) List<GenreRef> genres,
    @Default(ProfileCounts()) ProfileCounts counts,
    @Default(ViewerRelation()) ViewerRelation viewerRelation,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  /// The name to show — the pen name if set, else the handle.
  String get displayName =>
      penName.trim().isNotEmpty ? penName.trim() : '@$username';

  /// The `@handle` form of the (permanent) username.
  String get handle => '@$username';

  /// Whether the viewer is looking at their own profile.
  bool get isSelf => viewerRelation.isSelf;
}

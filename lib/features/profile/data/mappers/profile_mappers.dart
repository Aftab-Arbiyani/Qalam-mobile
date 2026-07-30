/// Wire ↔ entity mappers for the profile feature (docs/40 §18). Tolerant readers
/// (never throw on a missing/null/mistyped field) turn the frozen `ProfileResponseDto`
/// / `PieceListItemDto` into domain entities, and turn a [ProfileEdit] into the
/// `PATCH /me` request body. Pure functions — no Dio, no `Failure`, no caching.
library;

import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_counts.dart';
import '../../domain/entities/profile_piece.dart';
import '../../domain/entities/viewer_relation.dart';
import '../../domain/value_objects/profile_edit.dart';

Profile profileFromJson(Json json) => Profile(
  id: asString(json['id']),
  username: asString(json['username']),
  penName: asString(json['penName']),
  avatarKey: asStringOrNull(json['avatarKey']),
  coverKey: asStringOrNull(json['coverKey']),
  isPrivate: asBool(json['isPrivate']),
  restricted: asBool(json['restricted']),
  bio: asStringOrNull(json['bio']),
  websiteUrl: asStringOrNull(json['websiteUrl']),
  location: asStringOrNull(json['location']),
  socialLinks: _socialLinks(json['socialLinks']),
  defaultLanguageId: asStringOrNull(json['defaultLanguageId']),
  genres: _genres(json['genres']),
  counts: _counts(asMap(json['counts'])),
  viewerRelation: _viewerRelation(asMap(json['viewerRelation'])),
);

ProfilePiece profilePieceFromJson(Json json) => ProfilePiece(
  id: asString(json['id']),
  title: asString(json['title']),
  slug: asStringOrNull(json['slug']),
  coverImageKey: asStringOrNull(json['coverImageKey']),
  wordCount: asInt(json['wordCount']),
  readingTimeSeconds: asInt(json['readingTimeSeconds']),
  publishedAt: asUtcDateOrNull(json['publishedAt']),
);

/// Build the `PATCH /me` body from an edit. Null fields are omitted ("leave
/// unchanged"). A blank `websiteUrl` / `defaultLanguageCode` is omitted rather
/// than sent, because the server validates them (a blank URL fails `@IsUrl`) — the
/// frozen `v1` has no explicit "unset", so those two cannot be cleared via PATCH
/// (documented gap, docs/40 §45).
Json profilePatchBody(ProfileEdit edit) {
  final Json body = <String, Object?>{};
  if (edit.penName != null) body['penName'] = edit.penName!.trim();
  if (edit.bio != null) body['bio'] = edit.bio!.trim();
  if (edit.location != null) body['location'] = edit.location!.trim();
  final String? website = edit.websiteUrl?.trim();
  if (website != null && website.isNotEmpty) body['websiteUrl'] = website;
  if (edit.socialLinks != null) body['socialLinks'] = edit.socialLinks;
  if (edit.isPrivate != null) body['isPrivate'] = edit.isPrivate;
  final String? language = edit.defaultLanguageCode?.trim();
  if (language != null && language.isNotEmpty) {
    body['defaultLanguageCode'] = language;
  }
  if (edit.genreSlugs != null) body['genres'] = edit.genreSlugs;
  return body;
}

Map<String, String> _socialLinks(Object? raw) {
  if (raw is! Map) return const <String, String>{};
  final Map<String, String> out = <String, String>{};
  raw.forEach((Object? key, Object? value) {
    if (key is String && value is String) out[key] = value;
  });
  return out;
}

List<GenreRef> _genres(Object? raw) => asMapList(raw)
    .map(
      (Json g) =>
          GenreRef(slug: asString(g['slug']), name: asString(g['name'])),
    )
    .where((GenreRef g) => g.slug.isNotEmpty)
    .toList(growable: false);

ProfileCounts _counts(Json json) => ProfileCounts(
  followers: asInt(json['followers']),
  following: asInt(json['following']),
  piecesPublished: asInt(json['piecesPublished']),
  totalReads: asInt(json['totalReads']),
  totalLikes: asInt(json['totalLikes']),
  totalClaps: asInt(json['totalClaps']),
  bookmarksReceived: asInt(json['bookmarksReceived']),
  responseCount: asInt(json['responseCount']),
);

ViewerRelation _viewerRelation(Json json) => ViewerRelation(
  isSelf: asBool(json['isSelf']),
  isFollowing: asBool(json['isFollowing']),
  hasPendingRequest: asBool(json['hasPendingRequest']),
);

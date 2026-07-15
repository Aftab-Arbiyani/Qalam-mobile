/// Wire → entity mappers for the reading feature (docs/40 §18). Maps the
/// `PieceResponseDto`, `PieceEngagementDto`, and `ProfileResponseDto` wire shapes
/// into domain entities. Pure, total, tolerant of nulls/unknown values. The raw
/// TipTap `content` map is carried through verbatim (parsed later by
/// `content_mapper.dart`); timestamps become UTC `DateTime`s.
library;

import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/entity_mappers.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/piece_detail.dart';
import '../../domain/entities/piece_engagement.dart';
import '../../domain/entities/writer_profile.dart';

PieceDetail pieceDetailFromJson(Json json) {
  final Object? languageRaw = json['language'];
  return PieceDetail(
    id: asString(json['id']),
    title: asString(json['title']),
    author: authorFromWire(json['author']),
    content: asMap(json['content']),
    subtitle: asStringOrNull(json['subtitle']),
    slug: asStringOrNull(json['slug']),
    featuredQuote: asStringOrNull(json['featuredQuote']),
    coverImageKey: asStringOrNull(json['coverImageKey']),
    language: languageRaw == null ? null : languageFromWire(languageRaw),
    genre: genreFromWireOrNull(json['genre']),
    tags: asMapList(
      json['tags'],
    ).map<TagRef>(tagFromWire).toList(growable: false),
    status: PieceStatus.fromWire(
      asStringOrNull(json['status']),
      fallback: PieceStatus.published,
    ),
    visibility: Visibility.fromWire(asStringOrNull(json['visibility'])),
    wordCount: asInt(json['wordCount']),
    readingTimeSeconds: asInt(json['readingTimeSeconds']),
    publishedAt: asUtcDateOrNull(json['publishedAt']),
  );
}

PieceEngagement pieceEngagementFromJson(Json json) {
  final Json stats = asMap(json['stats']);
  final Json viewer = asMap(json['viewer']);
  return PieceEngagement(
    likes: asInt(stats['likes']),
    claps: asInt(stats['claps']),
    bookmarks: asInt(stats['bookmarks']),
    comments: asInt(stats['comments']),
    responses: asInt(stats['responses']),
    shares: asInt(stats['shares']),
    hasLiked: asBool(viewer['hasLiked']),
    hasBookmarked: asBool(viewer['hasBookmarked']),
    clapCount: asInt(viewer['clapCount']),
  );
}

WriterProfile writerProfileFromJson(Json json) {
  final Json counts = asMap(json['counts']);
  final Json relation = asMap(json['viewerRelation']);
  return WriterProfile(
    id: asString(json['id']),
    username: asString(json['username']),
    penName: asString(json['penName']),
    avatarKey: asStringOrNull(json['avatarKey']),
    bio: asStringOrNull(json['bio']),
    isPrivate: asBool(json['isPrivate']),
    followersCount: asInt(counts['followers']),
    followingCount: asInt(counts['following']),
    piecesCount: asInt(counts['piecesPublished']),
    isSelf: asBool(relation['isSelf']),
    isFollowing: asBool(relation['isFollowing']),
    hasPendingRequest: asBool(relation['hasPendingRequest']),
    restricted: asBool(json['restricted']),
  );
}

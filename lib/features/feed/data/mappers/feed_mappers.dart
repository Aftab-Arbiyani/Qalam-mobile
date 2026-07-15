/// Wire → entity mappers for the feed feature (docs/40 §18). The only code that
/// knows the `FeedItemDto` / `WriterCardDto` / trend / bookmark wire shapes. Pure,
/// total functions: unknown enum values fall back (via `fromWire`), missing/typed-
/// wrong fields coerce to defaults — never a throw (docs/40 §18.2). Unit-tested
/// with null + unknown-field payloads.
library;

import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/entity_mappers.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/bookmark_item.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/entities/writer_summary.dart';

PieceSummaryStats pieceStatsFromJson(Object? raw) {
  final Json json = asMap(raw);
  return PieceSummaryStats(
    likes: asInt(json['likes']),
    claps: asInt(json['claps']),
    comments: asInt(json['comments']),
    responses: asInt(json['responses']),
  );
}

PieceSummary pieceSummaryFromJson(Json json) => PieceSummary(
  id: asString(json['id']),
  title: asString(json['title']),
  slug: asStringOrNull(json['slug']),
  subtitle: asStringOrNull(json['subtitle']),
  featuredQuote: asStringOrNull(json['featuredQuote']),
  coverImageKey: asStringOrNull(json['coverImageKey']),
  author: authorFromWire(json['author']),
  language: languageFromWire(json['language']),
  genre: genreFromWireOrNull(json['genre']),
  stats: pieceStatsFromJson(json['stats']),
  visibility: Visibility.fromWire(asStringOrNull(json['visibility'])),
  wordCount: asInt(json['wordCount']),
  readingTimeSeconds: asInt(json['readingTimeSeconds']),
  publishedAt: asUtcDateOrNull(json['publishedAt']),
);

WriterSummary writerSummaryFromJson(Json json) => WriterSummary(
  username: asString(json['username']),
  penName: asStringOrNull(json['penName']),
  avatarKey: asStringOrNull(json['avatarKey']),
  bio: asStringOrNull(json['bio']),
  followersCount: asInt(json['followersCount']),
  piecesCount: asInt(json['piecesCount']),
);

TrendingTag trendingTagFromJson(Json json) => TrendingTag(
  slug: asString(json['slug']),
  name: asString(json['name']),
  pieceCount: asInt(json['pieceCount']),
);

TrendingGenre trendingGenreFromJson(Json json) => TrendingGenre(
  slug: asString(json['slug']),
  name: asString(json['name']),
  pieceCount: asInt(json['pieceCount']),
);

TrendingLanguage trendingLanguageFromJson(Json json) => TrendingLanguage(
  code: asString(json['code']),
  nativeName: asString(json['nativeName']),
  direction: TextDirectionKind.fromWire(asStringOrNull(json['direction'])),
  pieceCount: asInt(json['pieceCount']),
);

BookmarkItem bookmarkItemFromJson(Json json) => BookmarkItem(
  pieceId: asString(json['pieceId']),
  title: asString(json['title']),
  slug: asStringOrNull(json['slug']),
  bookmarkedAt:
      asUtcDateOrNull(json['bookmarkedAt']) ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
);

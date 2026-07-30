/// Wire → entity mappers for the cross-cutting `shared/domain` value objects
/// (docs/40 §18). Author / language / genre / tag appear on many wire shapes
/// (feed cards, piece detail, discovery), so their mappers live in `shared/data`
/// and are imported by every feature's data layer — never re-implemented per
/// feature (features never import features, docs/40 §7.3). Pure, total, tolerant.
library;

import '../../core/utils/json_read.dart';
import '../../core/utils/typedefs.dart';
import '../domain/entities/author.dart';
import '../domain/entities/piece_summary.dart';
import '../domain/entities/taxonomy.dart';
import '../domain/entities/trend_item.dart';
import '../domain/entities/writer_summary.dart';
import '../domain/enums.dart';

Author authorFromWire(Object? raw) {
  final Json json = asMap(raw);
  return Author(
    username: asString(json['username']),
    penName: asStringOrNull(json['penName']),
    avatarKey: asStringOrNull(json['avatarKey']),
  );
}

LanguageRef languageFromWire(Object? raw) {
  final Json json = asMap(raw);
  return LanguageRef(
    code: asString(json['code']),
    nativeName: asString(json['nativeName']),
    direction: TextDirectionKind.fromWire(asStringOrNull(json['direction'])),
  );
}

/// A nullable genre — the wire sends `null` for genre-less pieces.
GenreRef? genreFromWireOrNull(Object? raw) {
  if (raw is! Map) return null;
  final Json json = Json.from(raw);
  return GenreRef(slug: asString(json['slug']), name: asString(json['name']));
}

TagRef tagFromWire(Object? raw) {
  final Json json = asMap(raw);
  return TagRef(slug: asString(json['slug']), name: asString(json['name']));
}

// ── Read-model mappers (shared by feed, discovery, and search) ───────────────
// A piece card, writer card, and the trend items appear on feed cards, the
// discovery shelves, and every search result group. Their mappers live here so
// no feature re-implements them (features never import features, docs/40 §7.3).
// Tolerant of extra wire fields (e.g. search's `rank`) — unknown keys are ignored.

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
  isPrivate: asBool(json['isPrivate']),
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

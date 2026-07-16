/// Wire → entity mappers private to the feed feature (docs/40 §18). The shared
/// read-model mappers (piece / writer / trend) now live in `shared/data/
/// entity_mappers.dart` — reused by feed, discovery, and search, never
/// re-implemented per feature (docs/40 §7.3). This file re-exports them so the
/// feed data layer keeps a single mapper import, and adds the feed-only
/// `BookmarkItem` mapper. Pure, total, tolerant — never throws (docs/40 §18.2).
library;

import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/bookmark_item.dart';

export '../../../../shared/data/entity_mappers.dart'
    show
        pieceStatsFromJson,
        pieceSummaryFromJson,
        trendingGenreFromJson,
        trendingLanguageFromJson,
        trendingTagFromJson,
        writerSummaryFromJson;

BookmarkItem bookmarkItemFromJson(Json json) => BookmarkItem(
  pieceId: asString(json['pieceId']),
  title: asString(json['title']),
  slug: asStringOrNull(json['slug']),
  bookmarkedAt:
      asUtcDateOrNull(json['bookmarkedAt']) ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
);

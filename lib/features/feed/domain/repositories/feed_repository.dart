/// The feed feature boundary (docs/40 §16). Serves the four piece-summary feed
/// tabs and the signed-in user's bookmarks, each cache-then-network with offline
/// fallback. Discovery surfaces (featured/popular pieces & writers, trending
/// tags/genres/languages) live in the shared `shared/discovery` module so search
/// reuses them without a feature→feature import (docs/40 §7.3). Returns domain
/// [Result]s of [CachedPage]s — never a DTO, `DioException`, or HTTP status.
library;

import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../entities/bookmark_item.dart';
import '../value_objects/feed_query.dart';

abstract interface class FeedRepository {
  /// A page of one of the four piece-summary feed tabs. Page 1 (`cursor == null`)
  /// is cache-then-network; later pages are network-only (cursors aren't cached).
  Future<Result<CachedPage<PieceSummary>>> pieceFeed(
    FeedTab tab, {
    FeedQuery query,
    String? cursor,
  });

  /// The signed-in user's private bookmark feed.
  Future<Result<CachedPage<BookmarkItem>>> bookmarks({String? cursor});
}

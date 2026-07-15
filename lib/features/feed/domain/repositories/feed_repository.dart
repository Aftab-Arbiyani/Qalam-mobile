/// The feed feature boundary (docs/40 §16). One repository serves every feed +
/// discovery surface, each cache-then-network with offline fallback. Returns
/// domain [Result]s of [CachedPage]s — never a DTO, `DioException`, or HTTP status.
library;

import '../../../../core/utils/result.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../entities/bookmark_item.dart';
import '../entities/piece_summary.dart';
import '../entities/trend_item.dart';
import '../entities/writer_summary.dart';
import '../value_objects/feed_query.dart';

abstract interface class FeedRepository {
  /// A page of one of the four piece-summary feed tabs. Page 1 (`cursor == null`)
  /// is cache-then-network; later pages are network-only (cursors aren't cached).
  Future<Result<CachedPage<PieceSummary>>> pieceFeed(
    FeedTab tab, {
    FeedQuery query,
    String? cursor,
  });

  /// Discovery: featured / recent / most-clapped / most-discussed pieces.
  Future<Result<CachedPage<PieceSummary>>> discoverPieces(
    DiscoverPieceKind kind, {
    String? cursor,
  });

  /// Discovery: featured / popular / new writers.
  Future<Result<CachedPage<WriterSummary>>> discoverWriters(
    WriterKind kind, {
    String? cursor,
  });

  Future<Result<CachedPage<TrendingTag>>> trendingTags({String? cursor});

  Future<Result<CachedPage<TrendingGenre>>> trendingGenres({String? cursor});

  Future<Result<CachedPage<TrendingLanguage>>> trendingLanguages({
    String? cursor,
  });

  /// The signed-in user's private bookmark feed.
  Future<Result<CachedPage<BookmarkItem>>> bookmarks({String? cursor});
}

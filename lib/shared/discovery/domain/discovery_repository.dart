/// The discovery boundary (docs/40 §6, §16, E6). Discovery surfaces — featured/
/// recent/most-clapped pieces, featured/popular/new writers, and trending tags/
/// genres/languages — are a cross-cutting read that both the feed feature's
/// `/discover` browse screen and the search feature's discovery landing consume.
/// It therefore lives in `shared/` (like taxonomy) so neither feature imports the
/// other (docs/40 §7.3). Cache-then-network with offline fallback throughout;
/// returns domain [Result]s of [CachedPage]s — never a DTO or HTTP status.
library;

import '../../../core/utils/result.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/entities/writer_summary.dart';
import '../../domain/enums.dart';
import '../../pagination/cached_page.dart';

abstract interface class DiscoveryRepository {
  /// Featured / recent / most-clapped / most-discussed pieces.
  Future<Result<CachedPage<PieceSummary>>> discoverPieces(
    DiscoverPieceKind kind, {
    String? cursor,
  });

  /// Featured / popular / new writers.
  Future<Result<CachedPage<WriterSummary>>> discoverWriters(
    WriterKind kind, {
    String? cursor,
  });

  Future<Result<CachedPage<TrendingTag>>> trendingTags({String? cursor});

  Future<Result<CachedPage<TrendingGenre>>> trendingGenres({String? cursor});

  Future<Result<CachedPage<TrendingLanguage>>> trendingLanguages({
    String? cursor,
  });
}

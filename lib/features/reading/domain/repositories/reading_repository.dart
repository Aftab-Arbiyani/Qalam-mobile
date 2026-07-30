/// The reading-reads boundary (docs/40 §16) — the piece aggregate, its engagement
/// snapshot, and the author's profile, each cache-then-network with offline
/// fallback; plus the fire-and-forget analytics beacons. Returns domain [Result]s
/// / entities — never a DTO, `DioException`, or HTTP status.
library;

import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../entities/piece_detail.dart';
import '../entities/piece_engagement.dart';
import '../entities/writer_profile.dart';

/// A piece detail plus whether it was served stale from cache (offline).
typedef CachedDetail = ({PieceDetail piece, bool isStale});

abstract interface class ReadingRepository {
  /// The full piece by id (cache-then-network; cached copy served stale offline).
  Future<Result<CachedDetail>> getPiece(String id);

  /// Counts + the viewer's like/bookmark state (cache-fallback offline).
  Future<Result<PieceEngagement>> getEngagement(String id);

  /// The author's public profile by username — the only source of the follow
  /// target id, avatar, bio, counts, and the viewer's follow relation.
  Future<Result<WriterProfile>> getWriterProfile(String username);

  /// "More like this" — published pieces sharing [tag], newest-trending first
  /// (docs/48 §3.1). A tag-filtered piece search, NOT a recommender: the AF4
  /// recommender needs `ai.use`, which a signed-out reader does not have.
  /// Non-critical, so it is not cached and its failure is the caller's to ignore.
  Future<Result<List<PieceSummary>>> getRelatedPieces(TagRef tag, {int limit});

  /// Beacon: the reader opened the piece. Best-effort; never throws.
  Future<void> recordView(String id, {String? sessionId});

  /// Beacon: a read session ended. Best-effort; never throws.
  Future<void> recordRead(
    String id, {
    required int durationSeconds,
    required int completionPct,
    String? sessionId,
  });
}

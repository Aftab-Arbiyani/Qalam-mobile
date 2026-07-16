/// The engagement-mutation boundary (docs/40 §16, §21.4) — like/bookmark/share on
/// a piece, follow on a writer, and report ANY entity (piece/comment/user/
/// response). Cross-cutting: consumed by the reading surface, the social feature,
/// and the offline action queue, so it lives in `shared/social` (docs/40 §7.3).
/// Each returns the server's authoritative result as a domain [Result]; the
/// presentation applies optimistic updates and reconciles/rolls back (docs/40 §21.4).
library;

import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../../domain/enums.dart';

/// The server's like result: new liked-state + total.
typedef LikeOutcome = ({bool liked, int totalLikes});

abstract interface class EngagementRepository {
  Future<Result<LikeOutcome>> like(String pieceId);
  Future<Result<Unit>> unlike(String pieceId);

  /// Returns the new bookmarked state (`true`).
  Future<Result<bool>> bookmark(String pieceId);
  Future<Result<Unit>> unbookmark(String pieceId);

  /// Records a share and returns the new total share count.
  Future<Result<int>> share(String pieceId, ShareChannel channel);

  /// Follows a writer by user id; returns `accepted` (public) or `pending` (private).
  Future<Result<FollowStatus>> follow(String userId);
  Future<Result<Unit>> unfollow(String userId);

  /// Report a piece, comment, user, or response.
  Future<Result<Unit>> report({
    required ReportEntityType entityType,
    required String entityId,
    required ReportReason reason,
    String? description,
  });
}

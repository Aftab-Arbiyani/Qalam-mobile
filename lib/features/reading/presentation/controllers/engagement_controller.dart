/// The reading engagement controller (docs/40 §21.4, §23) — holds the piece's
/// counts + the viewer's like/bookmark state, and applies OPTIMISTIC like /
/// bookmark / share with server reconciliation and rollback. When OFFLINE, a
/// like/bookmark toggle is applied optimistically and QUEUED (the unified
/// [SyncEngine] reconciles it on reconnect) instead of calling the wire.
/// Engagement is non-critical: a failed initial load degrades to empty counts.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/social/data/sync/social_sync_handler.dart';
import '../../../../shared/social/domain/engagement_repository.dart';
import '../../../../shared/social/social_providers.dart';
import '../../domain/entities/piece_engagement.dart';
import '../providers/reading_providers.dart';

part 'engagement_controller.g.dart';

/// The shared cache key for the Bookmarks feed (mirrors the feed repository's
/// key, docs/40 §25.1) — evicted here so a bookmark change reloads it fresh.
const String _bookmarksCacheKey = 'bookmarks:list';

@riverpod
class EngagementController extends _$EngagementController {
  @override
  Future<PieceEngagement> build(String pieceId) async {
    final result = await ref
        .watch(readingRepositoryProvider)
        .getEngagement(pieceId);
    return result.fold(
      (PieceEngagement engagement) => engagement,
      (Failure _) => PieceEngagement.empty,
    );
  }

  bool get _online => ref.read(connectivityServiceProvider).isOnline;

  /// Optimistic like/unlike — apply immediately, reconcile with the server total,
  /// roll back on failure. Offline: apply + queue for reconnect (docs/40 §23).
  Future<void> toggleLike() async {
    final PieceEngagement? current = state.asData?.value;
    if (current == null) return;
    final bool wasLiked = current.hasLiked;
    final PieceEngagement optimistic = current.copyWith(
      hasLiked: !wasLiked,
      likes: _clamp(current.likes + (wasLiked ? -1 : 1)),
    );
    state = AsyncData<PieceEngagement>(optimistic);

    if (!_online) {
      await _queue(SocialCategory.pieceLike, pieceId, desired: !wasLiked);
      return;
    }

    final EngagementRepository repo = ref.read(engagementRepositoryProvider);
    if (wasLiked) {
      final Result<void> res = await repo.unlike(pieceId);
      if (res.isErr) state = AsyncData<PieceEngagement>(current);
    } else {
      final Result<LikeOutcome> res = await repo.like(pieceId);
      res.fold(
        (LikeOutcome outcome) => state = AsyncData<PieceEngagement>(
          optimistic.copyWith(
            hasLiked: outcome.liked,
            likes: outcome.totalLikes,
          ),
        ),
        (Failure _) => state = AsyncData<PieceEngagement>(current),
      );
    }
  }

  /// Optimistic bookmark/unbookmark. Also evicts the cached bookmarks list so the
  /// Bookmarks feed is fresh on its next load. Offline: apply + queue.
  Future<void> toggleBookmark() async {
    final PieceEngagement? current = state.asData?.value;
    if (current == null) return;
    final bool wasMarked = current.hasBookmarked;
    state = AsyncData<PieceEngagement>(
      current.copyWith(
        hasBookmarked: !wasMarked,
        bookmarks: _clamp(current.bookmarks + (wasMarked ? -1 : 1)),
      ),
    );

    if (!_online) {
      await _queue(SocialCategory.pieceBookmark, pieceId, desired: !wasMarked);
      await ref.read(cacheStoreProvider).evict(_bookmarksCacheKey);
      return;
    }

    final EngagementRepository repo = ref.read(engagementRepositoryProvider);
    final Result<Object?> res = wasMarked
        ? await repo.unbookmark(pieceId)
        : await repo.bookmark(pieceId);
    if (res.isErr) {
      state = AsyncData<PieceEngagement>(current);
    } else {
      await ref.read(cacheStoreProvider).evict(_bookmarksCacheKey);
    }
  }

  /// Records a share (optimistic +1) and returns whether it succeeded.
  Future<bool> recordShare(ShareChannel channel) async {
    final PieceEngagement? current = state.asData?.value;
    if (current == null) return false;
    state = AsyncData<PieceEngagement>(
      current.copyWith(shares: _clamp(current.shares + 1)),
    );
    final Result<int> res = await ref
        .read(engagementRepositoryProvider)
        .share(pieceId, channel);
    return res.fold(
      (int total) {
        state = AsyncData<PieceEngagement>(current.copyWith(shares: total));
        return true;
      },
      (Failure _) {
        state = AsyncData<PieceEngagement>(current);
        return false;
      },
    );
  }

  /// Report the piece. Returns the [Failure] on error, or null on success.
  Future<Failure?> report({
    required ReportReason reason,
    String? description,
  }) async {
    final Result<void> res = await ref
        .read(engagementRepositoryProvider)
        .report(
          entityType: ReportEntityType.piece,
          entityId: pieceId,
          reason: reason,
          description: description,
        );
    return res.failureOrNull;
  }

  Future<void> _queue(
    SocialCategory category,
    String targetId, {
    required bool desired,
  }) => ref
      .read(syncEngineProvider)
      .enqueue(
        buildSocialOperation(
          category: category,
          targetId: targetId,
          desired: desired,
        ),
      );

  int _clamp(int value) => value < 0 ? 0 : value;
}

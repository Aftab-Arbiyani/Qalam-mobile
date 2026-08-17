/// The reading engagement controller (docs/40 §21.4, §23) — holds the piece's
/// counts + the viewer's like/bookmark state, and applies OPTIMISTIC like /
/// bookmark / share with server reconciliation and rollback. When OFFLINE, a
/// like/bookmark toggle is applied optimistically and QUEUED (the unified
/// [SyncEngine] reconciles it on reconnect) instead of calling the wire.
/// Engagement is non-critical: a failed initial load degrades to empty counts.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/social/data/sync/clap_sync_handler.dart';
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
    // Kill the debounce timer with the provider. This is autoDispose, so a reader
    // who claps and immediately navigates away would otherwise leave a Timer that
    // fires into a disposed `ref` and throws. Cancelling here only prevents the
    // crash — SAVING that burst is the screen's job, which flushes through a
    // notifier captured while mounted (`reading_screen`), because `ref` is not
    // usable from a dispose callback.
    ref.onDispose(() {
      _clapTimer?.cancel();
      _clapTimer = null;
    });
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

  // ── Claps ──────────────────────────────────────────────────────────────────
  //
  // A clap is NOT a like. A like toggles one boolean; a clap is a 1..50 quantity
  // the reader builds by tapping repeatedly, and its removal is all-or-nothing.
  // That difference is why it cannot reuse `toggleLike`'s shape or the
  // desired-state outbox category (see `clap_sync_handler.dart`).

  /// Claps tapped but not yet sent. Held on the notifier rather than in [state]
  /// because the visible number already lives in [state] (patched optimistically)
  /// — this only exists to be summed into one request.
  int _pendingClaps = 0;
  Timer? _clapTimer;

  /// Idle window before a burst is flushed as ONE request.
  ///
  /// Web uses the same 600 ms (`use-claps.ts:68`) and its two bounds hold here,
  /// one of them more strongly:
  ///
  ///   - **Above a repeat-tap interval.** Web argued ~250 ms as the slow end of a
  ///     deliberate repeat-CLICK. A thumb tapping a stationary target repeats
  ///     FASTER than a mouse — there is no pointer travel between presses — so
  ///     600 ms clears the touch cadence by a wider margin than it clears the
  ///     mouse one. The lower bound is safer on mobile, not tighter.
  ///   - **Below ~1 s**, past which an unflushed count stops feeling saved. This
  ///     bound is unchanged, and mobile has a second reason not to lengthen it:
  ///     everything inside the window depends on the lifecycle hook firing, and
  ///     an app can be backgrounded or killed at any moment. A longer window is
  ///     a strictly larger loss surface.
  ///
  /// It is an IDLE window, not a fixed interval — a continuing burst keeps
  /// deferring the flush, so a long run is still one request rather than one per
  /// window.
  static const Duration clapFlushDelay = Duration(milliseconds: 600);

  /// Add one clap, optimistically. A tap at the cap is a NO-OP — no increment, no
  /// request, and never an error: `CLAP_LIMIT_REACHED` is precisely what a reader
  /// hammering a full button must not be shown.
  void clap() {
    final PieceEngagement? current = state.asData?.value;
    // No engagement loaded means no count to move. Accumulating anyway would
    // send a burst the reader never saw acknowledged.
    if (current == null) return;
    // The cap check reads the OPTIMISTIC count, which already includes every
    // pending tap — so a reader who taps twenty times from forty-nine gets one
    // clap and nineteen no-ops, not a request for twenty the server discards.
    if (current.clapCount >= Limits.maxClapsPerUserPerPiece) return;

    _pendingClaps++;
    state = AsyncData<PieceEngagement>(
      current.copyWith(
        clapCount: current.clapCount + 1,
        claps: current.claps + 1,
      ),
    );

    _clapTimer?.cancel();
    _clapTimer = Timer(clapFlushDelay, () => unawaited(flushClaps()));
  }

  /// Send whatever has accumulated. Safe to call spuriously — zero pending is a
  /// no-op. Public because the reader screen flushes it on background and on
  /// dispose (an unflushed burst that vanishes is the failure a reader notices).
  Future<void> flushClaps() async {
    _clapTimer?.cancel();
    _clapTimer = null;
    final int count = _pendingClaps;
    if (count <= 0) return;
    _pendingClaps = 0;

    // Offline: queue it, exactly as like/bookmark/follow do. A clap that alone
    // did not survive airplane mode would be the one engagement write that
    // silently drops, and the outbox is Hive-persisted so it survives a kill.
    if (!_online) {
      await ref
          .read(syncEngineProvider)
          .enqueue(buildClapOperation(targetId: pieceId, count: count));
      return;
    }

    final Result<ClapOutcome> res = await ref
        .read(engagementRepositoryProvider)
        .clap(pieceId, count);
    final PieceEngagement? current = state.asData?.value;
    if (current == null) return;
    res.fold(
      // Adopt BOTH server numbers: the viewer's because the server clamped ours,
      // the piece's because other readers moved it while this screen was open.
      (ClapOutcome outcome) => state = AsyncData<PieceEngagement>(
        current.copyWith(
          clapCount: outcome.viewerClaps,
          claps: outcome.totalClaps,
        ),
      ),
      // Roll back exactly the claps this flush carried. Deliberately silent — a
      // clap is a grace note, and a toast for a lost one costs the reader more
      // than the clap was worth.
      (Failure _) => state = AsyncData<PieceEngagement>(
        current.copyWith(
          clapCount: _clamp(current.clapCount - count),
          claps: _clamp(current.claps - count),
        ),
      ),
    );
  }

  /// Remove EVERY clap this viewer has on the piece. There is no decrement, so
  /// the affordance says "remove my claps", never "−1".
  Future<void> removeClaps() async {
    final PieceEngagement? current = state.asData?.value;
    if (current == null || current.clapCount <= 0) return;

    // Drop anything tapped-but-unsent FIRST and synchronously. If the debounce
    // timer fired after the removal started, it would resurrect the very claps
    // the reader just asked to take away.
    _clapTimer?.cancel();
    _clapTimer = null;
    _pendingClaps = 0;

    final int mine = current.clapCount;
    state = AsyncData<PieceEngagement>(
      current.copyWith(clapCount: 0, claps: _clamp(current.claps - mine)),
    );

    final Result<void> res = await ref
        .read(engagementRepositoryProvider)
        .unclap(pieceId);
    if (res.isErr) state = AsyncData<PieceEngagement>(current);
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

/// The offline handler for a clap burst (M7-3) — deliberately NOT a
/// [SocialSyncHandler] category.
///
/// **Why a clap needs its own handler.** Every other queued engagement action is
/// a TOGGLE: `social_sync_handler.dart` carries `desired: bool`, a *terminal
/// state*, and replay simply drives the server to it. That model gives it two
/// properties for free — replay is idempotent (driving to `liked: true` twice is
/// the same as once), and collapsing two queued ops is `latest wins`, because a
/// later intent supersedes an earlier one.
///
/// A clap has neither property. It is a QUANTITY the reader accumulates, so:
///
///   - **Replay is not idempotent.** The payload is a delta, and re-sending it
///     adds again. See the bound on that below — it is real, and accepted.
///   - **Latest-wins would silently lose claps.** Ten queued, five more tapped,
///     and `merge => incoming` throws the ten away. The reader has already
///     WATCHED the count climb to fifteen, so the loss is invisible until the
///     number comes back wrong on the next read. [merge] sums instead.
///
/// Growing `buildSocialOperation` an optional `count` would have put those two
/// contracts behind one signature, and made the wrong merge the default for
/// whichever one the next caller forgot to think about. So the toggle builder,
/// its enum and its handler are untouched, and this sits beside them.
///
/// **Why a delta and not a desired total.** A desired total would restore
/// idempotency and make latest-wins correct — but it would also make claps from
/// one device CANCEL claps from another (device A queues "total 13" while device
/// B legitimately adds five, and reconnecting A pulls the count back down). A
/// clap is a contribution, not a setting; "I gave ten claps" is an event count.
/// Double-counting on a retry is the lesser failure, and it is bounded: the
/// server clamps every request to `min(count, MAX - current)`, so the worst case
/// is the reader's own count reaching [Limits.maxClapsPerUserPerPiece] early. It
/// cannot exceed the cap, cannot touch another reader, and self-heals on the
/// next engagement read.
library;

import '../../../../core/sync/sync_handler.dart';
import '../../../../core/sync/sync_operation.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../domain/limits.dart';
import '../../domain/engagement_repository.dart';

/// The queued clap op's type. Stable — it is persisted, so a queued burst
/// survives a restart.
const String clapOpType = 'social.piece_clap';

/// Build the queued operation for [count] claps on [targetId]. Deduped per
/// piece, so a second burst on the same piece merges into the first.
SyncOperation buildClapOperation({
  required String targetId,
  required int count,
  String? label,
}) {
  final DateTime now = DateTime.now();
  return SyncOperation(
    id: 'clap-$targetId-${now.microsecondsSinceEpoch}',
    type: clapOpType,
    dedupKey: targetId,
    payload: clapPayload(targetId: targetId, count: count),
    createdAt: now,
    label: label,
  );
}

/// The payload shape, in one place.
Json clapPayload({required String targetId, required int count}) =>
    <String, dynamic>{'targetId': targetId, 'count': count};

/// Read a payload's count defensively — a persisted op predating a shape change
/// must not crash the drain.
int clapCountOf(SyncOperation op) => (op.payload['count'] as int?) ?? 0;

class ClapSyncHandler implements SyncHandler {
  ClapSyncHandler(this._engagement);

  final EngagementRepository _engagement;

  @override
  String get type => clapOpType;

  @override
  Future<SyncOutcome> reconcile(SyncOperation op) async {
    final String targetId = (op.payload['targetId'] as String?) ?? '';
    final int count = clapCountOf(op);
    // A merged-to-nothing op is a success, not a wasted request.
    if (count <= 0) return const SyncOutcome.success();
    return syncOutcomeFromResult(await _engagement.clap(targetId, count));
  }

  /// **Claps ACCUMULATE — the queued counts are summed, not replaced.**
  ///
  /// This is the one place the toggle handler's `latest wins` is a defect rather
  /// than a simplification: returning [incoming] would discard everything
  /// [existing] had queued, and the reader would lose claps they already saw
  /// land on screen.
  ///
  /// [existing] is the base, not [incoming], so the merged op keeps the original
  /// id, `createdAt` and attempt/backoff record. A reader who taps again while a
  /// burst is failing should not thereby hand it a fresh retry budget and defeat
  /// the engine's backoff.
  ///
  /// The sum is clamped to [Limits.maxClapsPerUserPerPiece] because that is the
  /// most the server can ever accept for one viewer on one piece — an unclamped
  /// sum would just be a larger number for the server to throw away.
  @override
  SyncOperation? merge(SyncOperation incoming, SyncOperation existing) {
    final int total = clapCountOf(existing) + clapCountOf(incoming);
    final int capped = total > Limits.maxClapsPerUserPerPiece
        ? Limits.maxClapsPerUserPerPiece
        : total;
    // Rebuilt rather than `copyWith`ed because `copyWith` deliberately does not
    // expose `payload` — every other handler's merge picks one whole op. Each
    // field carried over is a decision: id/createdAt keep queue identity and
    // ordering, attempts/nextAttemptAt keep the backoff a failing burst has
    // already earned.
    return SyncOperation(
      id: existing.id,
      type: existing.type,
      dedupKey: existing.dedupKey,
      payload: clapPayload(
        targetId: (existing.payload['targetId'] as String?) ?? '',
        count: capped,
      ),
      createdAt: existing.createdAt,
      label: existing.label,
      attempts: existing.attempts,
      status: existing.status,
      nextAttemptAt: existing.nextAttemptAt,
      lastError: existing.lastError,
    );
  }
}

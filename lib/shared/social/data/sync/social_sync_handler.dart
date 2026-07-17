/// Social engagement handlers for the unified sync engine (docs/40 §23, §24) —
/// the replacement for the old bespoke `SocialSyncEngine` + `SocialOutboxStore`.
/// Each queued like / bookmark / follow is a [SyncOperation] carrying a *desired
/// terminal state* (`desired: true/false`), deduped per (category, target) so
/// toggling twice offline collapses to the final intent; replay simply drives the
/// server to that state through the SAME [EngagementRepository] the online path
/// uses. One handler instance per category, registered on the one engine.
library;

import '../../../../core/sync/sync_handler.dart';
import '../../../../core/sync/sync_operation.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/engagement_repository.dart';

/// The toggle category a social action reconciles. Wire keys are stable — they are
/// embedded in the persisted operation type, so a queued op survives a restart.
enum SocialCategory {
  pieceLike('piece_like'),
  pieceBookmark('piece_bookmark'),
  userFollow('user_follow');

  const SocialCategory(this.wire);
  final String wire;

  /// The [SyncOperation.type] this category maps to.
  String get opType => 'social.$wire';
}

/// Build the queued operation for a social toggle. [desired] is the intended end
/// state (`true` = liked / bookmarked / following).
SyncOperation buildSocialOperation({
  required SocialCategory category,
  required String targetId,
  required bool desired,
  String? label,
}) {
  final DateTime now = DateTime.now();
  return SyncOperation(
    id: 'social-${category.wire}-$targetId-${now.microsecondsSinceEpoch}',
    type: category.opType,
    dedupKey: targetId,
    payload: <String, dynamic>{'targetId': targetId, 'desired': desired},
    createdAt: now,
    label: label,
  );
}

class SocialSyncHandler implements SyncHandler {
  SocialSyncHandler(this._engagement, this.category);

  final EngagementRepository _engagement;
  final SocialCategory category;

  @override
  String get type => category.opType;

  @override
  Future<SyncOutcome> reconcile(SyncOperation op) async {
    final String targetId = (op.payload['targetId'] as String?) ?? '';
    final bool desired = (op.payload['desired'] as bool?) ?? true;
    final result = switch (category) {
      SocialCategory.pieceLike =>
        desired ? await _engagement.like(targetId) : await _engagement.unlike(targetId),
      SocialCategory.pieceBookmark =>
        desired
            ? await _engagement.bookmark(targetId)
            : await _engagement.unbookmark(targetId),
      SocialCategory.userFollow =>
        desired ? await _engagement.follow(targetId) : await _engagement.unfollow(targetId),
    };
    return syncOutcomeFromResult(result);
  }

  /// Latest intent wins (desired-state) — the incoming toggle replaces the queued
  /// one for the same target. This preserves the old outbox's put-overwrites
  /// semantics exactly.
  @override
  SyncOperation? merge(SyncOperation incoming, SyncOperation existing) =>
      incoming;
}

/// One handler per social category, ready to register on the unified engine.
List<SyncHandler> buildSocialSyncHandlers(EngagementRepository engagement) =>
    <SyncHandler>[
      for (final SocialCategory category in SocialCategory.values)
        SocialSyncHandler(engagement, category),
    ];

/// Helper the reconcile switch never needs but tests/readers may — the payload
/// shape in one place.
Json socialPayload({required String targetId, required bool desired}) =>
    <String, dynamic>{'targetId': targetId, 'desired': desired};

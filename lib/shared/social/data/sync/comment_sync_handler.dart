/// Comment-creation handler for the unified sync engine (docs/40 §23) — the
/// "Queued Comments" surface. A comment or reply written offline is queued as ONE
/// [SyncOperation], keyed by the provisional temp id the controller already
/// assigns to its optimistic node, so it is unique (never merged) and idempotent
/// on replay (one create per temp id). Reconciles through the SAME
/// [CommentRepository] the online path uses: a `parentId` routes to a reply,
/// otherwise a top-level comment.
library;

import '../../../../core/sync/sync_handler.dart';
import '../../../../core/sync/sync_operation.dart';
import '../../domain/comment_repository.dart';

/// The [SyncOperation.type] for a queued comment/reply creation.
const String kCommentOpType = 'comment.create';

SyncOperation buildCommentOperation({
  required String tempId,
  required String pieceId,
  required String body,
  String? parentId,
  String? label,
}) {
  final DateTime now = DateTime.now();
  return SyncOperation(
    id: 'comment-$tempId',
    type: kCommentOpType,
    dedupKey: tempId,
    payload: <String, dynamic>{
      'pieceId': pieceId,
      'body': body,
      'parentId': ?parentId,
    },
    createdAt: now,
    label: label,
  );
}

class CommentSyncHandler implements SyncHandler {
  CommentSyncHandler(this._repository);

  final CommentRepository _repository;

  @override
  String get type => kCommentOpType;

  @override
  Future<SyncOutcome> reconcile(SyncOperation op) async {
    final String pieceId = (op.payload['pieceId'] as String?) ?? '';
    final String body = (op.payload['body'] as String?) ?? '';
    final String? parentId = op.payload['parentId'] as String?;
    if (body.isEmpty) return const SyncOutcome.success();
    final result = parentId != null
        ? await _repository.reply(parentId, body)
        : await _repository.addComment(pieceId, body);
    return syncOutcomeFromResult(result);
  }

  /// Each queued comment is unique (its temp id is the dedup key), so storage keys
  /// never collide — this only fires defensively and keeps the latest.
  @override
  SyncOperation? merge(SyncOperation incoming, SyncOperation existing) =>
      incoming;
}

/// Authoring repository (docs/40 §16, §21). Wraps the remote data source, merges
/// server responses onto the local [Draft], and translates every transport error
/// to a domain [Failure]. A PURE REMOTE boundary — no local persistence, no
/// queueing (that is the [DraftSyncEngine] / store). Both the online action path
/// and the offline sync engine call these same methods (docs/40 §42; the brief).
library;

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../domain/entities/draft.dart';
import '../../domain/entities/draft_summary.dart';
import '../../domain/repositories/piece_editor_repository.dart';
import '../datasources/piece_editor_remote_data_source.dart';
import '../mappers/piece_write_mappers.dart';

class PieceEditorRepositoryImpl implements PieceEditorRepository {
  PieceEditorRepositoryImpl(this._remote, {DateTime Function()? clock})
    : _now = clock ?? (() => DateTime.now().toUtc());

  final PieceEditorRemoteDataSource _remote;
  final DateTime Function() _now;

  @override
  Future<Result<Draft>> createDraft(Draft draft) => _guard<Draft>(() async {
    final Json data = await _remote.create(pieceRequestBody(draft));
    return mergeServerPiece(draft, data, now: _now());
  });

  @override
  Future<Result<Draft>> updateDraft(Draft draft) => _guard<Draft>(() async {
    final String? id = draft.remoteId;
    if (id == null || id.isEmpty) {
      throw const ApiException(
        code: ErrorCodes.apiUnexpected,
        status: 0,
        message: 'updateDraft called on a draft with no remote id',
      );
    }
    final Json data = await _remote.update(id, pieceRequestBody(draft));
    return mergeServerPiece(draft, data, now: _now());
  });

  @override
  Future<Result<Unit>> deleteDraft(String remoteId) => _guard<Unit>(() async {
    await _remote.delete(remoteId);
    return unit;
  });

  @override
  Future<Result<Draft>> publish(Draft draft) => _guard<Draft>(() async {
    final Json data = await _remote.publish(
      draft.remoteId!,
      idempotencyKey: 'publish-${draft.remoteId}-v${draft.version}',
    );
    return mergeServerPiece(draft, data, now: _now());
  });

  @override
  Future<Result<Draft>> schedule(Draft draft, DateTime scheduledAt) =>
      _guard<Draft>(() async {
        final Json data = await _remote.schedule(draft.remoteId!, scheduledAt);
        return mergeServerPiece(draft, data, now: _now());
      });

  @override
  Future<Result<Draft>> fetchDraft(String remoteId) => _guard<Draft>(() async {
    final Json data = await _remote.fetch(remoteId);
    return draftFromServerPiece(data, localId: 'srv-$remoteId', now: _now());
  });

  @override
  Future<Result<CursorPage<DraftSummary>>> listDrafts({String? cursor}) =>
      _guard<CursorPage<DraftSummary>>(
        () => _remote.listDrafts(cursor: cursor),
      );

  @override
  Future<Result<String>> uploadCover(
    String remoteId, {
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  }) => _guard<String>(
    () => _remote.uploadCover(
      remoteId,
      filePath: filePath,
      mimeType: _mimeFor(filePath),
      onProgress: onProgress,
      uploadKey: uploadKey,
    ),
  );

  @override
  void cancelUpload(String uploadKey) => _remote.cancel(uploadKey);

  /// Run a remote call, translating exceptions to a [Failure] — the single place
  /// authoring transport errors become domain failures.
  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok<T>(await run());
    } on ApiException catch (e) {
      return Err<T>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<T>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  String _mimeFor(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

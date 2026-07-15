/// The authoring boundary (M4; docs/40 §16). The single interface over the frozen
/// `v1` piece-authoring endpoints — create/update/delete drafts, the lifecycle
/// actions (publish/schedule), reading the owner's piece, listing drafts, and cover
/// upload. Returns domain [Result]s of entities — never a DTO, `DioException`, or
/// HTTP status.
///
/// This is a PURE REMOTE boundary: it performs no local persistence and no
/// queueing. BOTH the immediate online action AND the offline [DraftSyncEngine]
/// drive the network through these same methods (docs/40 §42; the brief's
/// "offline sync reuses the same repository interfaces as online publishing").
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../entities/draft.dart';
import '../entities/draft_summary.dart';

/// Progress fraction 0.0–1.0 for a cover upload.
typedef UploadProgress = void Function(double progress);

abstract interface class PieceEditorRepository {
  /// `POST /pieces` — create a draft from [draft]'s authoring fields. Returns the
  /// server copy merged onto the local record (remote id, slug, updatedAt).
  Future<Result<Draft>> createDraft(Draft draft);

  /// `PATCH /pieces/:id` — persist [draft]'s authoring fields to its [remoteId].
  Future<Result<Draft>> updateDraft(Draft draft);

  /// `DELETE /pieces/:id` — soft-delete (204).
  Future<Result<Unit>> deleteDraft(String remoteId);

  /// `POST /pieces/:id/publish` — publish [draft] now (it must already be remote).
  /// Idempotency-Key applied so a re-queue is a safe replay (docs/40 §13.5).
  Future<Result<Draft>> publish(Draft draft);

  /// `POST /pieces/:id/schedule` — schedule [draft] for [scheduledAt] (future).
  Future<Result<Draft>> schedule(Draft draft, DateTime scheduledAt);

  /// `GET /pieces/:id` — the owner's full piece (any status), as a fresh local
  /// [Draft] (localId `srv-<remoteId>`). Used to hydrate a server-only draft for
  /// editing and to read `updatedAt` for conflict checks.
  Future<Result<Draft>> fetchDraft(String remoteId);

  /// `GET /me/drafts` — one cursor page of the writer's drafts.
  Future<Result<CursorPage<DraftSummary>>> listDrafts({String? cursor});

  /// `POST /pieces/:id/cover` — multipart upload of the file at [filePath];
  /// returns the storage key. [onProgress] streams send progress; pass a stable
  /// [uploadKey] to allow [cancelUpload]. Bypasses the 401→refresh interceptor
  /// (docs/40 §34.2) — a 401 surfaces so the caller refreshes and retries.
  Future<Result<String>> uploadCover(
    String remoteId, {
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  });

  /// Abort an in-flight cover upload started with [uploadKey] (screen left).
  void cancelUpload(String uploadKey);
}

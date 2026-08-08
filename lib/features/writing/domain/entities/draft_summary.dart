/// A lightweight drafts-list row (M4; docs/40 §37 memory-efficient lists).
///
/// The drafts screen shows a UNION of local (offline-first) drafts and the
/// server's `GET /me/drafts` page, so this summary omits the heavy `content` map
/// and carries only what a row renders plus the sync state. It is JSON
/// round-trippable so the server list is cached for offline viewing; a local draft
/// projects to one via [DraftSummary.fromDraft].
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/enums.dart';
import 'draft.dart';
import 'draft_sync.dart';

part 'draft_summary.freezed.dart';
part 'draft_summary.g.dart';

@freezed
abstract class DraftSummary with _$DraftSummary {
  const DraftSummary._();

  const factory DraftSummary({
    /// Local record id when a local draft exists for this piece; null for a
    /// server-only piece not yet opened/edited on this device.
    String? localId,
    String? remoteId,
    @Default('') String title,
    @Default(PieceStatus.draft) PieceStatus status,
    @Default(Visibility.public) Visibility visibility,
    @Default(DraftSyncState.synced) DraftSyncState syncState,

    /// The `ERROR_CODES` string from the last failed sync, so the row can say WHY it
    /// failed instead of only that it did. Null for a server row or a clean draft.
    String? lastError,
    @Default(TextDirectionKind.ltr) TextDirectionKind direction,
    String? coverImageKey,
    @Default(0) int wordCount,
    @Default(0) int readingTimeSeconds,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? updatedAt,
  }) = _DraftSummary;

  factory DraftSummary.fromJson(Map<String, dynamic> json) =>
      _$DraftSummaryFromJson(json);

  factory DraftSummary.fromDraft(Draft draft) => DraftSummary(
    localId: draft.localId,
    remoteId: draft.remoteId,
    title: draft.title,
    status: draft.status,
    visibility: draft.visibility,
    syncState: draft.syncState,
    lastError: draft.lastError,
    direction: draft.direction,
    coverImageKey: draft.coverImageKey,
    wordCount: draft.wordCount,
    readingTimeSeconds: draft.readingTimeSeconds,
    publishedAt: draft.publishedAt,
    scheduledAt: draft.scheduledAt,
    updatedAt: draft.localUpdatedAt,
  );

  /// The route target for opening this row (`/write/:id`) — the local id if one
  /// exists, else the remote id (the editor accepts either, hydrating as needed).
  String get routeId => localId ?? remoteId ?? '';

  /// Whether this row has an editable local draft record.
  bool get hasLocal => localId != null && localId!.isNotEmpty;
}

/// The editable draft aggregate (M4 editor; docs/40 §16, §19.1, §42).
///
/// One local, offline-first record of a piece being written: the server-truth
/// authoring fields (title, content, language, genre, tags, visibility, status,
/// cover, schedule) PLUS the local sync metadata (`localId`, sync state, pending
/// intent, conflict base, local revision) that let the app create and edit fully
/// offline and reconcile with the frozen `v1` API on reconnect.
///
/// It is JSON round-trippable (freezed + json_serializable) so it persists to the
/// Hive `drafts` box verbatim — the identical TipTap `content` shape locally and on
/// the wire (the offline-writing seam in docs/40 §42.1). `content` is carried as a
/// raw map (like `PieceDetail.content`); the editor decodes it to an
/// [EditorDocument] via `tiptap_codec` and re-encodes on save.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/enums.dart';
import 'draft_sync.dart';

part 'draft.freezed.dart';
part 'draft.g.dart';

@freezed
abstract class Draft with _$Draft {
  const Draft._();

  const factory Draft({
    /// Stable client identity — the Hive key and the `/write/:id` route param.
    /// Never sent to the server (kept distinct from [remoteId] for offline create).
    required String localId,

    /// The server piece UUID once created; null while the draft is local-only.
    String? remoteId,

    @Default('') String title,
    @Default('') String subtitle,
    @Default('') String featuredQuote,

    /// TipTap `doc` map — the same shape the wire uses (docs/40 §42.1).
    @Default(<String, dynamic>{'type': 'doc', 'content': <dynamic>[]})
    Map<String, dynamic> content,

    /// BCP-47 code (required by the API on create; UI enforces before first sync).
    @Default('') String languageCode,
    @Default('') String languageName,
    @Default(TextDirectionKind.ltr) TextDirectionKind direction,

    String? genreSlug,
    String? genreName,

    @Default(<String>[]) List<String> tags,
    @Default(Visibility.public) Visibility visibility,
    @Default(PieceStatus.draft) PieceStatus status,
    String? slug,

    /// Server storage key for the cover, once uploaded.
    String? coverImageKey,

    /// A locally-picked cover image awaiting upload (offline / not-yet-created).
    String? pendingCoverPath,

    DateTime? scheduledAt,
    DateTime? publishedAt,

    /// The server `updatedAt` this local copy was last synced from — the base for
    /// client-side conflict detection (docs/40 §42.1; see [DraftSyncState]).
    DateTime? remoteUpdatedAt,

    required DateTime createdAt,
    required DateTime localUpdatedAt,

    @Default(0) int wordCount,
    @Default(0) int readingTimeSeconds,

    @Default(DraftSyncState.synced) DraftSyncState syncState,
    @Default(DraftIntent.save) DraftIntent intent,

    /// Monotonic local revision — bumped on every local edit ("draft version
    /// tracking"); surfaced in the UI and used to ignore stale autosave writes.
    @Default(1) int version,

    /// Developer-facing detail of the last failed sync (never shown raw to users).
    String? lastError,
  }) = _Draft;

  factory Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);

  /// Has this draft ever been created on the server?
  bool get isRemote => remoteId != null && remoteId!.isNotEmpty;

  bool get isPublished => status == PieceStatus.published;
  bool get isScheduled => status == PieceStatus.scheduled;

  bool get hasCover =>
      (coverImageKey != null && coverImageKey!.isNotEmpty) ||
      (pendingCoverPath != null && pendingCoverPath!.isNotEmpty);

  bool get hasFeaturedQuote => featuredQuote.trim().isNotEmpty;

  bool get hasLanguage => languageCode.trim().isNotEmpty;

  /// Reading time in whole minutes (rounded up) for the preview meta row.
  int get readingTimeMinutes => readingTimeSeconds <= 0
      ? 0
      : ((readingTimeSeconds + 59) ~/ 60).clamp(1, 1 << 30);

  bool get isRtl => direction == TextDirectionKind.rtl;
}

/// The piece a publication action returns (AF6).
///
/// `POST /stories/{id}/{publish,unpublish,schedule}`, `PATCH /stories/{id}/visibility`
/// and `POST /stories/{id}/snapshots/{snapshotId}/revert` all answer
/// **`PieceResponseDto`** — the whole piece in its new state, not an event and not a
/// snapshot (`publishing.controller.ts:55-102, 185-196`).
///
/// Mobile used to decode all five as [PublicationEvent] (and the revert as
/// [StorySnapshot]). Nothing threw, because both entities default every missing
/// field: `type` came back `''`, `storyId` `''`, `createdAt` epoch-0, and `id` was
/// the *piece* id masquerading as an event/snapshot id — silent junk on a 200
/// (defect **P-1**, `docs/56` §2.2).
///
/// Only the fields a publishing UI needs are mirrored. `content` is deliberately
/// omitted: it is the full TipTap document, the screen does not render it, and the
/// collaboration feature is not the editor. A feature may not import another
/// feature's entities (docs/folder-structure), so this is publishing-local rather
/// than a reuse of the writing feature's `Piece`.
library;

import '../../../../core/utils/typedefs.dart';

class StoryPublicationState {
  const StoryPublicationState({
    required this.id,
    required this.title,
    required this.status,
    required this.visibility,
    required this.wordCount,
    this.slug,
    this.scheduledAt,
    this.publishedAt,
    this.archivedAt,
    this.updatedAt,
  });

  /// The piece id — which is also the story id (`storyId === pieceId`).
  final String id;
  final String title;

  /// `PieceStatus` on the wire (draft / published / archived / scheduled).
  final String status;

  /// `Visibility` on the wire — public / unlisted / private. Never `followers`.
  final String visibility;
  final int wordCount;

  /// Null until the first publish, permanent thereafter.
  final String? slug;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime? archivedAt;
  final DateTime? updatedAt;

  bool get isScheduled => scheduledAt != null && publishedAt == null;
  bool get isPublished => publishedAt != null && archivedAt == null;

  factory StoryPublicationState.fromJson(Json json) => StoryPublicationState(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    status: json['status'] as String? ?? '',
    visibility: json['visibility'] as String? ?? '',
    wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
    slug: json['slug'] as String?,
    scheduledAt: _date(json['scheduledAt']),
    publishedAt: _date(json['publishedAt']),
    archivedAt: _date(json['archivedAt']),
    updatedAt: _date(json['updatedAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

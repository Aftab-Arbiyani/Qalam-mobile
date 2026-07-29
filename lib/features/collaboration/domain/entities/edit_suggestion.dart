/// Edit suggestion entity (AF6) — a proposed text change a reviewer/editor submits
/// for the owner to accept or reject (`GET/POST /stories/{id}/suggestions`).
///
/// Mirrors `SuggestionDto` field for field. It used to parse four keys the wire never
/// sends — `blockId`, `rationale`/`note`, `resolvedBy` (the wire says
/// `resolvedById`) and `authorName` — and to ignore the one that matters, **`anchor`**,
/// leaving the client with a before/after diff and no location for it
/// (defect **C-4**, `docs/56` §2.1).
///
/// Accepting a suggestion rewrites the story: the server replaces the anchored range
/// with `suggestedText` and marks the suggestion accepted in one transaction. A stale
/// anchor — the text at `[from, to)` is no longer `originalText` — is refused with
/// `409 SUGGESTION_CONFLICT` and nothing is written, so the piece must be re-read
/// after an accept (defect **D1**, `docs/56` §3).
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';
import 'text_anchor.dart';

class EditSuggestion {
  const EditSuggestion({
    required this.id,
    required this.storyId,
    required this.authorId,
    required this.anchor,
    required this.originalText,
    required this.suggestedText,
    required this.status,
    this.resolvedById,
    this.resolvedAt,
    this.createdAt,
  });

  final String id;
  final String storyId;
  final String authorId;

  /// Where in the story's plain text the replacement applies. Null only if the
  /// server ever omitted it — `SuggestionDto.anchor` is non-nullable.
  final TextAnchor? anchor;
  final String originalText;
  final String suggestedText;
  final String status;
  final String? resolvedById;
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  bool get isPending => status == SuggestionStatus.pending;
  bool get isAccepted => status == SuggestionStatus.accepted;
  bool get isRejected => status == SuggestionStatus.rejected;
  bool get isWithdrawn => status == SuggestionStatus.withdrawn;

  factory EditSuggestion.fromJson(Json json) => EditSuggestion(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    authorId: json['authorId'] as String? ?? '',
    anchor: TextAnchor.fromJson(json['anchor']),
    originalText: json['originalText'] as String? ?? '',
    suggestedText: json['suggestedText'] as String? ?? '',
    status: json['status'] as String? ?? SuggestionStatus.pending,
    resolvedById: json['resolvedById'] as String?,
    resolvedAt: _date(json['resolvedAt']),
    createdAt: _date(json['createdAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

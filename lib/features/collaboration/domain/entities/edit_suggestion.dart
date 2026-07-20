/// Edit suggestion entity (AF6) — a proposed text change on a story a reviewer/editor
/// submits for the owner to accept or reject (`GET/POST /stories/{id}/suggestions`).
/// The server owns application of an accepted suggestion; the client renders the diff
/// and drives accept / reject / withdraw.
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

class EditSuggestion {
  const EditSuggestion({
    required this.id,
    required this.storyId,
    required this.status,
    required this.authorId,
    required this.originalText,
    required this.suggestedText,
    this.authorName,
    this.blockId,
    this.rationale,
    this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  final String id;
  final String storyId;
  final String status;
  final String authorId;
  final String originalText;
  final String suggestedText;
  final String? authorName;
  final String? blockId;
  final String? rationale;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  bool get isPending => status == SuggestionStatus.pending;
  bool get isAccepted => status == SuggestionStatus.accepted;
  bool get isRejected => status == SuggestionStatus.rejected;
  bool get isWithdrawn => status == SuggestionStatus.withdrawn;

  factory EditSuggestion.fromJson(Json json) => EditSuggestion(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    status: json['status'] as String? ?? SuggestionStatus.pending,
    authorId: json['authorId'] as String? ?? '',
    originalText: json['originalText'] as String? ?? '',
    suggestedText: json['suggestedText'] as String? ?? '',
    authorName: json['authorName'] as String? ?? json['author'] as String?,
    blockId: json['blockId'] as String?,
    rationale: json['rationale'] as String? ?? json['note'] as String?,
    createdAt: _date(json['createdAt']),
    resolvedAt: _date(json['resolvedAt']),
    resolvedBy: json['resolvedBy'] as String?,
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

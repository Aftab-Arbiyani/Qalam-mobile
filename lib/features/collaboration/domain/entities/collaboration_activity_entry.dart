/// Collaboration activity entry (AF6) — one item in a story's collaboration audit
/// feed (`GET /stories/{id}/activity`): who did what, when. Read-only display; the
/// server is authoritative on the log.
library;

import '../../../../core/utils/typedefs.dart';

class CollaborationActivityEntry {
  const CollaborationActivityEntry({
    required this.id,
    required this.storyId,
    required this.type,
    required this.summary,
    required this.metadata,
    required this.createdAt,
    this.actorId,
    this.actorName,
  });

  final String id;
  final String storyId;

  /// A stable event type (e.g. `member.added`, `comment.created`, `review.approved`).
  final String type;
  final String summary;
  final Json metadata;
  final DateTime createdAt;
  final String? actorId;
  final String? actorName;

  factory CollaborationActivityEntry.fromJson(Json json) {
    final Object? meta = json['metadata'];
    return CollaborationActivityEntry(
      id: json['id'] as String? ?? '',
      storyId: json['storyId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      summary: json['summary'] as String? ?? json['message'] as String? ?? '',
      metadata: meta is Map
          ? Map<String, dynamic>.from(meta)
          : const <String, dynamic>{},
      createdAt:
          _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      actorId: json['actorId'] as String?,
      actorName: json['actorName'] as String? ?? json['actor'] as String?,
    );
  }
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

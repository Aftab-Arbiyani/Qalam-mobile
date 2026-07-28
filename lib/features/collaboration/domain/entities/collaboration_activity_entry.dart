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
    required this.actorId,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String storyId;

  /// A stable event type from the `CollaborationActivity` catalogue — snake_case,
  /// e.g. `member_joined`, `comment_added`, `suggestion_accepted`. (The old doc
  /// comment here claimed dot-cased names like `member.added`, which never existed.)
  final String type;

  /// The actor's id. `ActivityDto` carries no name — there is no `actorName` and no
  /// `summary` on the wire, both of which this entity used to parse (defect **C-11**,
  /// `docs/56` §2.1). A UI composes its own sentence from [type] + [metadata].
  final String actorId;
  final Json metadata;
  final DateTime createdAt;

  factory CollaborationActivityEntry.fromJson(Json json) {
    final Object? meta = json['metadata'];
    return CollaborationActivityEntry(
      id: json['id'] as String? ?? '',
      storyId: json['storyId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      actorId: json['actorId'] as String? ?? '',
      metadata: meta is Map
          ? Map<String, dynamic>.from(meta)
          : const <String, dynamic>{},
      createdAt:
          _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

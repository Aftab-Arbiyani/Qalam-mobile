/// Publication event entity (AF6) — one item in a story's publication history
/// (`GET /stories/{id}/publication-history`), and the payload returned by the
/// publish / unpublish / schedule / visibility actions. Read-mostly; the server is
/// authoritative on publication state.
library;

import '../../../../core/utils/typedefs.dart';

class PublicationEvent {
  const PublicationEvent({
    required this.id,
    required this.storyId,
    required this.type,
    required this.createdAt,
    this.actorId,
    this.actorName,
    this.visibility,
    this.scheduledFor,
  });

  final String id;
  final String storyId;

  /// A stable event type (e.g. `published`, `unpublished`, `scheduled`,
  /// `visibility_changed`).
  final String type;
  final DateTime createdAt;
  final String? actorId;
  final String? actorName;
  final String? visibility;
  final DateTime? scheduledFor;

  factory PublicationEvent.fromJson(Json json) => PublicationEvent(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    type: json['type'] as String? ?? '',
    createdAt:
        _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    actorId: json['actorId'] as String?,
    actorName: json['actorName'] as String? ?? json['actor'] as String?,
    visibility: json['visibility'] as String?,
    scheduledFor: _date(json['scheduledFor']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

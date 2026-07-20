/// Story snapshot entity (AF6) — a point-in-time version of a story
/// (`GET/POST /stories/{id}/snapshots`, `GET /snapshots/{id}`). The server owns
/// version storage + reverts; the client lists snapshots and drives create / revert.
library;

import '../../../../core/utils/typedefs.dart';

class StorySnapshot {
  const StorySnapshot({
    required this.id,
    required this.storyId,
    required this.createdAt,
    this.label,
    this.version,
    this.createdBy,
    this.createdByName,
    this.wordCount,
  });

  final String id;
  final String storyId;
  final DateTime createdAt;
  final String? label;
  final int? version;
  final String? createdBy;
  final String? createdByName;
  final int? wordCount;

  factory StorySnapshot.fromJson(Json json) => StorySnapshot(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    createdAt:
        _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    label: json['label'] as String? ?? json['name'] as String?,
    version: (json['version'] as num?)?.toInt(),
    createdBy: json['createdBy'] as String?,
    createdByName: json['createdByName'] as String?,
    wordCount: (json['wordCount'] as num?)?.toInt(),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

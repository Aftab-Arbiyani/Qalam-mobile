/// Story snapshot entity (AF6) — a point-in-time version of a story
/// (`GET/POST /stories/{id}/snapshots`, `GET /snapshots/{id}`). The server owns
/// version storage + reverts; the client lists snapshots and drives create / revert.
library;

import '../../../../core/utils/typedefs.dart';

/// Mirrors `SnapshotDto`. It previously read `label`/`name`, `createdBy` and
/// `createdByName` — none of which the wire sends — and ignored the three fields it
/// does: `title`, `reason` and `createdById` (defect **P-7**, `docs/56` §2.2).
/// A snapshot is identified by its `version`; there is no user-supplied label.
class StorySnapshot {
  const StorySnapshot({
    required this.id,
    required this.storyId,
    required this.version,
    required this.title,
    required this.reason,
    required this.createdAt,
    this.createdById,
    this.wordCount,
  });

  final String id;
  final String storyId;

  /// Monotonic version, newest first as the server returns them.
  final int version;

  /// The story's title at capture time.
  final String title;

  /// Why it was captured: publish / manual / pre_edit / review / restore.
  final String reason;
  final DateTime createdAt;
  final String? createdById;
  final int? wordCount;

  /// What to show in a version list. `title` can be empty on an untitled draft.
  String get label => title.trim().isEmpty ? 'Version $version' : title.trim();

  factory StorySnapshot.fromJson(Json json) => StorySnapshot(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    version: (json['version'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    reason: json['reason'] as String? ?? '',
    createdAt:
        _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    createdById: json['createdById'] as String?,
    wordCount: (json['wordCount'] as num?)?.toInt(),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

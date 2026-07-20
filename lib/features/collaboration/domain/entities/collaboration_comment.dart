/// Collaboration comment entities (AF6) — threaded comments on a story, either
/// free-standing (general) or anchored to a passage (inline), with @mentions and
/// nested replies (`GET/POST /stories/{id}/comments`). The server owns threading +
/// resolution; the client renders the tree and drives reply / resolve / delete.
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';

/// Where an inline comment attaches in the manuscript (block + character range, with
/// the quoted passage for display when the block is no longer in view).
class CommentAnchor {
  const CommentAnchor({this.blockId, this.start, this.end, this.quote});

  final String? blockId;
  final int? start;
  final int? end;
  final String? quote;

  bool get isEmpty => blockId == null && quote == null;

  factory CommentAnchor.fromJson(Json json) => CommentAnchor(
    blockId: json['blockId'] as String?,
    start: (json['start'] as num?)?.toInt(),
    end: (json['end'] as num?)?.toInt(),
    quote: json['quote'] as String?,
  );

  Json toJson() => <String, Object?>{
    'blockId': ?blockId,
    'start': ?start,
    'end': ?end,
    'quote': ?quote,
  };
}

class CollaborationComment {
  const CollaborationComment({
    required this.id,
    required this.storyId,
    required this.kind,
    required this.status,
    required this.body,
    required this.authorId,
    required this.mentions,
    required this.replies,
    this.authorName,
    this.authorAvatarKey,
    this.parentId,
    this.anchor,
    this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String storyId;
  final String kind;
  final String status;
  final String body;
  final String authorId;
  final List<String> mentions;
  final List<CollaborationComment> replies;
  final String? authorName;
  final String? authorAvatarKey;
  final String? parentId;
  final CommentAnchor? anchor;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  bool get isResolved => status == CommentStatus.resolved;
  bool get isInline => kind == CommentKind.inline;
  bool get isReply => parentId != null;

  factory CollaborationComment.fromJson(Json json) {
    final Object? anchorRaw = json['anchor'];
    return CollaborationComment(
      id: json['id'] as String? ?? '',
      storyId: json['storyId'] as String? ?? '',
      kind: json['kind'] as String? ?? CommentKind.general,
      status: json['status'] as String? ?? CommentStatus.open,
      body: json['body'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      mentions: _stringList(json['mentions']),
      replies: (json['replies'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (dynamic e) => CollaborationComment.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(growable: false),
      authorName: json['authorName'] as String? ?? json['author'] as String?,
      authorAvatarKey: json['authorAvatarKey'] as String?,
      parentId: json['parentId'] as String?,
      anchor: anchorRaw is Map
          ? CommentAnchor.fromJson(Map<String, dynamic>.from(anchorRaw))
          : null,
      createdAt: _date(json['createdAt']),
      resolvedAt: _date(json['resolvedAt']),
    );
  }
}

List<String> _stringList(Object? raw) => raw is List
    ? raw.whereType<String>().toList(growable: false)
    : const <String>[];

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

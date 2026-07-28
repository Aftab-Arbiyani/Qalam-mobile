/// Collaboration comment entity (AF6) — a comment on a story, either free-standing
/// (general) or anchored to a passage (inline), with @mentions
/// (`GET/POST /stories/{id}/comments`). The server owns threading + resolution.
///
/// Mirrors `CommentDto` field for field. Three things it used to get wrong
/// (`docs/56` §2.1):
///
/// - It parsed a **`replies`** array. `CommentDto` has no such field — the list
///   endpoint returns ROOT comments only (`listRootComments`) and a thread comes from
///   `GET /comments/:id/thread`. So `replies` was always empty and the "threaded"
///   screen could never show a thread (**C-5**). Replies now arrive via
///   [CommentThread] and are held separately from the comment itself.
/// - It parsed `authorName` / `authorAvatarKey`, which the wire never sends — the DTO
///   carries `authorId` only.
/// - It read `resolvedAt`, which does not exist; the wire says **`resolvedById`**.
library;

import '../../../../core/utils/typedefs.dart';
import 'collaboration_enums.dart';
import 'text_anchor.dart';

class CollaborationComment {
  const CollaborationComment({
    required this.id,
    required this.storyId,
    required this.authorId,
    required this.kind,
    required this.status,
    required this.body,
    required this.mentions,
    this.parentId,
    this.anchor,
    this.resolvedById,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String storyId;
  final String authorId;
  final String kind;
  final String status;
  final String body;

  /// Resolved @mentioned user **ids** (the wire has no handles here).
  final List<String> mentions;
  final String? parentId;
  final TextAnchor? anchor;

  /// Who resolved the thread, if anyone.
  final String? resolvedById;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isResolved => status == CommentStatus.resolved;
  bool get isInline => kind == CommentKind.inline;
  bool get isReply => parentId != null;

  factory CollaborationComment.fromJson(Json json) => CollaborationComment(
    id: json['id'] as String? ?? '',
    storyId: json['storyId'] as String? ?? '',
    authorId: json['authorId'] as String? ?? '',
    kind: json['kind'] as String? ?? CommentKind.general,
    status: json['status'] as String? ?? CommentStatus.open,
    body: json['body'] as String? ?? '',
    mentions: _stringList(json['mentions']),
    parentId: json['parentId'] as String?,
    anchor: TextAnchor.fromJson(json['anchor']),
    resolvedById: json['resolvedById'] as String?,
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );
}

/// `CommentThreadDto` — a root comment plus its replies
/// (`GET /comments/:id/thread`). The endpoint 404s for a non-root id.
class CommentThread {
  const CommentThread({required this.comment, required this.replies});

  final CollaborationComment comment;
  final List<CollaborationComment> replies;

  int get replyCount => replies.length;

  factory CommentThread.fromJson(Json json) => CommentThread(
    comment: CollaborationComment.fromJson(
      json['comment'] is Map
          ? Json.from(json['comment'] as Map<dynamic, dynamic>)
          : const <String, dynamic>{},
    ),
    replies: (json['replies'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> e) =>
              CollaborationComment.fromJson(Json.from(e)),
        )
        .toList(growable: false),
  );
}

List<String> _stringList(Object? raw) => raw is List
    ? raw.whereType<String>().toList(growable: false)
    : const <String>[];

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

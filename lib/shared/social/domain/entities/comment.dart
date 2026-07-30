/// A comment (or reply) on a piece (docs/40 E7) — mirrors the backend
/// `CommentResponseDto`. A soft-deleted comment keeps its node (replies stay
/// visible) but its [author] is null and [body] is the tombstone text; the client
/// renders the placeholder. Cached to Hive for offline reading of a thread.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
abstract class CommentAuthor with _$CommentAuthor {
  const CommentAuthor._();

  const factory CommentAuthor({
    required String username,
    String? penName,
    String? avatarKey,
  }) = _CommentAuthor;

  factory CommentAuthor.fromJson(Map<String, dynamic> json) =>
      _$CommentAuthorFromJson(json);

  String get displayName => (penName != null && penName!.trim().isNotEmpty)
      ? penName!.trim()
      : '@$username';

  String get handle => '@$username';
}

@freezed
abstract class Comment with _$Comment {
  const Comment._();

  const factory Comment({
    required String id,
    String? parentId,
    @Default(1) int depth,
    CommentAuthor? author,
    @Default('') String body,
    @Default(false) bool isDeleted,
    @Default(0) int replyCount,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  bool get isTopLevel => parentId == null;
  bool get hasReplies => replyCount > 0;
  bool get wasEdited => editedAt != null;
}

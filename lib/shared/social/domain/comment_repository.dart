/// The comments boundary (docs/40 §16, E7) — top-level comments on a piece and
/// replies to a comment (both cursor-paginated, cache-then-network for offline
/// reading), plus add / reply / edit / delete. Owner-only edit/delete is enforced
/// server-side. Returns domain [Result]s — never a DTO or HTTP status.
library;

import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../../pagination/cached_page.dart';
import 'entities/comment.dart';

abstract interface class CommentRepository {
  Future<Result<CachedPage<Comment>>> listComments(
    String pieceId, {
    String? cursor,
  });

  Future<Result<CachedPage<Comment>>> listReplies(
    String commentId, {
    String? cursor,
  });

  Future<Result<Comment>> addComment(String pieceId, String body);

  Future<Result<Comment>> reply(String commentId, String body);

  Future<Result<Comment>> edit(String commentId, String body);

  Future<Result<Unit>> delete(String commentId);
}

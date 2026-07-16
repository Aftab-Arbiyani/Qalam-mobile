/// Comments remote data source (docs/40 §17.1) — the only place comment
/// mutations/reads touch the wire. Lists return cursor pages of [Comment]; add /
/// reply / edit return the created/updated [Comment]; delete is a 204.
library;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/typedefs.dart';
import '../../api/api_envelope.dart';
import '../domain/entities/comment.dart';
import 'mappers/social_mappers.dart';

class CommentRemoteDataSource {
  CommentRemoteDataSource(this._api);

  final ApiClient _api;

  static const int _limit = 20;

  Future<CursorPage<Comment>> listComments(String pieceId, {String? cursor}) =>
      _api.getPage<Comment>(
        ApiPaths.pieceComments(pieceId),
        query: _page(cursor),
        decodeItem: commentFromJson,
      );

  Future<CursorPage<Comment>> listReplies(String commentId, {String? cursor}) =>
      _api.getPage<Comment>(
        ApiPaths.commentReplies(commentId),
        query: _page(cursor),
        decodeItem: commentFromJson,
      );

  Future<Comment> addComment(String pieceId, String body) => _api.post<Comment>(
    ApiPaths.pieceComments(pieceId),
    body: <String, Object?>{'body': body},
    decode: commentFromJson,
  );

  Future<Comment> reply(String commentId, String body) => _api.post<Comment>(
    ApiPaths.commentReplies(commentId),
    body: <String, Object?>{'body': body},
    decode: commentFromJson,
  );

  Future<Comment> edit(String commentId, String body) => _api.patch<Comment>(
    ApiPaths.comment(commentId),
    body: <String, Object?>{'body': body},
    decode: commentFromJson,
  );

  Future<void> delete(String commentId) =>
      _api.delete(ApiPaths.comment(commentId));

  Json _page(String? cursor) =>
      <String, dynamic>{'cursor': ?cursor, 'limit': _limit};
}

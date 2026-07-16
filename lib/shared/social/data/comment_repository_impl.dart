/// Comments repository (docs/40 §16, §23). Lists delegate to the shared
/// [loadCachedPage] engine (page-1 cached for offline reading + stale fallback);
/// mutations are guarded and never retried (presentation owns optimistic apply).
library;

import '../../../core/error/api_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/storage/cache_policy.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../../data/cache_list_data_source.dart';
import '../../data/cached_page_loader.dart';
import '../../domain/error_codes.dart';
import '../../pagination/cached_page.dart';
import '../domain/comment_repository.dart';
import '../domain/entities/comment.dart';
import 'comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._remote, this._cache);

  final CommentRemoteDataSource _remote;
  final CacheListDataSource _cache;

  @override
  Future<Result<CachedPage<Comment>>> listComments(
    String pieceId, {
    String? cursor,
  }) => loadCachedPage<Comment>(
    cache: _cache,
    cacheKey: 'comments:piece:$pieceId',
    cursor: cursor,
    fetch: (String? c) => _remote.listComments(pieceId, cursor: c),
    toJson: (Comment x) => x.toJson(),
    fromJson: Comment.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<CachedPage<Comment>>> listReplies(
    String commentId, {
    String? cursor,
  }) => loadCachedPage<Comment>(
    cache: _cache,
    cacheKey: 'comments:replies:$commentId',
    cursor: cursor,
    fetch: (String? c) => _remote.listReplies(commentId, cursor: c),
    toJson: (Comment x) => x.toJson(),
    fromJson: Comment.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<Comment>> addComment(String pieceId, String body) =>
      _guard(() => _remote.addComment(pieceId, body));

  @override
  Future<Result<Comment>> reply(String commentId, String body) =>
      _guard(() => _remote.reply(commentId, body));

  @override
  Future<Result<Comment>> edit(String commentId, String body) =>
      _guard(() => _remote.edit(commentId, body));

  @override
  Future<Result<Unit>> delete(String commentId) => _guard<Unit>(() async {
    await _remote.delete(commentId);
    return unit;
  });

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok<T>(await run());
    } on ApiException catch (e) {
      return Err<T>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<T>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }
}

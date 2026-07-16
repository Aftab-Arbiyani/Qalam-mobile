/// Canned social repositories for widget/provider tests — no network. Each
/// exposes seedable lists and a `failNext` toggle to exercise rollback paths.
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/pagination/cached_page.dart';
import 'package:qalam_mobile/shared/social/domain/collection_repository.dart';
import 'package:qalam_mobile/shared/social/domain/comment_repository.dart';
import 'package:qalam_mobile/shared/social/domain/entities/collection.dart';
import 'package:qalam_mobile/shared/social/domain/entities/comment.dart';
import 'package:qalam_mobile/shared/social/domain/entities/follow_user.dart';
import 'package:qalam_mobile/shared/social/domain/entities/response_item.dart';
import 'package:qalam_mobile/shared/social/domain/follow_repository.dart';
import 'package:qalam_mobile/shared/social/domain/response_repository.dart';

CachedPage<T> fakeCachedPage<T>(List<T> items) => CachedPage<T>(
  page: CursorPage<T>(items: items, meta: const CursorMeta()),
);

const NetworkFailure _failure = NetworkFailure(code: 'API_NETWORK_ERROR');

class FakeCommentRepository implements CommentRepository {
  FakeCommentRepository({
    this.comments = const <Comment>[],
    this.replies = const <Comment>[],
  });

  List<Comment> comments;
  List<Comment> replies;
  bool failNext = false;

  Result<T> _guard<T>(T value) {
    if (failNext) {
      failNext = false;
      return Err<T>(_failure);
    }
    return Ok<T>(value);
  }

  @override
  Future<Result<CachedPage<Comment>>> listComments(String pieceId, {String? cursor}) async =>
      Ok<CachedPage<Comment>>(fakeCachedPage(comments));

  @override
  Future<Result<CachedPage<Comment>>> listReplies(String commentId, {String? cursor}) async =>
      Ok<CachedPage<Comment>>(fakeCachedPage(replies));

  @override
  Future<Result<Comment>> addComment(String pieceId, String body) async =>
      _guard<Comment>(Comment(id: 'server-1', body: body));

  @override
  Future<Result<Comment>> reply(String commentId, String body) async =>
      _guard<Comment>(Comment(id: 'server-r', parentId: commentId, depth: 2, body: body));

  @override
  Future<Result<Comment>> edit(String commentId, String body) async =>
      _guard<Comment>(Comment(id: commentId, body: body));

  @override
  Future<Result<Unit>> delete(String commentId) async => _guard<Unit>(unit);
}

class FakeFollowRepository implements FollowRepository {
  FakeFollowRepository({
    this.followerUsers = const <FollowUser>[],
    this.followingUsers = const <FollowUser>[],
    this.pendingRequests = const <FollowRequest>[],
  });

  List<FollowUser> followerUsers;
  List<FollowUser> followingUsers;
  List<FollowRequest> pendingRequests;
  bool failNext = false;

  Result<Unit> _guardUnit() {
    if (failNext) {
      failNext = false;
      return const Err<Unit>(_failure);
    }
    return const Ok<Unit>(unit);
  }

  @override
  Future<Result<CachedPage<FollowUser>>> followers(String username, {String? cursor}) async =>
      Ok<CachedPage<FollowUser>>(fakeCachedPage(followerUsers));

  @override
  Future<Result<CachedPage<FollowUser>>> following(String username, {String? cursor}) async =>
      Ok<CachedPage<FollowUser>>(fakeCachedPage(followingUsers));

  @override
  Future<Result<CachedPage<FollowRequest>>> requests({String? cursor}) async =>
      Ok<CachedPage<FollowRequest>>(fakeCachedPage(pendingRequests));

  @override
  Future<Result<Unit>> acceptRequest(String followId) async => _guardUnit();

  @override
  Future<Result<Unit>> rejectRequest(String followId) async => _guardUnit();
}

class FakeCollectionRepository implements CollectionRepository {
  FakeCollectionRepository({
    this.collections = const <Collection>[],
    this.pieces = const <CollectionPieceItem>[],
  });

  List<Collection> collections;
  List<CollectionPieceItem> pieces;
  bool failNext = false;

  Result<T> _guard<T>(T value) {
    if (failNext) {
      failNext = false;
      return Err<T>(_failure);
    }
    return Ok<T>(value);
  }

  @override
  Future<Result<CachedPage<Collection>>> myCollections({String? cursor}) async =>
      Ok<CachedPage<Collection>>(fakeCachedPage(collections));

  @override
  Future<Result<Collection>> getCollection(String id) async =>
      _guard<Collection>(Collection(id: id, title: 'C'));

  @override
  Future<Result<CachedPage<CollectionPieceItem>>> collectionPieces(String id, {String? cursor}) async =>
      Ok<CachedPage<CollectionPieceItem>>(fakeCachedPage(pieces));

  @override
  Future<Result<Collection>> create({
    required String title,
    String? description,
    Visibility? visibility,
  }) async => _guard<Collection>(Collection(id: 'new', title: title));

  @override
  Future<Result<Collection>> update(String id, {String? title, String? description, Visibility? visibility}) async =>
      _guard<Collection>(Collection(id: id, title: title ?? 'C'));

  @override
  Future<Result<Unit>> delete(String id) async => _guard<Unit>(unit);

  @override
  Future<Result<Unit>> addPiece(String collectionId, String pieceId, {String? note}) async =>
      _guard<Unit>(unit);

  @override
  Future<Result<Unit>> removePiece(String collectionId, String pieceId) async => _guard<Unit>(unit);
}

class FakeResponseRepository implements ResponseRepository {
  FakeResponseRepository({this.responses = const <ResponseItem>[], this.newDraftId = 'draft-1'});

  List<ResponseItem> responses;
  String newDraftId;
  bool failNext = false;

  @override
  Future<Result<CachedPage<ResponseItem>>> listResponses(String pieceId, {String? cursor}) async =>
      Ok<CachedPage<ResponseItem>>(fakeCachedPage(responses));

  @override
  Future<Result<String>> createResponse(String pieceId, {String? title, required String languageCode}) async {
    if (failNext) {
      failNext = false;
      return const Err<String>(_failure);
    }
    return Ok<String>(newDraftId);
  }
}

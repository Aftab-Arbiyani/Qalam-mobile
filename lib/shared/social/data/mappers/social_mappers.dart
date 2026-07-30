/// Wire → entity mappers for the social module (docs/40 §18). The only code that
/// knows the comment / follow-user / collection / response wire shapes. Pure,
/// total, tolerant — a missing/typed-wrong field coerces to a default, never a
/// throw (docs/40 §18.2).
library;

import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../domain/enums.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/follow_user.dart';
import '../../domain/entities/response_item.dart';

Comment commentFromJson(Json json) {
  final Object? rawAuthor = json['author'];
  return Comment(
    id: asString(json['id']),
    parentId: asStringOrNull(json['parentId']),
    depth: asInt(json['depth'], 1),
    author: rawAuthor is Map
        ? CommentAuthor(
            username: asString(rawAuthor['username']),
            penName: asStringOrNull(rawAuthor['penName']),
            avatarKey: asStringOrNull(rawAuthor['avatarKey']),
          )
        : null,
    body: asString(json['body']),
    isDeleted: asBool(json['isDeleted']),
    replyCount: asInt(json['replyCount']),
    editedAt: asUtcDateOrNull(json['editedAt']),
    createdAt: asUtcDateOrNull(json['createdAt']),
    updatedAt: asUtcDateOrNull(json['updatedAt']),
  );
}

FollowUser followUserFromJson(Json json) => FollowUser(
  id: asString(json['id']),
  username: asString(json['username']),
  penName: asStringOrNull(json['penName']),
  avatarKey: asStringOrNull(json['avatarKey']),
);

FollowRequest followRequestFromJson(Json json) => FollowRequest(
  id: asString(json['id']),
  requester: followUserFromJson(asMap(json['requester'])),
  requestedAt: asUtcDateOrNull(json['requestedAt']),
);

Collection collectionFromJson(Json json) => Collection(
  id: asString(json['id']),
  title: asString(json['title']),
  slug: asString(json['slug']),
  description: asStringOrNull(json['description']),
  coverImageKey: asStringOrNull(json['coverImageKey']),
  visibility: Visibility.fromWire(asStringOrNull(json['visibility'])),
  isDefault: asBool(json['isDefault']),
  piecesCount: asInt(json['piecesCount']),
  createdAt: asUtcDateOrNull(json['createdAt']),
  updatedAt: asUtcDateOrNull(json['updatedAt']),
);

CollectionPieceItem collectionPieceItemFromJson(Json json) =>
    CollectionPieceItem(
      pieceId: asString(json['pieceId']),
      slug: asStringOrNull(json['slug']),
      title: asString(json['title']),
      position: asInt(json['position']),
      note: asStringOrNull(json['note']),
      addedAt: asUtcDateOrNull(json['addedAt']),
    );

ResponseItem responseItemFromJson(Json json) => ResponseItem(
  pieceId: asString(json['pieceId']),
  slug: asStringOrNull(json['slug']),
  title: asString(json['title']),
  subtitle: asStringOrNull(json['subtitle']),
  author: ResponseAuthor(
    username: asString(asMap(json['author'])['username']),
    penName: asStringOrNull(asMap(json['author'])['penName']),
  ),
  publishedAt: asUtcDateOrNull(json['publishedAt']),
  respondedAt: asUtcDateOrNull(json['respondedAt']),
);

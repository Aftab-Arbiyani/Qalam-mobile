// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentAuthor _$CommentAuthorFromJson(Map<String, dynamic> json) =>
    _CommentAuthor(
      username: json['username'] as String,
      penName: json['penName'] as String?,
      avatarKey: json['avatarKey'] as String?,
    );

Map<String, dynamic> _$CommentAuthorToJson(_CommentAuthor instance) =>
    <String, dynamic>{
      'username': instance.username,
      'penName': instance.penName,
      'avatarKey': instance.avatarKey,
    };

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  parentId: json['parentId'] as String?,
  depth: (json['depth'] as num?)?.toInt() ?? 1,
  author: json['author'] == null
      ? null
      : CommentAuthor.fromJson(json['author'] as Map<String, dynamic>),
  body: json['body'] as String? ?? '',
  isDeleted: json['isDeleted'] as bool? ?? false,
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  editedAt: json['editedAt'] == null
      ? null
      : DateTime.parse(json['editedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'parentId': instance.parentId,
  'depth': instance.depth,
  'author': instance.author?.toJson(),
  'body': instance.body,
  'isDeleted': instance.isDeleted,
  'replyCount': instance.replyCount,
  'editedAt': instance.editedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

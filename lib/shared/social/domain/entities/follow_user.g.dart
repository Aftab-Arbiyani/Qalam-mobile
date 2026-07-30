// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowUser _$FollowUserFromJson(Map<String, dynamic> json) => _FollowUser(
  id: json['id'] as String,
  username: json['username'] as String,
  penName: json['penName'] as String?,
  avatarKey: json['avatarKey'] as String?,
);

Map<String, dynamic> _$FollowUserToJson(_FollowUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'penName': instance.penName,
      'avatarKey': instance.avatarKey,
    };

_FollowRequest _$FollowRequestFromJson(Map<String, dynamic> json) =>
    _FollowRequest(
      id: json['id'] as String,
      requester: FollowUser.fromJson(json['requester'] as Map<String, dynamic>),
      requestedAt: json['requestedAt'] == null
          ? null
          : DateTime.parse(json['requestedAt'] as String),
    );

Map<String, dynamic> _$FollowRequestToJson(_FollowRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requester': instance.requester.toJson(),
      'requestedAt': instance.requestedAt?.toIso8601String(),
    };

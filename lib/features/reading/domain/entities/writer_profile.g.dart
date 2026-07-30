// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writer_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WriterProfile _$WriterProfileFromJson(Map<String, dynamic> json) =>
    _WriterProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      penName: json['penName'] as String? ?? '',
      avatarKey: json['avatarKey'] as String?,
      bio: json['bio'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      piecesCount: (json['piecesCount'] as num?)?.toInt() ?? 0,
      isSelf: json['isSelf'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      hasPendingRequest: json['hasPendingRequest'] as bool? ?? false,
      restricted: json['restricted'] as bool? ?? false,
    );

Map<String, dynamic> _$WriterProfileToJson(_WriterProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'penName': instance.penName,
      'avatarKey': instance.avatarKey,
      'bio': instance.bio,
      'isPrivate': instance.isPrivate,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'piecesCount': instance.piecesCount,
      'isSelf': instance.isSelf,
      'isFollowing': instance.isFollowing,
      'hasPendingRequest': instance.hasPendingRequest,
      'restricted': instance.restricted,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writer_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WriterSummary _$WriterSummaryFromJson(Map<String, dynamic> json) =>
    _WriterSummary(
      username: json['username'] as String,
      penName: json['penName'] as String?,
      avatarKey: json['avatarKey'] as String?,
      bio: json['bio'] as String?,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      piecesCount: (json['piecesCount'] as num?)?.toInt() ?? 0,
      isPrivate: json['isPrivate'] as bool? ?? false,
    );

Map<String, dynamic> _$WriterSummaryToJson(_WriterSummary instance) =>
    <String, dynamic>{
      'username': instance.username,
      'penName': instance.penName,
      'avatarKey': instance.avatarKey,
      'bio': instance.bio,
      'followersCount': instance.followersCount,
      'piecesCount': instance.piecesCount,
      'isPrivate': instance.isPrivate,
    };

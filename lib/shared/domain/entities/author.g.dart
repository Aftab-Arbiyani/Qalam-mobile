// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Author _$AuthorFromJson(Map<String, dynamic> json) => _Author(
  username: json['username'] as String,
  penName: json['penName'] as String?,
  avatarKey: json['avatarKey'] as String?,
);

Map<String, dynamic> _$AuthorToJson(_Author instance) => <String, dynamic>{
  'username': instance.username,
  'penName': instance.penName,
  'avatarKey': instance.avatarKey,
};

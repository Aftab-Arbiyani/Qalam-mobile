// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewer_relation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ViewerRelation _$ViewerRelationFromJson(Map<String, dynamic> json) =>
    _ViewerRelation(
      isSelf: json['isSelf'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      hasPendingRequest: json['hasPendingRequest'] as bool? ?? false,
    );

Map<String, dynamic> _$ViewerRelationToJson(_ViewerRelation instance) =>
    <String, dynamic>{
      'isSelf': instance.isSelf,
      'isFollowing': instance.isFollowing,
      'hasPendingRequest': instance.hasPendingRequest,
    };

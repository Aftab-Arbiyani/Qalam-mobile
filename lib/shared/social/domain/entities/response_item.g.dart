// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResponseAuthor _$ResponseAuthorFromJson(Map<String, dynamic> json) =>
    _ResponseAuthor(
      username: json['username'] as String,
      penName: json['penName'] as String?,
    );

Map<String, dynamic> _$ResponseAuthorToJson(_ResponseAuthor instance) =>
    <String, dynamic>{
      'username': instance.username,
      'penName': instance.penName,
    };

_ResponseItem _$ResponseItemFromJson(Map<String, dynamic> json) =>
    _ResponseItem(
      pieceId: json['pieceId'] as String,
      slug: json['slug'] as String?,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      author: ResponseAuthor.fromJson(json['author'] as Map<String, dynamic>),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$ResponseItemToJson(_ResponseItem instance) =>
    <String, dynamic>{
      'pieceId': instance.pieceId,
      'slug': instance.slug,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'author': instance.author.toJson(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };

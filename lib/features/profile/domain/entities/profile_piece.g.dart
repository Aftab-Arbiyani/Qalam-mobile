// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_piece.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfilePiece _$ProfilePieceFromJson(Map<String, dynamic> json) =>
    _ProfilePiece(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String?,
      coverImageKey: json['coverImageKey'] as String?,
      wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
      readingTimeSeconds: (json['readingTimeSeconds'] as num?)?.toInt() ?? 0,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$ProfilePieceToJson(_ProfilePiece instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'coverImageKey': instance.coverImageKey,
      'wordCount': instance.wordCount,
      'readingTimeSeconds': instance.readingTimeSeconds,
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

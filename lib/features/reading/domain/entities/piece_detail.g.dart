// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PieceDetail _$PieceDetailFromJson(Map<String, dynamic> json) => _PieceDetail(
  id: json['id'] as String,
  title: json['title'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  content:
      json['content'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  subtitle: json['subtitle'] as String?,
  slug: json['slug'] as String?,
  featuredQuote: json['featuredQuote'] as String?,
  coverImageKey: json['coverImageKey'] as String?,
  language: json['language'] == null
      ? null
      : LanguageRef.fromJson(json['language'] as Map<String, dynamic>),
  genre: json['genre'] == null
      ? null
      : GenreRef.fromJson(json['genre'] as Map<String, dynamic>),
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => TagRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TagRef>[],
  status:
      $enumDecodeNullable(_$PieceStatusEnumMap, json['status']) ??
      PieceStatus.published,
  visibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
      Visibility.public,
  wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
  readingTimeSeconds: (json['readingTimeSeconds'] as num?)?.toInt() ?? 0,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$PieceDetailToJson(_PieceDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author.toJson(),
      'content': instance.content,
      'subtitle': instance.subtitle,
      'slug': instance.slug,
      'featuredQuote': instance.featuredQuote,
      'coverImageKey': instance.coverImageKey,
      'language': instance.language?.toJson(),
      'genre': instance.genre?.toJson(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
      'status': _$PieceStatusEnumMap[instance.status]!,
      'visibility': _$VisibilityEnumMap[instance.visibility]!,
      'wordCount': instance.wordCount,
      'readingTimeSeconds': instance.readingTimeSeconds,
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

const _$PieceStatusEnumMap = {
  PieceStatus.draft: 'draft',
  PieceStatus.scheduled: 'scheduled',
  PieceStatus.published: 'published',
  PieceStatus.archived: 'archived',
};

const _$VisibilityEnumMap = {
  Visibility.public: 'public',
  Visibility.unlisted: 'unlisted',
  Visibility.private: 'private',
};

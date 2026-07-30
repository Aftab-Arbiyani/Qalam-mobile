// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PieceSummaryStats _$PieceSummaryStatsFromJson(Map<String, dynamic> json) =>
    _PieceSummaryStats(
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      claps: (json['claps'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      responses: (json['responses'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PieceSummaryStatsToJson(_PieceSummaryStats instance) =>
    <String, dynamic>{
      'likes': instance.likes,
      'claps': instance.claps,
      'comments': instance.comments,
      'responses': instance.responses,
    };

_PieceSummary _$PieceSummaryFromJson(Map<String, dynamic> json) =>
    _PieceSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      language: LanguageRef.fromJson(json['language'] as Map<String, dynamic>),
      slug: json['slug'] as String?,
      subtitle: json['subtitle'] as String?,
      featuredQuote: json['featuredQuote'] as String?,
      coverImageKey: json['coverImageKey'] as String?,
      genre: json['genre'] == null
          ? null
          : GenreRef.fromJson(json['genre'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? const PieceSummaryStats()
          : PieceSummaryStats.fromJson(json['stats'] as Map<String, dynamic>),
      visibility:
          $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
          Visibility.public,
      wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
      readingTimeSeconds: (json['readingTimeSeconds'] as num?)?.toInt() ?? 0,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$PieceSummaryToJson(_PieceSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author.toJson(),
      'language': instance.language.toJson(),
      'slug': instance.slug,
      'subtitle': instance.subtitle,
      'featuredQuote': instance.featuredQuote,
      'coverImageKey': instance.coverImageKey,
      'genre': instance.genre?.toJson(),
      'stats': instance.stats.toJson(),
      'visibility': _$VisibilityEnumMap[instance.visibility]!,
      'wordCount': instance.wordCount,
      'readingTimeSeconds': instance.readingTimeSeconds,
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

const _$VisibilityEnumMap = {
  Visibility.public: 'public',
  Visibility.unlisted: 'unlisted',
  Visibility.private: 'private',
};

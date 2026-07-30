// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trending_searches.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrendingKeyword _$TrendingKeywordFromJson(Map<String, dynamic> json) =>
    _TrendingKeyword(
      keyword: json['keyword'] as String,
      searchCount: (json['searchCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TrendingKeywordToJson(_TrendingKeyword instance) =>
    <String, dynamic>{
      'keyword': instance.keyword,
      'searchCount': instance.searchCount,
    };

_TrendingSearches _$TrendingSearchesFromJson(Map<String, dynamic> json) =>
    _TrendingSearches(
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => TrendingKeyword.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TrendingKeyword>[],
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => TrendingTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TrendingTag>[],
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => TrendingGenre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TrendingGenre>[],
      writers:
          (json['writers'] as List<dynamic>?)
              ?.map((e) => WriterSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WriterSummary>[],
    );

Map<String, dynamic> _$TrendingSearchesToJson(_TrendingSearches instance) =>
    <String, dynamic>{
      'keywords': instance.keywords.map((e) => e.toJson()).toList(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
      'genres': instance.genres.map((e) => e.toJson()).toList(),
      'writers': instance.writers.map((e) => e.toJson()).toList(),
    };

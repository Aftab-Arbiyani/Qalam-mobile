// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GlobalSearchResult _$GlobalSearchResultFromJson(Map<String, dynamic> json) =>
    _GlobalSearchResult(
      writers:
          (json['writers'] as List<dynamic>?)
              ?.map((e) => WriterSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WriterSummary>[],
      pieces:
          (json['pieces'] as List<dynamic>?)
              ?.map((e) => PieceSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PieceSummary>[],
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
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => TrendingLanguage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TrendingLanguage>[],
    );

Map<String, dynamic> _$GlobalSearchResultToJson(_GlobalSearchResult instance) =>
    <String, dynamic>{
      'writers': instance.writers.map((e) => e.toJson()).toList(),
      'pieces': instance.pieces.map((e) => e.toJson()).toList(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
      'genres': instance.genres.map((e) => e.toJson()).toList(),
      'languages': instance.languages.map((e) => e.toJson()).toList(),
    };

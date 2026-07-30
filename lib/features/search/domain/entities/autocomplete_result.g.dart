// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autocomplete_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WriterSuggestion _$WriterSuggestionFromJson(Map<String, dynamic> json) =>
    _WriterSuggestion(
      username: json['username'] as String,
      penName: json['penName'] as String?,
      avatarKey: json['avatarKey'] as String?,
    );

Map<String, dynamic> _$WriterSuggestionToJson(_WriterSuggestion instance) =>
    <String, dynamic>{
      'username': instance.username,
      'penName': instance.penName,
      'avatarKey': instance.avatarKey,
    };

_TagSuggestion _$TagSuggestionFromJson(Map<String, dynamic> json) =>
    _TagSuggestion(
      slug: json['slug'] as String,
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$TagSuggestionToJson(_TagSuggestion instance) =>
    <String, dynamic>{'slug': instance.slug, 'name': instance.name};

_GenreSuggestion _$GenreSuggestionFromJson(Map<String, dynamic> json) =>
    _GenreSuggestion(
      slug: json['slug'] as String,
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$GenreSuggestionToJson(_GenreSuggestion instance) =>
    <String, dynamic>{'slug': instance.slug, 'name': instance.name};

_PieceSuggestion _$PieceSuggestionFromJson(Map<String, dynamic> json) =>
    _PieceSuggestion(
      slug: json['slug'] as String?,
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$PieceSuggestionToJson(_PieceSuggestion instance) =>
    <String, dynamic>{'slug': instance.slug, 'title': instance.title};

_AutocompleteResult _$AutocompleteResultFromJson(Map<String, dynamic> json) =>
    _AutocompleteResult(
      writers:
          (json['writers'] as List<dynamic>?)
              ?.map((e) => WriterSuggestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WriterSuggestion>[],
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => TagSuggestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TagSuggestion>[],
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreSuggestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GenreSuggestion>[],
      pieces:
          (json['pieces'] as List<dynamic>?)
              ?.map((e) => PieceSuggestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PieceSuggestion>[],
    );

Map<String, dynamic> _$AutocompleteResultToJson(_AutocompleteResult instance) =>
    <String, dynamic>{
      'writers': instance.writers.map((e) => e.toJson()).toList(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
      'genres': instance.genres.map((e) => e.toJson()).toList(),
      'pieces': instance.pieces.map((e) => e.toJson()).toList(),
    };

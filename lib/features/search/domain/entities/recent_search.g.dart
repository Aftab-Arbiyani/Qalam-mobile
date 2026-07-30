// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecentSearch _$RecentSearchFromJson(Map<String, dynamic> json) =>
    _RecentSearch(
      query: json['query'] as String,
      searchType:
          $enumDecodeNullable(_$SearchTypeEnumMap, json['searchType']) ??
          SearchType.all,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
      serverId: json['serverId'] as String?,
    );

Map<String, dynamic> _$RecentSearchToJson(_RecentSearch instance) =>
    <String, dynamic>{
      'query': instance.query,
      'searchType': _$SearchTypeEnumMap[instance.searchType]!,
      'searchedAt': instance.searchedAt.toIso8601String(),
      'serverId': instance.serverId,
    };

const _$SearchTypeEnumMap = {
  SearchType.all: 'all',
  SearchType.pieces: 'pieces',
  SearchType.writers: 'writers',
  SearchType.tags: 'tags',
  SearchType.genres: 'genres',
  SearchType.languages: 'languages',
};

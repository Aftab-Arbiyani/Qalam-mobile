// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrendingTag _$TrendingTagFromJson(Map<String, dynamic> json) => _TrendingTag(
  slug: json['slug'] as String,
  name: json['name'] as String? ?? '',
  pieceCount: (json['pieceCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TrendingTagToJson(_TrendingTag instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'pieceCount': instance.pieceCount,
    };

_TrendingGenre _$TrendingGenreFromJson(Map<String, dynamic> json) =>
    _TrendingGenre(
      slug: json['slug'] as String,
      name: json['name'] as String? ?? '',
      pieceCount: (json['pieceCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TrendingGenreToJson(_TrendingGenre instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'pieceCount': instance.pieceCount,
    };

_TrendingLanguage _$TrendingLanguageFromJson(Map<String, dynamic> json) =>
    _TrendingLanguage(
      code: json['code'] as String,
      nativeName: json['nativeName'] as String? ?? '',
      direction:
          $enumDecodeNullable(_$TextDirectionKindEnumMap, json['direction']) ??
          TextDirectionKind.ltr,
      pieceCount: (json['pieceCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TrendingLanguageToJson(_TrendingLanguage instance) =>
    <String, dynamic>{
      'code': instance.code,
      'nativeName': instance.nativeName,
      'direction': _$TextDirectionKindEnumMap[instance.direction]!,
      'pieceCount': instance.pieceCount,
    };

const _$TextDirectionKindEnumMap = {
  TextDirectionKind.ltr: 'ltr',
  TextDirectionKind.rtl: 'rtl',
};

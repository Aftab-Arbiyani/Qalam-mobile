// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LanguageRef _$LanguageRefFromJson(Map<String, dynamic> json) => _LanguageRef(
  code: json['code'] as String,
  nativeName: json['nativeName'] as String? ?? '',
  direction:
      $enumDecodeNullable(_$TextDirectionKindEnumMap, json['direction']) ??
      TextDirectionKind.ltr,
);

Map<String, dynamic> _$LanguageRefToJson(_LanguageRef instance) =>
    <String, dynamic>{
      'code': instance.code,
      'nativeName': instance.nativeName,
      'direction': _$TextDirectionKindEnumMap[instance.direction]!,
    };

const _$TextDirectionKindEnumMap = {
  TextDirectionKind.ltr: 'ltr',
  TextDirectionKind.rtl: 'rtl',
};

_GenreRef _$GenreRefFromJson(Map<String, dynamic> json) => _GenreRef(
  slug: json['slug'] as String,
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$GenreRefToJson(_GenreRef instance) => <String, dynamic>{
  'slug': instance.slug,
  'name': instance.name,
};

_TagRef _$TagRefFromJson(Map<String, dynamic> json) =>
    _TagRef(slug: json['slug'] as String, name: json['name'] as String? ?? '');

Map<String, dynamic> _$TagRefToJson(_TagRef instance) => <String, dynamic>{
  'slug': instance.slug,
  'name': instance.name,
};

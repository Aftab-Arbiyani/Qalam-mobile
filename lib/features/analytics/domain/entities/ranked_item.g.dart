// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranked_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RankedItem _$RankedItemFromJson(Map<String, dynamic> json) => _RankedItem(
  key: json['key'] as String? ?? '',
  label: json['label'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RankedItemToJson(_RankedItem instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'count': instance.count,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Collection _$CollectionFromJson(Map<String, dynamic> json) => _Collection(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  slug: json['slug'] as String? ?? '',
  description: json['description'] as String?,
  coverImageKey: json['coverImageKey'] as String?,
  visibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
      Visibility.private,
  isDefault: json['isDefault'] as bool? ?? false,
  piecesCount: (json['piecesCount'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CollectionToJson(_Collection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'coverImageKey': instance.coverImageKey,
      'visibility': _$VisibilityEnumMap[instance.visibility]!,
      'isDefault': instance.isDefault,
      'piecesCount': instance.piecesCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$VisibilityEnumMap = {
  Visibility.public: 'public',
  Visibility.unlisted: 'unlisted',
  Visibility.private: 'private',
};

_CollectionPieceItem _$CollectionPieceItemFromJson(Map<String, dynamic> json) =>
    _CollectionPieceItem(
      pieceId: json['pieceId'] as String,
      slug: json['slug'] as String?,
      title: json['title'] as String? ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      addedAt: json['addedAt'] == null
          ? null
          : DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$CollectionPieceItemToJson(
  _CollectionPieceItem instance,
) => <String, dynamic>{
  'pieceId': instance.pieceId,
  'slug': instance.slug,
  'title': instance.title,
  'position': instance.position,
  'note': instance.note,
  'addedAt': instance.addedAt?.toIso8601String(),
};

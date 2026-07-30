// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookmarkItem _$BookmarkItemFromJson(Map<String, dynamic> json) =>
    _BookmarkItem(
      pieceId: json['pieceId'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      bookmarkedAt: DateTime.parse(json['bookmarkedAt'] as String),
    );

Map<String, dynamic> _$BookmarkItemToJson(_BookmarkItem instance) =>
    <String, dynamic>{
      'pieceId': instance.pieceId,
      'title': instance.title,
      'slug': instance.slug,
      'bookmarkedAt': instance.bookmarkedAt.toIso8601String(),
    };

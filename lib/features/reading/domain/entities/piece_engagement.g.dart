// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece_engagement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PieceEngagement _$PieceEngagementFromJson(Map<String, dynamic> json) =>
    _PieceEngagement(
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      claps: (json['claps'] as num?)?.toInt() ?? 0,
      bookmarks: (json['bookmarks'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      responses: (json['responses'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      hasLiked: json['hasLiked'] as bool? ?? false,
      hasBookmarked: json['hasBookmarked'] as bool? ?? false,
      clapCount: (json['clapCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PieceEngagementToJson(_PieceEngagement instance) =>
    <String, dynamic>{
      'likes': instance.likes,
      'claps': instance.claps,
      'bookmarks': instance.bookmarks,
      'comments': instance.comments,
      'responses': instance.responses,
      'shares': instance.shares,
      'hasLiked': instance.hasLiked,
      'hasBookmarked': instance.hasBookmarked,
      'clapCount': instance.clapCount,
    };

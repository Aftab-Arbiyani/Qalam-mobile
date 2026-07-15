// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_counts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileCounts _$ProfileCountsFromJson(Map<String, dynamic> json) =>
    _ProfileCounts(
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
      piecesPublished: (json['piecesPublished'] as num?)?.toInt() ?? 0,
      totalReads: (json['totalReads'] as num?)?.toInt() ?? 0,
      totalLikes: (json['totalLikes'] as num?)?.toInt() ?? 0,
      totalClaps: (json['totalClaps'] as num?)?.toInt() ?? 0,
      bookmarksReceived: (json['bookmarksReceived'] as num?)?.toInt() ?? 0,
      responseCount: (json['responseCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProfileCountsToJson(_ProfileCounts instance) =>
    <String, dynamic>{
      'followers': instance.followers,
      'following': instance.following,
      'piecesPublished': instance.piecesPublished,
      'totalReads': instance.totalReads,
      'totalLikes': instance.totalLikes,
      'totalClaps': instance.totalClaps,
      'bookmarksReceived': instance.bookmarksReceived,
      'responseCount': instance.responseCount,
    };

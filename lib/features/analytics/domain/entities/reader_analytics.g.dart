// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReaderAnalytics _$ReaderAnalyticsFromJson(Map<String, dynamic> json) =>
    _ReaderAnalytics(
      piecesRead: (json['piecesRead'] as num?)?.toInt() ?? 0,
      readingTimeSeconds: (json['readingTimeSeconds'] as num?)?.toInt() ?? 0,
      completedReads: (json['completedReads'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      favoriteGenres:
          (json['favoriteGenres'] as List<dynamic>?)
              ?.map((e) => RankedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RankedItem>[],
      favoriteLanguages:
          (json['favoriteLanguages'] as List<dynamic>?)
              ?.map((e) => RankedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RankedItem>[],
    );

Map<String, dynamic> _$ReaderAnalyticsToJson(_ReaderAnalytics instance) =>
    <String, dynamic>{
      'piecesRead': instance.piecesRead,
      'readingTimeSeconds': instance.readingTimeSeconds,
      'completedReads': instance.completedReads,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'favoriteGenres': instance.favoriteGenres.map((e) => e.toJson()).toList(),
      'favoriteLanguages': instance.favoriteLanguages
          .map((e) => e.toJson())
          .toList(),
    };

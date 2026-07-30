// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writer_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WriterAnalytics _$WriterAnalyticsFromJson(Map<String, dynamic> json) =>
    _WriterAnalytics(
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      uniqueViews: (json['uniqueViews'] as num?)?.toInt() ?? 0,
      reads: (json['reads'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      totalReadSeconds: (json['totalReadSeconds'] as num?)?.toInt() ?? 0,
      averageReadTimeSeconds:
          (json['averageReadTimeSeconds'] as num?)?.toInt() ?? 0,
      followersGained: (json['followersGained'] as num?)?.toInt() ?? 0,
      piecesPublished: (json['piecesPublished'] as num?)?.toInt() ?? 0,
      piecesArchived: (json['piecesArchived'] as num?)?.toInt() ?? 0,
      commentsReceived: (json['commentsReceived'] as num?)?.toInt() ?? 0,
      clapsReceived: (json['clapsReceived'] as num?)?.toInt() ?? 0,
      bookmarksReceived: (json['bookmarksReceived'] as num?)?.toInt() ?? 0,
      responsesReceived: (json['responsesReceived'] as num?)?.toInt() ?? 0,
      mostPopularPiece: json['mostPopularPiece'] == null
          ? null
          : MostPopularPiece.fromJson(
              json['mostPopularPiece'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$WriterAnalyticsToJson(_WriterAnalytics instance) =>
    <String, dynamic>{
      'totalViews': instance.totalViews,
      'uniqueViews': instance.uniqueViews,
      'reads': instance.reads,
      'completionRate': instance.completionRate,
      'totalReadSeconds': instance.totalReadSeconds,
      'averageReadTimeSeconds': instance.averageReadTimeSeconds,
      'followersGained': instance.followersGained,
      'piecesPublished': instance.piecesPublished,
      'piecesArchived': instance.piecesArchived,
      'commentsReceived': instance.commentsReceived,
      'clapsReceived': instance.clapsReceived,
      'bookmarksReceived': instance.bookmarksReceived,
      'responsesReceived': instance.responsesReceived,
      'mostPopularPiece': instance.mostPopularPiece?.toJson(),
    };

_MostPopularPiece _$MostPopularPieceFromJson(Map<String, dynamic> json) =>
    _MostPopularPiece(
      pieceId: json['pieceId'] as String,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String?,
      views: (json['views'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MostPopularPieceToJson(_MostPopularPiece instance) =>
    <String, dynamic>{
      'pieceId': instance.pieceId,
      'title': instance.title,
      'slug': instance.slug,
      'views': instance.views,
    };

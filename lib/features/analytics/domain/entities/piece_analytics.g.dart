// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PieceAnalytics _$PieceAnalyticsFromJson(Map<String, dynamic> json) =>
    _PieceAnalytics(
      pieceId: json['pieceId'] as String? ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
      uniqueViews: (json['uniqueViews'] as num?)?.toInt() ?? 0,
      reads: (json['reads'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      averageReadTimeSeconds:
          (json['averageReadTimeSeconds'] as num?)?.toInt() ?? 0,
      claps: (json['claps'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      responses: (json['responses'] as num?)?.toInt() ?? 0,
      bookmarks: (json['bookmarks'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      readingSources: json['readingSources'] == null
          ? const ReadingSources()
          : ReadingSources.fromJson(
              json['readingSources'] as Map<String, dynamic>,
            ),
      publishedAt: json['publishedAt'] as String?,
    );

Map<String, dynamic> _$PieceAnalyticsToJson(_PieceAnalytics instance) =>
    <String, dynamic>{
      'pieceId': instance.pieceId,
      'views': instance.views,
      'uniqueViews': instance.uniqueViews,
      'reads': instance.reads,
      'completionRate': instance.completionRate,
      'averageReadTimeSeconds': instance.averageReadTimeSeconds,
      'claps': instance.claps,
      'comments': instance.comments,
      'responses': instance.responses,
      'bookmarks': instance.bookmarks,
      'shares': instance.shares,
      'readingSources': instance.readingSources.toJson(),
      'publishedAt': instance.publishedAt,
    };

_ReadingSources _$ReadingSourcesFromJson(Map<String, dynamic> json) =>
    _ReadingSources(
      internal: (json['internal'] as num?)?.toInt() ?? 0,
      external: (json['external'] as num?)?.toInt() ?? 0,
      copyLink: (json['copyLink'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ReadingSourcesToJson(_ReadingSources instance) =>
    <String, dynamic>{
      'internal': instance.internal,
      'external': instance.external,
      'copyLink': instance.copyLink,
    };

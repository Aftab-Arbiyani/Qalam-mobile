// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DraftSummary _$DraftSummaryFromJson(Map<String, dynamic> json) =>
    _DraftSummary(
      localId: json['localId'] as String?,
      remoteId: json['remoteId'] as String?,
      title: json['title'] as String? ?? '',
      status:
          $enumDecodeNullable(_$PieceStatusEnumMap, json['status']) ??
          PieceStatus.draft,
      visibility:
          $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
          Visibility.public,
      syncState:
          $enumDecodeNullable(_$DraftSyncStateEnumMap, json['syncState']) ??
          DraftSyncState.synced,
      lastError: json['lastError'] as String?,
      direction:
          $enumDecodeNullable(_$TextDirectionKindEnumMap, json['direction']) ??
          TextDirectionKind.ltr,
      coverImageKey: json['coverImageKey'] as String?,
      wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
      readingTimeSeconds: (json['readingTimeSeconds'] as num?)?.toInt() ?? 0,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DraftSummaryToJson(_DraftSummary instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'remoteId': instance.remoteId,
      'title': instance.title,
      'status': _$PieceStatusEnumMap[instance.status]!,
      'visibility': _$VisibilityEnumMap[instance.visibility]!,
      'syncState': _$DraftSyncStateEnumMap[instance.syncState]!,
      'lastError': instance.lastError,
      'direction': _$TextDirectionKindEnumMap[instance.direction]!,
      'coverImageKey': instance.coverImageKey,
      'wordCount': instance.wordCount,
      'readingTimeSeconds': instance.readingTimeSeconds,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PieceStatusEnumMap = {
  PieceStatus.draft: 'draft',
  PieceStatus.scheduled: 'scheduled',
  PieceStatus.published: 'published',
  PieceStatus.archived: 'archived',
};

const _$VisibilityEnumMap = {
  Visibility.public: 'public',
  Visibility.unlisted: 'unlisted',
  Visibility.private: 'private',
};

const _$DraftSyncStateEnumMap = {
  DraftSyncState.synced: 'synced',
  DraftSyncState.pending: 'pending',
  DraftSyncState.syncing: 'syncing',
  DraftSyncState.failed: 'failed',
  DraftSyncState.conflict: 'conflict',
};

const _$TextDirectionKindEnumMap = {
  TextDirectionKind.ltr: 'ltr',
  TextDirectionKind.rtl: 'rtl',
};

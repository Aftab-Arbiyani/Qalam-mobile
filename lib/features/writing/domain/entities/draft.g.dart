// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Draft _$DraftFromJson(Map<String, dynamic> json) => _Draft(
  localId: json['localId'] as String,
  remoteId: json['remoteId'] as String?,
  title: json['title'] as String? ?? '',
  subtitle: json['subtitle'] as String? ?? '',
  featuredQuote: json['featuredQuote'] as String? ?? '',
  content:
      json['content'] as Map<String, dynamic>? ??
      const <String, dynamic>{'type': 'doc', 'content': <dynamic>[]},
  languageCode: json['languageCode'] as String? ?? '',
  languageName: json['languageName'] as String? ?? '',
  direction:
      $enumDecodeNullable(_$TextDirectionKindEnumMap, json['direction']) ??
      TextDirectionKind.ltr,
  genreSlug: json['genreSlug'] as String?,
  genreName: json['genreName'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  visibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
      Visibility.public,
  status:
      $enumDecodeNullable(_$PieceStatusEnumMap, json['status']) ??
      PieceStatus.draft,
  slug: json['slug'] as String?,
  coverImageKey: json['coverImageKey'] as String?,
  pendingCoverPath: json['pendingCoverPath'] as String?,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  remoteUpdatedAt: json['remoteUpdatedAt'] == null
      ? null
      : DateTime.parse(json['remoteUpdatedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  localUpdatedAt: DateTime.parse(json['localUpdatedAt'] as String),
  wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
  readingTimeSeconds: (json['readingTimeSeconds'] as num?)?.toInt() ?? 0,
  syncState:
      $enumDecodeNullable(_$DraftSyncStateEnumMap, json['syncState']) ??
      DraftSyncState.synced,
  intent:
      $enumDecodeNullable(_$DraftIntentEnumMap, json['intent']) ??
      DraftIntent.save,
  version: (json['version'] as num?)?.toInt() ?? 1,
  lastError: json['lastError'] as String?,
);

Map<String, dynamic> _$DraftToJson(_Draft instance) => <String, dynamic>{
  'localId': instance.localId,
  'remoteId': instance.remoteId,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'featuredQuote': instance.featuredQuote,
  'content': instance.content,
  'languageCode': instance.languageCode,
  'languageName': instance.languageName,
  'direction': _$TextDirectionKindEnumMap[instance.direction]!,
  'genreSlug': instance.genreSlug,
  'genreName': instance.genreName,
  'tags': instance.tags,
  'visibility': _$VisibilityEnumMap[instance.visibility]!,
  'status': _$PieceStatusEnumMap[instance.status]!,
  'slug': instance.slug,
  'coverImageKey': instance.coverImageKey,
  'pendingCoverPath': instance.pendingCoverPath,
  'scheduledAt': instance.scheduledAt?.toIso8601String(),
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'remoteUpdatedAt': instance.remoteUpdatedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'localUpdatedAt': instance.localUpdatedAt.toIso8601String(),
  'wordCount': instance.wordCount,
  'readingTimeSeconds': instance.readingTimeSeconds,
  'syncState': _$DraftSyncStateEnumMap[instance.syncState]!,
  'intent': _$DraftIntentEnumMap[instance.intent]!,
  'version': instance.version,
  'lastError': instance.lastError,
};

const _$TextDirectionKindEnumMap = {
  TextDirectionKind.ltr: 'ltr',
  TextDirectionKind.rtl: 'rtl',
};

const _$VisibilityEnumMap = {
  Visibility.public: 'public',
  Visibility.unlisted: 'unlisted',
  Visibility.private: 'private',
};

const _$PieceStatusEnumMap = {
  PieceStatus.draft: 'draft',
  PieceStatus.scheduled: 'scheduled',
  PieceStatus.published: 'published',
  PieceStatus.archived: 'archived',
};

const _$DraftSyncStateEnumMap = {
  DraftSyncState.synced: 'synced',
  DraftSyncState.pending: 'pending',
  DraftSyncState.syncing: 'syncing',
  DraftSyncState.failed: 'failed',
  DraftSyncState.conflict: 'conflict',
};

const _$DraftIntentEnumMap = {
  DraftIntent.save: 'save',
  DraftIntent.publish: 'publish',
  DraftIntent.schedule: 'schedule',
  DraftIntent.delete: 'delete',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadingHistoryEntry _$ReadingHistoryEntryFromJson(Map<String, dynamic> json) =>
    _ReadingHistoryEntry(
      pieceId: json['pieceId'] as String,
      title: json['title'] as String,
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
      authorName: json['authorName'] as String? ?? '',
      authorUsername: json['authorUsername'] as String?,
      slug: json['slug'] as String?,
      coverImageKey: json['coverImageKey'] as String?,
      languageCode: json['languageCode'] as String?,
      direction:
          $enumDecodeNullable(_$TextDirectionKindEnumMap, json['direction']) ??
          TextDirectionKind.ltr,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      totalReadSeconds: (json['totalReadSeconds'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$ReadingHistoryEntryToJson(
  _ReadingHistoryEntry instance,
) => <String, dynamic>{
  'pieceId': instance.pieceId,
  'title': instance.title,
  'lastReadAt': instance.lastReadAt.toIso8601String(),
  'authorName': instance.authorName,
  'authorUsername': instance.authorUsername,
  'slug': instance.slug,
  'coverImageKey': instance.coverImageKey,
  'languageCode': instance.languageCode,
  'direction': _$TextDirectionKindEnumMap[instance.direction]!,
  'progress': instance.progress,
  'totalReadSeconds': instance.totalReadSeconds,
  'isCompleted': instance.isCompleted,
};

const _$TextDirectionKindEnumMap = {
  TextDirectionKind.ltr: 'ltr',
  TextDirectionKind.rtl: 'rtl',
};

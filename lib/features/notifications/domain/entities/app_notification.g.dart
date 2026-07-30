// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.unknown,
      status:
          $enumDecodeNullable(_$NotificationStatusEnumMap, json['status']) ??
          NotificationStatus.unread,
      actor: json['actor'] == null
          ? null
          : Author.fromJson(json['actor'] as Map<String, dynamic>),
      entityType:
          $enumDecodeNullable(
            _$NotificationEntityTypeEnumMap,
            json['entityType'],
          ) ??
          NotificationEntityType.unknown,
      entityId: json['entityId'] as String?,
      payload: json['payload'] == null
          ? const NotificationPayload()
          : NotificationPayload.fromJson(
              json['payload'] as Map<String, dynamic>,
            ),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'status': _$NotificationStatusEnumMap[instance.status]!,
      'actor': instance.actor?.toJson(),
      'entityType': _$NotificationEntityTypeEnumMap[instance.entityType]!,
      'entityId': instance.entityId,
      'payload': instance.payload.toJson(),
      'readAt': instance.readAt?.toIso8601String(),
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.follow: 'follow',
  NotificationType.followRequest: 'followRequest',
  NotificationType.followAccepted: 'followAccepted',
  NotificationType.comment: 'comment',
  NotificationType.commentReply: 'commentReply',
  NotificationType.like: 'like',
  NotificationType.clap: 'clap',
  NotificationType.response: 'response',
  NotificationType.mention: 'mention',
  NotificationType.repost: 'repost',
  NotificationType.featured: 'featured',
  NotificationType.collectionFollow: 'collectionFollow',
  NotificationType.system: 'system',
  NotificationType.unknown: 'unknown',
};

const _$NotificationStatusEnumMap = {
  NotificationStatus.unread: 'unread',
  NotificationStatus.read: 'read',
  NotificationStatus.archived: 'archived',
};

const _$NotificationEntityTypeEnumMap = {
  NotificationEntityType.piece: 'piece',
  NotificationEntityType.comment: 'comment',
  NotificationEntityType.user: 'user',
  NotificationEntityType.collection: 'collection',
  NotificationEntityType.system: 'system',
  NotificationEntityType.unknown: 'unknown',
};

_NotificationPayload _$NotificationPayloadFromJson(Map<String, dynamic> json) =>
    _NotificationPayload(
      pieceSlug: json['pieceSlug'] as String?,
      pieceTitle: json['pieceTitle'] as String?,
      responsePieceId: json['responsePieceId'] as String?,
      commentId: json['commentId'] as String?,
      commentExcerpt: json['commentExcerpt'] as String?,
      systemTitle: json['systemTitle'] as String?,
      systemMessage: json['systemMessage'] as String?,
      systemLink: json['systemLink'] as String?,
    );

Map<String, dynamic> _$NotificationPayloadToJson(
  _NotificationPayload instance,
) => <String, dynamic>{
  'pieceSlug': instance.pieceSlug,
  'pieceTitle': instance.pieceTitle,
  'responsePieceId': instance.responsePieceId,
  'commentId': instance.commentId,
  'commentExcerpt': instance.commentExcerpt,
  'systemTitle': instance.systemTitle,
  'systemMessage': instance.systemMessage,
  'systemLink': instance.systemLink,
};

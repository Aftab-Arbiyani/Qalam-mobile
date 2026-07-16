/// Wire → entity mappers for the notifications feature (docs/40 §18) — the only
/// place the notification wire shape is interpreted. Pure, total, tolerant: a
/// missing/mistyped field coerces to a default and never throws, and an unknown
/// `type`/`entityType` falls back to its enum's `unknown` so an older client
/// survives a server-added kind. The `actor` and the denormalized `data` payload
/// are flattened into typed value objects here so nothing downstream reaches into
/// an untyped map.
library;

import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/entity_mappers.dart';
import '../../../../shared/domain/entities/author.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/unread_count.dart';

AppNotification notificationFromJson(Json json) {
  final Json data = asMap(json['data']);
  return AppNotification(
    id: asString(json['id']),
    type: NotificationType.fromWire(asStringOrNull(json['type'])),
    status: NotificationStatus.fromWire(asStringOrNull(json['status'])),
    actor: _actorFromWire(json['actor'], data),
    entityType: NotificationEntityType.fromWire(
      asStringOrNull(json['entityType']),
    ),
    entityId: asStringOrNull(json['entityId']),
    payload: _payloadFromData(data),
    readAt: asUtcDateOrNull(json['readAt']),
    archivedAt: asUtcDateOrNull(json['archivedAt']),
    createdAt:
        asUtcDateOrNull(json['createdAt']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
}

/// The actor lives at the top level on the wire, but older payloads carry it only
/// inside `data.actor` — prefer the top-level, fall back to the nested copy, and
/// stay null (not an empty `@`) when neither is present.
Author? _actorFromWire(Object? top, Json data) {
  if (top is Map) return authorFromWire(top);
  if (data['actor'] is Map) return authorFromWire(data['actor']);
  return null;
}

NotificationPayload _payloadFromData(Json data) {
  final Json piece = asMap(data['piece']);
  final Json comment = asMap(data['comment']);
  return NotificationPayload(
    pieceSlug: asStringOrNull(piece['slug']),
    pieceTitle: asStringOrNull(piece['title']),
    responsePieceId: asStringOrNull(data['responsePieceId']),
    commentId: asStringOrNull(comment['id']),
    commentExcerpt: asStringOrNull(comment['excerpt']),
    systemTitle: asStringOrNull(data['title']),
    systemMessage: asStringOrNull(data['message']),
    systemLink: asStringOrNull(data['link']),
  );
}

NotificationPreferences notificationPreferencesFromJson(Json json) =>
    NotificationPreferences(
      follow: asBool(json['follow'], true),
      comment: asBool(json['comment'], true),
      reply: asBool(json['reply'], true),
      reaction: asBool(json['reaction'], true),
      mention: asBool(json['mention'], true),
      response: asBool(json['response'], true),
      system: asBool(json['system'], true),
    );

UnreadCount unreadCountFromJson(Json json) =>
    UnreadCount(count: asInt(json['count']), capped: asBool(json['capped']));

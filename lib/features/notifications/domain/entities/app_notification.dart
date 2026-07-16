/// A single in-app notification (docs/40 §19.2, §32) — the unified domain model
/// every notification source flows into: the backend inbox (`GET /notifications`),
/// a foreground push merged in (Phase-2 seam, §32.2), and a locally-presented
/// notification all decode to THIS shape.
///
/// The wire sends an open [type] catalogue plus a polymorphic `entityType`/
/// `entityId` and a denormalized `data` map; the mapper flattens the render-time
/// fields it knows into [NotificationPayload] (tolerant — unknown kinds keep an
/// empty payload and render a generic row). Image keys stay keys; the CDN URL is
/// resolved at render via `core/media` (docs/40 §18.2). `fromJson`/`toJson` exist
/// only for the Hive cache round-trip (enums serialize by name — stable per app
/// version); the wire boundary always goes through the hand-written mapper.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/entities/author.dart';
import '../../../../shared/domain/enums.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

@freezed
abstract class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required String id,
    @Default(NotificationType.unknown) NotificationType type,
    @Default(NotificationStatus.unread) NotificationStatus status,
    Author? actor,
    @Default(NotificationEntityType.unknown) NotificationEntityType entityType,
    String? entityId,
    @Default(NotificationPayload()) NotificationPayload payload,
    DateTime? readAt,
    DateTime? archivedAt,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  bool get isUnread => status == NotificationStatus.unread;
  bool get isRead => status == NotificationStatus.read;
  bool get isArchived => status == NotificationStatus.archived;

  /// A locally-applied optimistic read: flips [status] and stamps [readAt] so the
  /// row (and the derived unread count) update instantly, before the server round
  /// trip settles (docs/40 §21.4). [readAt] uses the injected [at] for testability.
  AppNotification markedRead(DateTime at) => isUnread
      ? copyWith(status: NotificationStatus.read, readAt: readAt ?? at)
      : this;
}

/// The denormalized, render-time fields lifted out of the wire `data` map
/// (docs/40 §12.4). Kept as a small typed value so the deep-link resolver and
/// the tile never reach into an untyped map. Every field is optional — a mention
/// on a published piece carries a piece but no comment; a system notice carries
/// only its own title/body/link.
@freezed
abstract class NotificationPayload with _$NotificationPayload {
  const NotificationPayload._();

  const factory NotificationPayload({
    /// Target piece — `data.piece.slug` is the deep-link key when the subject is
    /// a piece or a comment (a comment's `entityId` is the comment id, not the
    /// piece, so the slug is how the tap reaches the piece — docs/40 §12.3).
    String? pieceSlug,
    String? pieceTitle,

    /// A response notification's authored response-piece id (`data.responsePieceId`).
    String? responsePieceId,

    /// Comment context (`data.comment.id` / `.excerpt`, excerpt ≤140 chars).
    String? commentId,
    String? commentExcerpt,

    /// System-announcement content (admin-authored `data.title`/`.message`/`.link`).
    String? systemTitle,
    String? systemMessage,
    String? systemLink,
  }) = _NotificationPayload;

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);
}

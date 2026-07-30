/// Notification → route resolution (docs/40 §12.4) — the single source of truth
/// that maps a notification's `type` + `entityType`/`entityId` + denormalized
/// payload onto an app-router path. Both an in-app row tap and a push/local
/// notification tap resolve through here, so navigation behaves identically
/// however the notification arrived. Pure and total: an unknown/target-less
/// notification returns null (the caller falls back to the inbox — docs/40 §12.4).
///
/// The router IS the deep-link parser (docs/40 §12.1) — this only produces the
/// path; navigation is `context.go(...)` through the same guarded router, so an
/// auth-gated target while signed out still routes through login→returnTo.
///
/// Piece-key caveat (docs/40 §12.3): `GET /pieces/:id` needs a UUID and there is
/// no slug→piece endpoint. Piece-subject notifications carry the piece UUID in
/// `entityId` (used directly); comment-subject ones carry only the comment id +
/// piece slug, so those route by slug and the reading view renders its graceful
/// slug fallback.
library;

import '../../../../app/router/routes.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/app_notification.dart';

/// The route a tapped [notification] should open, or null when it has no
/// navigable target.
String? routeForNotification(AppNotification n) => _resolve(
  type: n.type,
  entityType: n.entityType,
  entityId: n.entityId,
  pieceSlug: n.payload.pieceSlug,
  commentId: n.payload.commentId,
  responsePieceId: n.payload.responsePieceId,
  actorUsername: n.actor?.username,
  systemLink: n.payload.systemLink,
);

/// The route for a raw push/local data payload (the Phase-2 FCM seam feeds this).
/// Keys mirror the wire (`type`, `entityType`, `entityId`, `pieceSlug`,
/// `commentId`, `responsePieceId`, `actorUsername`, `link`).
String? routeForPushData(Map<String, String> data) => _resolve(
  type: NotificationType.fromWire(data['type']),
  entityType: NotificationEntityType.fromWire(data['entityType']),
  entityId: _nullIfBlank(data['entityId']),
  pieceSlug: _nullIfBlank(data['pieceSlug']),
  commentId: _nullIfBlank(data['commentId']),
  responsePieceId: _nullIfBlank(data['responsePieceId']),
  actorUsername: _nullIfBlank(data['actorUsername']),
  systemLink: _nullIfBlank(data['link']),
);

String? _resolve({
  required NotificationType type,
  required NotificationEntityType entityType,
  String? entityId,
  String? pieceSlug,
  String? commentId,
  String? responsePieceId,
  String? actorUsername,
  String? systemLink,
}) {
  // A resolvable piece key: prefer the UUID when the subject is a piece; else the
  // slug (comment-subject notifications only carry the slug — graceful fallback).
  final String? pieceKey = entityType == NotificationEntityType.piece
      ? (entityId ?? pieceSlug)
      : pieceSlug;

  switch (type) {
    case NotificationType.follow:
    case NotificationType.followAccepted:
    case NotificationType.collectionFollow:
      return actorUsername == null
          ? null
          : Routes.userProfilePath(actorUsername);

    case NotificationType.followRequest:
      return Routes.followRequests;

    case NotificationType.comment:
    case NotificationType.commentReply:
      return pieceKey == null ? null : Routes.pieceCommentsPath(pieceKey);

    case NotificationType.response:
      if (responsePieceId != null) return Routes.piecePath(responsePieceId);
      return pieceKey == null ? null : Routes.pieceResponsesPath(pieceKey);

    case NotificationType.mention:
      if (pieceKey == null) return null;
      return commentId != null
          ? Routes.pieceCommentsPath(pieceKey)
          : Routes.piecePath(pieceKey);

    case NotificationType.like:
    case NotificationType.clap:
    case NotificationType.featured:
    case NotificationType.repost:
      return pieceKey == null ? null : Routes.piecePath(pieceKey);

    case NotificationType.system:
      // Only honor a same-origin relative path an admin supplied (open-redirect
      // safe); anything else has no in-app target.
      return (systemLink != null &&
              systemLink.startsWith('/') &&
              !systemLink.startsWith('//'))
          ? systemLink
          : null;

    case NotificationType.unknown:
      return null;
  }
}

String? _nullIfBlank(String? value) =>
    (value == null || value.isEmpty) ? null : value;

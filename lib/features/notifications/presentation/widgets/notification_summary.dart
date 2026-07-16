/// Builds the human, literary one-line summary + optional secondary line for a
/// notification row (docs/41 §37 — "a literary summary built from the notification
/// `type` + denormalized `data`"). Pure functions over the localized strings so
/// they are unit-testable and RTL-safe (the actor display name / piece title carry
/// their own script; chrome stays LTR). An actor-less kind (system / featured) or
/// a missing actor falls back to a calm generic line.
library;

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/app_notification.dart';

/// The primary summary sentence for [n].
String notificationSummary(AppLocalizations l10n, AppNotification n) {
  final String? name = n.actor?.displayName;
  String named(String Function(String name) build) =>
      name == null ? l10n.notificationGeneric : build(name);

  switch (n.type) {
    case NotificationType.follow:
      return named(l10n.notificationFollow);
    case NotificationType.followRequest:
      return named(l10n.notificationFollowRequest);
    case NotificationType.followAccepted:
      return named(l10n.notificationFollowAccepted);
    case NotificationType.like:
      return named(l10n.notificationLike);
    case NotificationType.clap:
      return named(l10n.notificationClap);
    case NotificationType.comment:
      return named(l10n.notificationComment);
    case NotificationType.commentReply:
      return named(l10n.notificationCommentReply);
    case NotificationType.response:
      return named(l10n.notificationResponse);
    case NotificationType.mention:
      return named(l10n.notificationMention);
    case NotificationType.repost:
      return named(l10n.notificationRepost);
    case NotificationType.collectionFollow:
      return named(l10n.notificationCollectionFollow);
    case NotificationType.featured:
      return l10n.notificationFeatured;
    case NotificationType.system:
      final String? title = n.payload.systemTitle;
      return (title != null && title.trim().isNotEmpty)
          ? title
          : l10n.notificationSystem;
    case NotificationType.unknown:
      return l10n.notificationGeneric;
  }
}

/// The optional secondary line — a piece title, comment excerpt, or system body.
/// Null when there is nothing meaningful to add.
String? notificationSecondary(AppNotification n) {
  switch (n.type) {
    case NotificationType.comment:
    case NotificationType.commentReply:
      return _clean(n.payload.commentExcerpt) ?? _clean(n.payload.pieceTitle);
    case NotificationType.like:
    case NotificationType.clap:
    case NotificationType.response:
    case NotificationType.mention:
    case NotificationType.repost:
    case NotificationType.featured:
      return _clean(n.payload.pieceTitle);
    case NotificationType.system:
      return _clean(n.payload.systemMessage);
    case NotificationType.follow:
    case NotificationType.followRequest:
    case NotificationType.followAccepted:
    case NotificationType.collectionFollow:
    case NotificationType.unknown:
      return null;
  }
}

String? _clean(String? value) {
  if (value == null) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

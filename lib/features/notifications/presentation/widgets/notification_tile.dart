/// A single notification row (docs/41 §37) — actor avatar, a literary summary +
/// optional secondary line, a relative time, and an unread dot. Tapping marks it
/// read and deep-links to its target (docs/40 §12.4); swiping archives (leading)
/// or deletes (trailing, undo-able); an overflow menu makes every action
/// tap-reachable for accessibility (docs/41 §18, §20). All state changes go
/// through [NotificationsController]; the widget holds no business logic.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/cards/q_badge.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../controllers/notifications_controller.dart';
import '../navigation/notification_deep_link.dart';
import 'notification_summary.dart';

class NotificationTile extends ConsumerWidget {
  const NotificationTile({
    required this.notification,
    required this.filter,
    this.now,
    super.key,
  });

  final AppNotification notification;
  final NotificationFilter filter;

  /// Injectable clock for deterministic relative-time rendering in tests.
  final DateTime? now;

  NotificationsController _notifier(WidgetRef ref) =>
      ref.read(notificationsControllerProvider(filter).notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    final String summary = notificationSummary(l10n, notification);
    final String? secondary = notificationSecondary(notification);
    final String? avatarUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(notification.actor?.avatarKey);
    final bool unread = notification.isUnread;

    return Dismissible(
      key: ValueKey<String>('notif_${notification.id}'),
      background: _SwipeBackground(
        color: tokens.colors.infoBg,
        foreground: tokens.colors.infoText,
        icon: Icons.archive_outlined,
        label: l10n.notificationActionArchive,
        alignment: AlignmentDirectional.centerStart,
      ),
      secondaryBackground: _SwipeBackground(
        color: tokens.colors.dangerBg,
        foreground: tokens.colors.dangerText,
        icon: Icons.delete_outline,
        label: l10n.notificationActionDelete,
        alignment: AlignmentDirectional.centerEnd,
      ),
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.startToEnd) {
          QHaptics.medium();
          unawaited(_notifier(ref).archive(notification.id));
        } else {
          unawaited(_handleDelete(context, ref, l10n));
        }
      },
      child: Semantics(
        button: true,
        label: unread ? '${l10n.notificationsFilterUnread}. $summary' : summary,
        child: InkWell(
          onTap: () => _open(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: QSpacing.s4,
              vertical: QSpacing.s3,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                QAvatar(
                  name: notification.actor?.displayName ?? 'Qalam',
                  imageUrl: avatarUrl,
                  size: 40,
                ),
                const SizedBox(width: QSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        summary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: unread
                              ? tokens.colors.textPrimary
                              : tokens.colors.textSecondary,
                          fontWeight: unread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (secondary != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          secondary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.colors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        relativeTime(notification.createdAt, now: now),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: QSpacing.s2),
                _Trailing(
                  unread: unread,
                  onSelected: (_Action a) => _run(context, ref, l10n, a),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    if (notification.isUnread) {
      QHaptics.selection();
      unawaited(_notifier(ref).markRead(notification.id));
    }
    final String? route = routeForNotification(notification);
    if (route != null) context.go(route);
  }

  void _run(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    _Action action,
  ) {
    switch (action) {
      case _Action.markRead:
        QHaptics.selection();
        unawaited(_notifier(ref).markRead(notification.id));
      case _Action.archive:
        QHaptics.selection();
        unawaited(_notifier(ref).archive(notification.id));
      case _Action.delete:
        unawaited(_handleDelete(context, ref, l10n));
    }
  }

  /// Undo-able delete: remove the row now, offer Undo for 5s, and commit the
  /// destructive call only if the user let it stand (docs/41 §18).
  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final NotificationsController notifier = _notifier(ref);
    final AppNotification? removed = notifier.removeForUndo(notification.id);
    if (removed == null) return;
    unawaited(QHaptics.medium());
    bool undone = false;
    final controller = QSnackbar.showUndo(
      context,
      message: l10n.notificationDeleted,
      undoLabel: l10n.notificationUndo,
      onUndo: () {
        undone = true;
        notifier.reinsert(removed);
      },
    );
    await controller.closed;
    if (!undone) await notifier.confirmDelete(removed);
  }
}

/// The trailing cluster: unread dot + overflow menu (keeps every swipe action
/// reachable by tap, docs/41 §20).
class _Trailing extends StatelessWidget {
  const _Trailing({required this.unread, required this.onSelected});

  final bool unread;
  final ValueChanged<_Action> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (unread)
          QBadge.dot(semanticLabel: l10n.notificationsFilterUnread)
        else
          const SizedBox(width: 8, height: 8),
        PopupMenuButton<_Action>(
          icon: const Icon(Icons.more_horiz, size: 20),
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          onSelected: onSelected,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<_Action>>[
            if (unread)
              PopupMenuItem<_Action>(
                value: _Action.markRead,
                child: Text(l10n.notificationActionMarkRead),
              ),
            PopupMenuItem<_Action>(
              value: _Action.archive,
              child: Text(l10n.notificationActionArchive),
            ),
            PopupMenuItem<_Action>(
              value: _Action.delete,
              child: Text(l10n.notificationActionDelete),
            ),
          ],
        ),
      ],
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;
  final AlignmentDirectional alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: QSpacing.s5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: QSpacing.s2),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

enum _Action { markRead, archive, delete }

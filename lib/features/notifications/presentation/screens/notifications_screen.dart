/// The Notifications center (docs/40 §32, docs/41 §37) — the inbox tab. An
/// infinite, pull-to-refreshable list filterable by status and grouped by day,
/// with mark-all-read and a shortcut to preferences. All loading/empty/error/
/// stale/pagination UX comes from the shared [PagedFeedView]; rows are
/// [NotificationTile]s. No I/O or business logic here — it composes providers.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/pagination/paged_list_state.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/unread_count_controller.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_skeleton_list.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationFilter _filter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<PagedListState<AppNotification>> state = ref.watch(
      notificationsControllerProvider(_filter),
    );
    final List<AppNotification> items =
        state.asData?.value.items ?? const <AppNotification>[];

    return QScaffold(
      appBar: QAppBar(
        title: l10n.notificationsTitle,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: l10n.notificationsMarkAllRead,
            onPressed: () {
              QHaptics.selection();
              unawaited(
                ref
                    .read(notificationsControllerProvider(_filter).notifier)
                    .markAllRead(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: l10n.notificationsSettingsTooltip,
            onPressed: () => context.push(Routes.settingsNotifications),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          NotificationFilterBar(
            selected: _filter,
            onSelected: (NotificationFilter filter) {
              QHaptics.selection();
              setState(() => _filter = filter);
            },
          ),
          Expanded(
            child: PagedFeedView<AppNotification>(
              state: state,
              padding: const EdgeInsets.only(bottom: QSpacing.s4),
              loading: const NotificationSkeletonList(),
              staleNotice: l10n.notificationsStaleNotice,
              onRefresh: () async {
                await ref
                    .read(notificationsControllerProvider(_filter).notifier)
                    .refresh();
                await ref
                    .read(unreadCountControllerProvider.notifier)
                    .refresh();
              },
              onLoadMore: () => ref
                  .read(notificationsControllerProvider(_filter).notifier)
                  .loadMore(),
              empty: _EmptyForFilter(filter: _filter),
              itemBuilder:
                  (BuildContext context, AppNotification item, int index) {
                    final bool showHeader =
                        index == 0 ||
                        !_sameDay(items[index - 1].createdAt, item.createdAt);
                    final Widget tile = NotificationTile(
                      notification: item,
                      filter: _filter,
                    );
                    if (!showHeader) return tile;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _DaySectionHeader(date: item.createdAt),
                        tile,
                      ],
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) {
    final DateTime la = a.toLocal();
    final DateTime lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }
}

/// A day divider grouping the list (docs/41 §37 "grouped by day").
class _DaySectionHeader extends StatelessWidget {
  const _DaySectionHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s4,
        QSpacing.s4,
        QSpacing.s4,
        QSpacing.s1,
      ),
      child: Text(
        _label(l10n),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: tokens.colors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime local = date.toLocal();
    final DateTime day = DateTime(local.year, local.month, local.day);
    final int diff = today.difference(day).inDays;
    if (diff <= 0) return l10n.notificationSectionToday;
    if (diff == 1) return l10n.notificationSectionYesterday;
    return readableDate(local);
  }
}

class _EmptyForFilter extends StatelessWidget {
  const _EmptyForFilter({required this.filter});

  final NotificationFilter filter;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ({String title, String body}) copy = switch (filter) {
      NotificationFilter.all => (
        title: l10n.notificationsEmptyTitle,
        body: l10n.notificationsEmptyBody,
      ),
      NotificationFilter.unread => (
        title: l10n.notificationsUnreadEmptyTitle,
        body: l10n.notificationsUnreadEmptyBody,
      ),
      NotificationFilter.read => (
        title: l10n.notificationsReadEmptyTitle,
        body: l10n.notificationsReadEmptyBody,
      ),
      NotificationFilter.archived => (
        title: l10n.notificationsArchivedEmptyTitle,
        body: l10n.notificationsArchivedEmptyBody,
      ),
    };
    return QEmptyState(
      icon: Icons.notifications_none_outlined,
      title: copy.title,
      message: copy.body,
    );
  }
}

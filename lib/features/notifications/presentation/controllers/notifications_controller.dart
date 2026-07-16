/// The notification inbox controller (docs/40 §8.3, §21.4) — an infinite
/// cursor-paginated [PagedListState] over [NotificationRepository], keyed by the
/// [NotificationFilter] tab, reusing the shared [CursorPaginator] (no bespoke
/// pagination). Per-row actions (mark read / archive / delete) and mark-all-read
/// are optimistic with rollback; offline they apply locally and queue for replay
/// on reconnect via [NotificationSyncEngine] (docs/40 §23, §24). Deletion is
/// undo-able — the row is removed locally and the destructive call is committed
/// (or dropped) by the screen after the undo window (docs/41 §18).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/pagination/paged_list_state.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../../domain/value_objects/queued_notification_action.dart';
import '../providers/notification_providers.dart';
import 'unread_count_controller.dart';

part 'notifications_controller.g.dart';

@riverpod
class NotificationsController extends _$NotificationsController {
  CursorPaginator<AppNotification>? _paginator;

  @override
  Future<PagedListState<AppNotification>> build(NotificationFilter filter) {
    final CursorPaginator<AppNotification> paginator =
        CursorPaginator<AppNotification>(
          (String? cursor) => ref
              .read(notificationRepositoryProvider)
              .list(filter, cursor: cursor),
        );
    _paginator = paginator;
    return paginator.first();
  }

  bool get _online => ref.read(connectivityServiceProvider).isOnline;
  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  Future<void> loadMore() async {
    final CursorPaginator<AppNotification>? paginator = _paginator;
    final PagedListState<AppNotification>? current = state.asData?.value;
    if (paginator == null ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    state = AsyncData<PagedListState<AppNotification>>(
      current.copyWith(isLoadingMore: true),
    );
    state = AsyncData<PagedListState<AppNotification>>(
      await paginator.next(current),
    );
  }

  Future<void> refresh() async {
    final CursorPaginator<AppNotification>? paginator = _paginator;
    if (paginator != null) {
      state = await AsyncValue.guard(paginator.first);
    }
  }

  /// Mark one notification read — optimistic (row updates / drops from the Unread
  /// tab and the badge decrements instantly); rolls back on a non-offline error.
  Future<void> markRead(String id) => _act(id, NotificationActionKind.read);

  /// Archive one notification — optimistic (drops from every tab but Archived).
  Future<void> archive(String id) => _act(id, NotificationActionKind.archive);

  /// Mark every notification read. Optimistic: all rows flip to read (and the
  /// Unread tab empties), the badge zeroes; rolls back on a non-offline error.
  Future<void> markAllRead() async {
    final PagedListState<AppNotification>? current = state.asData?.value;
    if (current == null) return;
    final DateTime now = DateTime.now();
    final List<AppNotification> updated = current.items
        .map((AppNotification n) => n.markedRead(now))
        .where((AppNotification n) => filter.matches(n.status))
        .toList();
    state = AsyncData<PagedListState<AppNotification>>(
      current.copyWith(items: updated),
    );
    ref.read(unreadCountControllerProvider.notifier).reset();

    if (!_online) {
      // A single mark-all replay; individual rows reconcile server-side.
      await _enqueue(id: _allSentinel, kind: NotificationActionKind.readAll);
      return;
    }
    final Result<Unit> result = await _repo.markAllRead();
    if (result.isErr) state = AsyncData(current); // rollback
  }

  /// Sentinel target id for the global mark-all-read queued action.
  static const String _allSentinel = '__all__';

  /// Remove a row for a pending, undo-able deletion — no server call yet. Returns
  /// the removed item so the screen can restore it if the user taps Undo.
  AppNotification? removeForUndo(String id) {
    final PagedListState<AppNotification>? current = state.asData?.value;
    if (current == null) return null;
    final int index = current.items.indexWhere(
      (AppNotification n) => n.id == id,
    );
    if (index < 0) return null;
    final AppNotification removed = current.items[index];
    final List<AppNotification> without = <AppNotification>[...current.items]
      ..removeAt(index);
    state = AsyncData<PagedListState<AppNotification>>(
      current.copyWith(items: without),
    );
    return removed;
  }

  /// Re-insert an item the user chose to keep (Undo), preserving newest-first order.
  void reinsert(AppNotification item) {
    final PagedListState<AppNotification>? current = state.asData?.value;
    if (current == null) return;
    if (current.items.any((AppNotification n) => n.id == item.id)) return;
    final List<AppNotification> items = <AppNotification>[...current.items];
    final DateTime at = item.createdAt;
    int index = items.indexWhere(
      (AppNotification n) => n.createdAt.isBefore(at),
    );
    if (index < 0) index = items.length;
    items.insert(index, item);
    state = AsyncData<PagedListState<AppNotification>>(
      current.copyWith(items: items),
    );
  }

  /// Commit a deletion after the undo window elapsed. The row is already gone
  /// locally; offline it queues, online it deletes and on a non-network failure
  /// the row is restored so the UI stays honest.
  Future<void> confirmDelete(AppNotification item) async {
    if (item.isUnread) {
      ref.read(unreadCountControllerProvider.notifier).applyDelta(-1);
    }
    if (!_online) {
      await _enqueue(id: item.id, kind: NotificationActionKind.delete);
      return;
    }
    final Result<Unit> result = await _repo.delete(item.id);
    if (result.isErr && result.failureOrNull is! NetworkFailure) {
      reinsert(item);
      if (item.isUnread) {
        ref.read(unreadCountControllerProvider.notifier).applyDelta(1);
      }
    }
  }

  Future<void> _act(String id, NotificationActionKind kind) async {
    final PagedListState<AppNotification>? current = state.asData?.value;
    if (current == null) return;
    final int index = current.items.indexWhere(
      (AppNotification n) => n.id == id,
    );
    if (index < 0) return;
    final AppNotification original = current.items[index];

    state = AsyncData<PagedListState<AppNotification>>(
      _withOptimistic(current, index, kind),
    );
    if (original.isUnread) {
      ref.read(unreadCountControllerProvider.notifier).applyDelta(-1);
    }

    if (!_online) {
      await _enqueue(id: id, kind: kind);
      return;
    }
    final Result<Unit> result = switch (kind) {
      NotificationActionKind.read => await _repo.markRead(id),
      NotificationActionKind.archive => await _repo.archive(id),
      NotificationActionKind.delete => await _repo.delete(id),
      NotificationActionKind.readAll => await _repo.markAllRead(),
    };
    if (result.isErr) {
      state = AsyncData<PagedListState<AppNotification>>(current); // rollback
      if (original.isUnread) {
        ref.read(unreadCountControllerProvider.notifier).applyDelta(1);
      }
    }
  }

  PagedListState<AppNotification> _withOptimistic(
    PagedListState<AppNotification> current,
    int index,
    NotificationActionKind kind,
  ) {
    final AppNotification item = current.items[index];
    final DateTime now = DateTime.now();
    final AppNotification next = switch (kind) {
      NotificationActionKind.read => item.markedRead(now),
      NotificationActionKind.archive => item.copyWith(
        status: NotificationStatus.archived,
        archivedAt: item.archivedAt ?? now,
      ),
      NotificationActionKind.delete || NotificationActionKind.readAll => item,
    };
    final List<AppNotification> items = <AppNotification>[...current.items];
    // Drop the row when it no longer belongs in the current filter (or on delete).
    if (kind == NotificationActionKind.delete || !filter.matches(next.status)) {
      items.removeAt(index);
    } else {
      items[index] = next;
    }
    return current.copyWith(items: items);
  }

  Future<void> _enqueue({
    required String id,
    required NotificationActionKind kind,
  }) => ref
      .read(notificationSyncEngineProvider)
      .enqueue(
        QueuedNotificationAction(
          kind: kind,
          targetId: id,
          createdAt: DateTime.now(),
        ),
      );
}

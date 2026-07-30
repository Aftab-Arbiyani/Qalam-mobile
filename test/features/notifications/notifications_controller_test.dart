import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/sync/sync_providers.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:qalam_mobile/features/notifications/domain/value_objects/notification_filter.dart';
import 'package:qalam_mobile/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

import '../../support/fake_notifications.dart';
import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final unreadProvider = notificationsControllerProvider(
    NotificationFilter.unread,
  );

  test(
    'markRead drops the row from the Unread filter and calls the repo',
    () async {
      final repo = FakeNotificationRepository(
        items: <AppNotification>[
          notif(id: 'a'),
          notif(id: 'b'),
        ],
      );
      final container = await buildTestContainer(notificationRepository: repo);
      addTearDown(container.dispose);

      await container.read(unreadProvider.future);
      await container.read(unreadProvider.notifier).markRead('a');

      final state = container.read(unreadProvider).asData!.value;
      expect(state.items.map((n) => n.id), <String>['b']);
      expect(repo.markReadCalls, 1);
    },
  );

  test('a failed markRead rolls the row back', () async {
    final repo =
        FakeNotificationRepository(items: <AppNotification>[notif(id: 'a')])
          ..failNext = true
          ..failure = const Failure.notFound(code: 'NOTIFICATION_NOT_FOUND');
    final container = await buildTestContainer(notificationRepository: repo);
    addTearDown(container.dispose);

    await container.read(unreadProvider.future);
    await container.read(unreadProvider.notifier).markRead('a');

    final state = container.read(unreadProvider).asData!.value;
    expect(state.items.map((n) => n.id), <String>['a']); // restored
    expect(repo.markReadCalls, 1);
  });

  test('offline markRead queues the action and skips the network', () async {
    final repo = FakeNotificationRepository(
      items: <AppNotification>[notif(id: 'a')],
    );
    final container = await buildTestContainer(
      online: false,
      notificationRepository: repo,
    );
    addTearDown(container.dispose);
    // Keep the autodispose provider alive across reads.
    container.listen(unreadProvider, (_, _) {});

    await container.read(unreadProvider.future);
    await container.read(unreadProvider.notifier).markRead('a');

    expect(repo.markReadCalls, 0); // no network call offline
    expect(container.read(syncOutboxStoreProvider).count, 1);
    // Optimistic removal still applied.
    expect(container.read(unreadProvider).asData!.value.items, isEmpty);
  });

  test(
    'markAllRead empties the Unread filter and calls the repo once',
    () async {
      final repo = FakeNotificationRepository(
        items: <AppNotification>[
          notif(id: 'a'),
          notif(id: 'b'),
        ],
      );
      final container = await buildTestContainer(notificationRepository: repo);
      addTearDown(container.dispose);

      await container.read(unreadProvider.future);
      await container.read(unreadProvider.notifier).markAllRead();

      expect(container.read(unreadProvider).asData!.value.items, isEmpty);
      expect(repo.markAllReadCalls, 1);
    },
  );

  test(
    'delete is undo-able: removeForUndo → reinsert restores, confirmDelete commits',
    () async {
      final repo = FakeNotificationRepository(
        items: <AppNotification>[
          notif(id: 'a', status: NotificationStatus.read),
          notif(id: 'b', status: NotificationStatus.read),
        ],
      );
      final container = await buildTestContainer(notificationRepository: repo);
      addTearDown(container.dispose);
      final all = notificationsControllerProvider(NotificationFilter.all);

      await container.read(all.future);
      final notifier = container.read(all.notifier);

      final removed = notifier.removeForUndo('a');
      expect(removed, isNotNull);
      expect(container.read(all).asData!.value.items.map((n) => n.id), <String>[
        'b',
      ]);

      notifier.reinsert(removed!);
      expect(
        container.read(all).asData!.value.items.map((n) => n.id).contains('a'),
        isTrue,
      );
      expect(repo.deleteCalls, 0); // undo → nothing committed

      await notifier.confirmDelete(removed);
      expect(repo.deleteCalls, 1);
    },
  );
}

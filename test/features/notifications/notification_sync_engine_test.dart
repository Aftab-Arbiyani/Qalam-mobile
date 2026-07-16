import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/features/notifications/domain/value_objects/queued_notification_action.dart';
import 'package:qalam_mobile/features/notifications/presentation/providers/notification_providers.dart';

import '../../support/fake_notifications.dart';
import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  QueuedNotificationAction read(String id) => QueuedNotificationAction(
    kind: NotificationActionKind.read,
    targetId: id,
    createdAt: DateTime.utc(2026, 7, 16),
  );

  test(
    'offline enqueue keeps the action queued and skips the network',
    () async {
      final repo = FakeNotificationRepository();
      final container = await buildTestContainer(
        online: false,
        notificationRepository: repo,
      );
      addTearDown(container.dispose);

      final engine = container.read(notificationSyncEngineProvider);
      await engine.enqueue(read('a'));

      expect(engine.pendingCount, 1);
      expect(repo.markReadCalls, 0);
    },
  );

  test('online enqueue drains immediately and clears the queue', () async {
    final repo = FakeNotificationRepository();
    final container = await buildTestContainer(notificationRepository: repo);
    addTearDown(container.dispose);

    final engine = container.read(notificationSyncEngineProvider);
    await engine.enqueue(read('a'));

    expect(repo.markReadCalls, 1);
    expect(engine.pendingCount, 0);
  });

  test(
    'a terminal failure drops the entry (a fresh read will correct the UI)',
    () async {
      final repo = FakeNotificationRepository()
        ..failNext = true
        ..failure = const Failure.notFound(code: 'NOTIFICATION_NOT_FOUND');
      final container = await buildTestContainer(notificationRepository: repo);
      addTearDown(container.dispose);

      final engine = container.read(notificationSyncEngineProvider);
      await engine.enqueue(read('gone'));

      expect(repo.markReadCalls, 1);
      expect(engine.pendingCount, 0); // dropped
    },
  );

  test('a stronger action supersedes a weaker one for the same id', () async {
    final repo = FakeNotificationRepository();
    final container = await buildTestContainer(
      online: false,
      notificationRepository: repo,
    );
    addTearDown(container.dispose);

    final store = container.read(notificationOutboxStoreProvider);
    await store.put(read('a'));
    await store.put(
      QueuedNotificationAction(
        kind: NotificationActionKind.delete,
        targetId: 'a',
        createdAt: DateTime.utc(2026, 7, 16, 1),
      ),
    );
    expect(store.count, 1);
    expect(store.readAll().single.kind, NotificationActionKind.delete);

    // A weaker action does not downgrade the queued delete.
    await store.put(read('a'));
    expect(store.readAll().single.kind, NotificationActionKind.delete);
  });
}

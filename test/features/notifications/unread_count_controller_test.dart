import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/unread_count.dart';
import 'package:qalam_mobile/features/notifications/presentation/controllers/unread_count_controller.dart';

import '../../support/fake_notifications.dart';
import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fetches the count on build', () async {
    final repo = FakeNotificationRepository(
      unread: const UnreadCount(count: 3),
    );
    final container = await buildTestContainer(notificationRepository: repo);
    addTearDown(container.dispose);

    final value = await container.read(unreadCountControllerProvider.future);
    expect(value.count, 3);
    expect(value.hasUnread, isTrue);
  });

  test('applyDelta adjusts and clamps at zero', () async {
    final repo = FakeNotificationRepository(
      unread: const UnreadCount(count: 2),
    );
    final container = await buildTestContainer(notificationRepository: repo);
    addTearDown(container.dispose);

    await container.read(unreadCountControllerProvider.future);
    final notifier = container.read(unreadCountControllerProvider.notifier);

    notifier.applyDelta(-1);
    expect(
      container.read(unreadCountControllerProvider).asData!.value.count,
      1,
    );

    notifier.applyDelta(-5);
    expect(
      container.read(unreadCountControllerProvider).asData!.value.count,
      0,
    );
  });

  test('reset zeroes the badge', () async {
    final repo = FakeNotificationRepository(
      unread: const UnreadCount(count: 7),
    );
    final container = await buildTestContainer(notificationRepository: repo);
    addTearDown(container.dispose);

    await container.read(unreadCountControllerProvider.future);
    container.read(unreadCountControllerProvider.notifier).reset();
    expect(
      container.read(unreadCountControllerProvider).asData!.value.count,
      0,
    );
  });
}

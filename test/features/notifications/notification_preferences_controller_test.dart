import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/notification_preferences.dart';
import 'package:qalam_mobile/features/notifications/presentation/controllers/notification_preferences_controller.dart';

import '../../support/fake_notifications.dart';
import '../../support/harness.dart';

void main() {
  final provider = notificationPreferencesControllerProvider;

  test('loads the current preference set', () async {
    final repo = FakeNotificationPreferencesRepository(
      initial: const NotificationPreferences(follow: false),
    );
    final container = await buildTestContainer(
      notificationPreferencesRepository: repo,
    );
    addTearDown(container.dispose);

    final prefs = await container.read(provider.future);
    expect(prefs.follow, isFalse);
    expect(prefs.comment, isTrue);
  });

  test('toggle flips optimistically and persists the change', () async {
    final repo = FakeNotificationPreferencesRepository();
    final container = await buildTestContainer(
      notificationPreferencesRepository: repo,
    );
    addTearDown(container.dispose);

    await container.read(provider.future);
    await container
        .read(provider.notifier)
        .toggle(NotificationPreferenceCategory.follow);

    expect(container.read(provider).asData!.value.follow, isFalse);
  });

  test('a failed toggle rolls the switch back', () async {
    final repo = FakeNotificationPreferencesRepository()..failNext = true;
    final container = await buildTestContainer(
      notificationPreferencesRepository: repo,
    );
    addTearDown(container.dispose);

    await container.read(provider.future);
    await container
        .read(provider.notifier)
        .toggle(NotificationPreferenceCategory.reaction);

    // Optimistic flip reverted to the original (true).
    expect(container.read(provider).asData!.value.reaction, isTrue);
  });
}

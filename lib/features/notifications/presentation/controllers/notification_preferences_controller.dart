/// The notification-preferences controller (docs/40 §21.4) — loads the seven
/// per-category toggles and flips one optimistically (the switch moves instantly),
/// reconciling with the server's authoritative set on success or rolling back on
/// failure. A single partial PATCH per toggle, so concurrent changes to other
/// categories are never clobbered.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../data/sync/notification_sync_handler.dart';
import '../../domain/entities/notification_preferences.dart';
import '../providers/notification_providers.dart';

part 'notification_preferences_controller.g.dart';

@riverpod
class NotificationPreferencesController
    extends _$NotificationPreferencesController {
  @override
  Future<NotificationPreferences> build() async {
    final result = await ref
        .read(notificationPreferencesRepositoryProvider)
        .get();
    return result.fold(
      (NotificationPreferences prefs) => prefs,
      (Object failure) => throw failure,
    );
  }

  /// Flip one category. Optimistic; reconciles to the server's returned set (or
  /// rolls back the switch on failure).
  Future<void> toggle(NotificationPreferenceCategory category) async {
    final NotificationPreferences? current = state.asData?.value;
    if (current == null) return;
    final bool next = !category.valueOf(current);
    state = AsyncData<NotificationPreferences>(category.apply(current, next));

    // Offline: keep the optimistic switch and queue the change on the unified
    // engine ("Queued Settings Changes", docs/40 §23) — it replays on reconnect.
    if (!ref.read(connectivityServiceProvider).isOnline) {
      await ref
          .read(syncEngineProvider)
          .enqueue(
            buildNotificationPrefOperation(
              category: category,
              value: next,
              label: 'Notification setting',
            ),
          );
      return;
    }
    final result = await ref
        .read(notificationPreferencesRepositoryProvider)
        .update(category, next);
    state = AsyncData<NotificationPreferences>(
      result.fold(
        (NotificationPreferences updated) => updated,
        (Object _) => current, // rollback
      ),
    );
  }
}

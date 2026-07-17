/// The notifications module composition root (docs/40 §9) — binds every
/// notification domain repository + the offline outbox/sync engine + the push
/// coordinator to their implementations. The inbox, the unread badge, and the
/// push coordinator all depend on THESE providers; there is no duplicate
/// notification repository (docs/40 §7.3, §44). DI is Riverpod only.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/sync/sync_status.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_preferences_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/unread_count_controller.dart';
import '../navigation/push_notification_coordinator.dart';

part 'notification_providers.g.dart';

@riverpod
NotificationRemoteDataSource notificationRemoteDataSource(Ref ref) =>
    NotificationRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepositoryImpl(
      ref.watch(notificationRemoteDataSourceProvider),
      ref.watch(cacheListDataSourceProvider),
      ref.watch(cacheStoreProvider),
    );

@Riverpod(keepAlive: true)
NotificationPreferencesRepository notificationPreferencesRepository(Ref ref) =>
    NotificationPreferencesRepositoryImpl(
      ref.watch(notificationRemoteDataSourceProvider),
      ref.watch(cacheStoreProvider),
    );

// ── Offline action queue ─────────────────────────────────────────────────────

// Queued notification actions (read / archive / delete / read-all) and preference
// toggles now flow through the single unified `SyncEngine` (see `core/sync` +
// `app/sync_bootstrap.dart`) — there is no notification-specific outbox/engine.

/// Keeps the unread badge honest as queued notification actions drain on the
/// unified engine: a change in the engine's outstanding work re-reads the count.
/// Kept alive + watched from the app root so it works with no inbox screen open —
/// the same always-on guarantee the old engine gave.
@Riverpod(keepAlive: true)
Object notificationSyncWatcher(Ref ref) {
  ref.listen<SyncStatus>(syncStatusProvider, (SyncStatus? prev, SyncStatus next) {
    if (prev == null || prev.outstanding != next.outstanding) {
      ref.invalidate(unreadCountControllerProvider);
    }
  });
  return const Object();
}

// ── Push ↔ app bridge (Phase-2 FCM seam) ─────────────────────────────────────

@Riverpod(keepAlive: true)
PushNotificationCoordinator pushNotificationCoordinator(Ref ref) {
  final PushNotificationCoordinator coordinator = PushNotificationCoordinator(
    push: ref.watch(pushMessagingServiceProvider),
    local: ref.watch(localNotificationServiceProvider),
    navigate: (String route) => ref.read(goRouterProvider).go(route),
    onInboxChanged: () {
      ref.invalidate(unreadCountControllerProvider);
      ref.invalidate(notificationsControllerProvider);
    },
    logger: ref.watch(appLoggerProvider),
  );
  unawaited(coordinator.start());
  ref.onDispose(() => unawaited(coordinator.dispose()));
  return coordinator;
}

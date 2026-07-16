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
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_preferences_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/sync/notification_outbox_store.dart';
import '../../data/sync/notification_sync_engine.dart';
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

@Riverpod(keepAlive: true)
NotificationOutboxStore notificationOutboxStore(Ref ref) =>
    NotificationOutboxStore(ref.watch(prefsBoxProvider));

@Riverpod(keepAlive: true)
NotificationSyncEngine notificationSyncEngine(Ref ref) {
  final NotificationSyncEngine engine = NotificationSyncEngine(
    repository: ref.watch(notificationRepositoryProvider),
    store: ref.watch(notificationOutboxStoreProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    logger: ref.watch(appLoggerProvider),
  )..start();
  // As queued actions drain on reconnect, the server state moved — keep the badge
  // honest by refreshing it whenever the queue changes.
  void onRevision() => ref.invalidate(unreadCountControllerProvider);
  engine.revision.addListener(onRevision);
  ref.onDispose(() {
    engine.revision.removeListener(onRevision);
    engine.dispose();
  });
  return engine;
}

/// The number of pending queued notification actions — drives the offline-pending
/// indicator. Re-reads whenever the engine's revision changes.
@riverpod
int notificationPendingCount(Ref ref) {
  final NotificationSyncEngine engine = ref.watch(
    notificationSyncEngineProvider,
  );
  void listener() => ref.invalidateSelf();
  engine.revision.addListener(listener);
  ref.onDispose(() => engine.revision.removeListener(listener));
  return engine.pendingCount;
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

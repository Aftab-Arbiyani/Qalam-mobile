/// The app-level synchronization registrar (docs/40 §23) — the ONE place feature
/// handlers and background tasks are wired onto the single [SyncEngine], then the
/// engine is started. Watched once from the app root so queued offline actions
/// (likes, bookmarks, follows, notification actions, comments, profile + settings
/// changes) and the offline-draft drain all reconcile on the same connectivity
/// signal. This is the only module that depends on both the engine and every
/// feature — keeping `core/sync` itself dependency-clean.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/sync/sync_engine.dart';
import '../core/sync/sync_handler.dart';
import '../core/sync/sync_providers.dart';
import '../features/notifications/data/sync/notification_sync_handler.dart';
import '../features/notifications/presentation/providers/notification_providers.dart';
import '../features/profile/data/sync/profile_sync_handler.dart';
import '../features/profile/presentation/providers/profile_providers.dart';
import '../features/writing/presentation/providers/writing_providers.dart';
import '../shared/social/data/sync/clap_sync_handler.dart';
import '../shared/social/data/sync/comment_sync_handler.dart';
import '../shared/social/data/sync/social_sync_handler.dart';
import '../shared/social/social_providers.dart';

part 'sync_bootstrap.g.dart';

/// Registers every handler + background task onto the engine and starts it.
/// Returns the started engine so a watcher holds it alive.
@Riverpod(keepAlive: true)
SyncEngine appSync(Ref ref) {
  final SyncEngine engine = ref.watch(syncEngineProvider);

  // Operation handlers — one per queued-action type. Registration is idempotent.
  for (final SyncHandler handler in buildSocialSyncHandlers(
    ref.watch(engagementRepositoryProvider),
  )) {
    engine.registerHandler(handler);
  }
  engine
    // A clap is a quantity, not a toggle, so it is NOT a `SocialCategory` — it
    // needs a summing merge the desired-state handler cannot give it (M7-3).
    ..registerHandler(ClapSyncHandler(ref.watch(engagementRepositoryProvider)))
    ..registerHandler(
      NotificationSyncHandler(ref.watch(notificationRepositoryProvider)),
    )
    ..registerHandler(
      NotificationPreferenceSyncHandler(
        ref.watch(notificationPreferencesRepositoryProvider),
      ),
    )
    ..registerHandler(CommentSyncHandler(ref.watch(commentRepositoryProvider)))
    ..registerHandler(ProfileSyncHandler(ref.watch(profileRepositoryProvider)));

  // Background tasks — subsystems that own their own local store drain on the same
  // signal instead of subscribing to connectivity themselves (offline drafts).
  final draftEngine = ref.watch(draftSyncEngineProvider);
  engine.registerTask((name: 'drafts', run: draftEngine.syncAll));

  engine.start();
  return engine;
}

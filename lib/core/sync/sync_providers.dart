/// Composition root for the unified synchronization engine (docs/40 §9, §23).
/// Provides the ONE engine, its durable outbox + history stores, and the published
/// status — dependency-clean (core depends on no feature). Feature handlers and
/// background tasks are registered onto [syncEngineProvider] by the app-level
/// registrar (`lib/app/sync_bootstrap.dart`), the only place features and the
/// engine meet.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/providers.dart';
import 'sync_engine.dart';
import 'sync_history.dart';
import 'sync_operation.dart';
import 'sync_outbox_store.dart';
import 'sync_status.dart';

part 'sync_providers.g.dart';

@Riverpod(keepAlive: true)
SyncOutboxStore syncOutboxStore(Ref ref) =>
    SyncOutboxStore(ref.watch(prefsBoxProvider));

@Riverpod(keepAlive: true)
SyncHistoryStore syncHistoryStore(Ref ref) =>
    SyncHistoryStore(ref.watch(prefsBoxProvider));

/// The single engine instance. Built without handlers — the app registrar adds
/// them and calls `start()`. Kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) {
  final SyncEngine engine = SyncEngine(
    outbox: ref.watch(syncOutboxStoreProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    logger: ref.watch(appLoggerProvider),
    history: ref.watch(syncHistoryStoreProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
}

/// The engine's published state — drives the sync indicator, offline banner and
/// queue-status surfaces. Re-reads whenever the engine emits a new status.
@Riverpod(keepAlive: true)
SyncStatus syncStatus(Ref ref) {
  final SyncEngine engine = ref.watch(syncEngineProvider);
  void listener() => ref.invalidateSelf();
  engine.status.addListener(listener);
  ref.onDispose(() => engine.status.removeListener(listener));
  return engine.status.value;
}

/// Every queued operation (pending / failed / conflict), newest intent last.
/// Recomputed whenever the engine's status changes.
@riverpod
List<SyncOperation> syncOperations(Ref ref) {
  ref.watch(syncStatusProvider);
  return ref.watch(syncOutboxStoreProvider).readAll();
}

/// The queued operations currently parked awaiting conflict resolution.
@riverpod
List<SyncOperation> syncConflicts(Ref ref) {
  // Recomputed on each status change (a conflict changes the status counts).
  ref.watch(syncStatusProvider);
  return ref.watch(syncEngineProvider).conflicts;
}

/// The durable synchronization history, newest first. Recomputed on status change
/// (every resolved op appends an entry and changes the status).
@riverpod
List<SyncHistoryEntry> syncHistory(Ref ref) {
  ref.watch(syncStatusProvider);
  return ref.watch(syncHistoryStoreProvider).readAll();
}

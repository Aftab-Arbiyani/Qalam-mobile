/// The unified synchronization engine (docs/40 §23, §24) — the ONE engine every
/// offline feature in the app shares. It owns:
///
///  * a single durable operation outbox ([SyncOutboxStore]);
///  * a registry of [SyncHandler]s (one per operation type) that reconcile a queued
///    desired-state with the server through the feature's normal repository;
///  * connectivity-driven, event-based draining (never a battery-draining poll) —
///    it flushes on reconnect, on enqueue while online, on app-resume, and on an
///    explicit user retry;
///  * exponential backoff with a per-op attempt cap, transient-vs-terminal
///    classification, and conflict parking for user resolution;
///  * a published [SyncStatus] and a durable [SyncHistoryStore] for the sync
///    indicator, queue-status and history surfaces;
///  * registered *background tasks* for richer subsystems that own their own local
///    store (e.g. the offline-draft state machine) so they, too, drain on the SAME
///    connectivity signal instead of each subscribing separately.
///
/// Features never touch connectivity or the outbox directly — they call [enqueue]
/// with a [SyncOperation] (or register via [registerHandler] / [registerTask]).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../connectivity/connectivity_service.dart';
import '../logging/app_logger.dart';
import 'sync_handler.dart';
import 'sync_history.dart';
import 'sync_operation.dart';
import 'sync_outbox_store.dart';
import 'sync_status.dart';

/// A background drain owned by a subsystem with its own local store. The engine
/// runs [run] on every drain so all offline work reconciles on one signal.
typedef SyncTask = ({String name, Future<void> Function() run});

/// How a conflicted operation should be resolved by the user.
enum ConflictResolution {
  /// Re-send the local intent (retry, overwriting server) — clears the conflict.
  keepLocal,

  /// Abandon the local intent (server wins) — drops the op; a fresh read corrects.
  keepServer,
}

class SyncEngine {
  SyncEngine({
    required SyncOutboxReader outbox,
    required ConnectivityService connectivity,
    required AppLogger logger,
    required SyncHistoryStore history,
    List<SyncHandler> handlers = const <SyncHandler>[],
    Duration baseBackoff = const Duration(seconds: 2),
    Duration maxBackoff = const Duration(minutes: 5),
    int maxAttempts = 8,
  }) : _outbox = outbox,
       _connectivity = connectivity,
       _logger = logger,
       _history = history,
       _baseBackoff = baseBackoff,
       _maxBackoff = maxBackoff,
       _maxAttempts = maxAttempts {
    for (final SyncHandler handler in handlers) {
      registerHandler(handler);
    }
  }

  final SyncOutboxReader _outbox;
  final ConnectivityService _connectivity;
  final AppLogger _logger;
  final SyncHistoryStore _history;
  final Duration _baseBackoff;
  final Duration _maxBackoff;
  final int _maxAttempts;

  final Map<String, SyncHandler> _handlers = <String, SyncHandler>{};
  final List<SyncTask> _tasks = <SyncTask>[];

  /// The published engine state — the sole thing presentation watches.
  final ValueNotifier<SyncStatus> status = ValueNotifier<SyncStatus>(
    const SyncStatus(),
  );

  StreamSubscription<bool>? _connSub;
  Future<void>? _draining;
  Timer? _retryTimer;
  bool _started = false;

  int get pendingCount => _outbox.readAll().length;

  /// The operations currently parked awaiting conflict resolution.
  List<SyncOperation> get conflicts => _outbox
      .readAll()
      .where((SyncOperation o) => o.status == SyncOpStatus.conflict)
      .toList(growable: false);

  /// Register the handler for its [SyncHandler.type]. Idempotent per type (a later
  /// registration replaces an earlier one — the composition root wins).
  void registerHandler(SyncHandler handler) {
    _handlers[handler.type] = handler;
  }

  /// Register a background drain (a subsystem that owns its own store). Idempotent
  /// by [SyncTask.name].
  void registerTask(SyncTask task) {
    _tasks.removeWhere((SyncTask t) => t.name == task.name);
    _tasks.add(task);
  }

  /// Begin background synchronization: drain now if online, and on every reconnect.
  /// Idempotent — safe to call once from the app root.
  void start() {
    if (_started) return;
    _started = true;
    _connSub = _connectivity.onStatusChange.listen((bool online) {
      if (online) {
        unawaited(sync(respectBackoff: false));
      } else {
        _publishStatus();
      }
    });
    _publishStatus();
    if (_connectivity.isOnline) unawaited(sync());
  }

  void dispose() {
    unawaited(_connSub?.cancel());
    _connSub = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    status.dispose();
  }

  /// Queue a desired-state operation. The caller has already applied the optimistic
  /// UI update. Collapses against any already-queued op with the same storage key
  /// via the handler's [SyncHandler.merge]; then drains immediately if online.
  Future<void> enqueue(SyncOperation op) async {
    final SyncOperation? existing = _outbox.read(op.storageKey);
    if (existing != null) {
      final SyncHandler? handler = _handlers[op.type];
      // A registered handler decides the merge (null = self-cancelling, drop both);
      // with no handler yet, keep the incoming op.
      final SyncOperation? kept = handler != null
          ? handler.merge(op, existing)
          : op;
      if (kept == null) {
        // Self-cancelling (e.g. like then unlike offline) — drop both.
        await _outbox.remove(op.storageKey);
        _publishStatus();
        return;
      }
      await _outbox.upsert(kept.copyWith(status: SyncOpStatus.pending));
    } else {
      await _outbox.upsert(op);
    }
    _publishStatus();
    if (_connectivity.isOnline) await sync();
  }

  /// Drain the whole queue once, then run every registered background task.
  /// Re-entrancy guarded — a concurrent call shares the in-flight drain.
  Future<void> sync({bool respectBackoff = true}) {
    final Future<void>? running = _draining;
    if (running != null) return running;
    final Future<void> run = _run(respectBackoff: respectBackoff);
    _draining = run;
    return run.whenComplete(() => _draining = null);
  }

  /// Reset one failed/conflicted op to pending and drain (explicit user retry).
  Future<void> retry(String storageKey) async {
    final SyncOperation? op = _outbox.read(storageKey);
    if (op == null) return;
    await _outbox.upsert(
      op.copyWith(
        status: SyncOpStatus.pending,
        attempts: 0,
        nextAttemptAt: null,
      ),
    );
    _publishStatus();
    await sync(respectBackoff: false);
  }

  /// Retry every failed op (not conflicts — those need an explicit choice).
  Future<void> retryFailed() async {
    for (final SyncOperation op in _outbox.readAll()) {
      if (op.status == SyncOpStatus.failed) {
        await _outbox.upsert(
          op.copyWith(
            status: SyncOpStatus.pending,
            attempts: 0,
            nextAttemptAt: null,
          ),
        );
      }
    }
    _publishStatus();
    await sync(respectBackoff: false);
  }

  /// Resolve a parked conflict: [ConflictResolution.keepLocal] retries the local
  /// intent; [ConflictResolution.keepServer] discards it.
  Future<void> resolveConflict(
    String storageKey,
    ConflictResolution resolution,
  ) async {
    switch (resolution) {
      case ConflictResolution.keepServer:
        await discard(storageKey);
      case ConflictResolution.keepLocal:
        await retry(storageKey);
    }
  }

  /// Remove an op from the queue without sending it (user discard / server wins).
  Future<void> discard(String storageKey) async {
    await _outbox.remove(storageKey);
    _publishStatus();
  }

  // ── Internals ────────────────────────────────────────────────────────────────

  Future<void> _run({required bool respectBackoff}) async {
    if (!_connectivity.isOnline) {
      _publishStatus();
      return;
    }
    _setPhase(SyncPhase.syncing);
    await _drainOutbox(respectBackoff: respectBackoff);
    for (final SyncTask task in _tasks) {
      if (!_connectivity.isOnline) break;
      try {
        await task.run();
      } on Object catch (error, stack) {
        _logger.w(
          'sync.task.error ${task.name}',
          error: error,
          stackTrace: stack,
        );
      }
    }
    _publishStatus();
    _scheduleRetry();
  }

  Future<void> _drainOutbox({required bool respectBackoff}) async {
    final DateTime now = DateTime.now();
    for (final SyncOperation op in _outbox.readAll()) {
      if (!_connectivity.isOnline) break; // dropped offline mid-drain
      if (op.status == SyncOpStatus.conflict) continue; // awaits resolution
      if (op.status == SyncOpStatus.failed && respectBackoff) continue;
      if (respectBackoff && !op.isReady(now)) continue;

      final SyncHandler? handler = _handlers[op.type];
      if (handler == null) {
        // No handler registered for this type — drop it rather than wedge the
        // queue forever (a stale op from a removed feature).
        _logger.w('sync.no_handler ${op.type}');
        await _outbox.remove(op.storageKey);
        await _record(op, SyncHistoryResult.dropped, 'no_handler');
        continue;
      }

      final SyncOutcome outcome = await handler.reconcile(op);
      switch (outcome) {
        case SyncSuccess():
          await _outbox.remove(op.storageKey);
          await _record(op, SyncHistoryResult.synced, null);
        case SyncTransient(:final failure):
          await _onTransient(op, failure.code);
        case SyncTerminal(:final failure):
          _logger.w('sync.drop ${op.storageKey} (${failure.code})');
          await _outbox.remove(op.storageKey);
          await _record(op, SyncHistoryResult.dropped, failure.code);
        case SyncConflictOutcome(:final detail):
          await _outbox.upsert(
            op.copyWith(status: SyncOpStatus.conflict, lastError: detail),
          );
          await _record(op, SyncHistoryResult.conflict, detail);
      }
    }
  }

  Future<void> _onTransient(SyncOperation op, String code) async {
    final int attempts = op.attempts + 1;
    if (attempts >= _maxAttempts) {
      // Give up automatic retries; surface for manual retry.
      await _outbox.upsert(
        op.copyWith(status: SyncOpStatus.failed, attempts: attempts, lastError: code),
      );
      await _record(op, SyncHistoryResult.failed, code);
      return;
    }
    await _outbox.upsert(
      op.copyWith(
        status: SyncOpStatus.pending,
        attempts: attempts,
        nextAttemptAt: DateTime.now().add(_backoff(attempts)),
        lastError: code,
      ),
    );
  }

  /// Exponential backoff capped at [_maxBackoff]: base · 2^(attempts-1).
  Duration _backoff(int attempts) {
    final int factor = 1 << (attempts - 1).clamp(0, 20);
    final Duration delay = _baseBackoff * factor;
    return delay > _maxBackoff ? _maxBackoff : delay;
  }

  /// Arm a single timer for the soonest backing-off op so failed transient work
  /// retries even without a reconnect — one timer, not a per-op poll.
  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    final DateTime now = DateTime.now();
    DateTime? soonest;
    for (final SyncOperation op in _outbox.readAll()) {
      if (op.status != SyncOpStatus.pending) continue;
      final DateTime? at = op.nextAttemptAt;
      if (at == null || !at.isAfter(now)) continue;
      if (soonest == null || at.isBefore(soonest)) soonest = at;
    }
    if (soonest == null) return;
    final Duration wait = soonest.difference(now);
    _retryTimer = Timer(wait, () {
      if (_connectivity.isOnline) unawaited(sync());
    });
  }

  Future<void> _record(
    SyncOperation op,
    SyncHistoryResult result,
    String? error,
  ) => _history.record(
    SyncHistoryEntry(
      type: op.type,
      result: result,
      at: DateTime.now(),
      label: op.label,
      error: error,
    ),
  );

  void _setPhase(SyncPhase phase) {
    status.value = status.value.copyWith(phase: phase);
  }

  void _publishStatus() {
    final List<SyncOperation> ops = _outbox.readAll();
    final int failed = ops
        .where((SyncOperation o) => o.status == SyncOpStatus.failed)
        .length;
    final int conflicts = ops
        .where((SyncOperation o) => o.status == SyncOpStatus.conflict)
        .length;
    final int pending = ops.length - failed - conflicts;

    final SyncPhase phase;
    if (!_connectivity.isOnline) {
      phase = SyncPhase.offline;
    } else if (failed > 0 || conflicts > 0) {
      phase = SyncPhase.error;
    } else if (pending > 0) {
      phase = status.value.phase == SyncPhase.syncing
          ? SyncPhase.syncing
          : SyncPhase.idle;
    } else {
      phase = SyncPhase.idle;
    }

    final bool drainedEmpty = ops.isEmpty && _connectivity.isOnline;
    status.value = SyncStatus(
      phase: phase,
      pending: pending,
      failed: failed,
      conflicts: conflicts,
      lastSyncedAt: drainedEmpty ? DateTime.now() : status.value.lastSyncedAt,
      lastError: ops.isEmpty ? null : status.value.lastError,
    );
  }
}

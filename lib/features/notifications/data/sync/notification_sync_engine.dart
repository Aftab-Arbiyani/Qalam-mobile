/// The offline notification-action sync engine (docs/40 §23, §24) — mirrors the
/// social sync engine: event-driven flush on connectivity restore, a
/// re-entrancy-guarded single drain, transient-vs-terminal failure
/// classification, and a `ValueNotifier` revision so presentation shows a pending
/// indicator without a data→presentation dependency. Reconciles each queued
/// read/archive/delete by driving the server to it via [NotificationRepository];
/// a terminal failure (404 for an already-gone notification, etc.) drops the
/// entry — a fresh inbox read then corrects the UI.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/value_objects/queued_notification_action.dart';

class NotificationSyncEngine {
  NotificationSyncEngine({
    required NotificationRepository repository,
    required NotificationOutboxReader store,
    required ConnectivityService connectivity,
    required AppLogger logger,
  }) : _repository = repository,
       _store = store,
       _connectivity = connectivity,
       _logger = logger;

  final NotificationRepository _repository;
  final NotificationOutboxReader _store;
  final ConnectivityService _connectivity;
  final AppLogger _logger;

  /// Bumped whenever the queue size changes — the offline-pending indicator
  /// listens and re-reads [pendingCount].
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  StreamSubscription<bool>? _connSub;
  Future<void>? _draining;

  int get pendingCount => _store.count;

  /// Idempotent: listen for reconnects and drain now if already online.
  void start() {
    _connSub ??= _connectivity.onStatusChange.listen((bool online) {
      if (online) unawaited(flush());
    });
    if (_connectivity.isOnline) unawaited(flush());
  }

  void dispose() {
    unawaited(_connSub?.cancel());
    _connSub = null;
    revision.dispose();
  }

  /// Persist a desired action. The caller has already applied the optimistic UI
  /// update. If online, attempt an immediate drain; otherwise wait for reconnect.
  Future<void> enqueue(QueuedNotificationAction action) async {
    await _store.put(action);
    _bump();
    if (_connectivity.isOnline) await flush();
  }

  /// Drain the whole queue once (re-entrancy guarded — a concurrent call shares
  /// the in-flight drain).
  Future<void> flush() {
    final Future<void>? running = _draining;
    if (running != null) return running;
    final Future<void> run = _drain();
    _draining = run;
    return run.whenComplete(() => _draining = null);
  }

  Future<void> _drain() async {
    if (!_connectivity.isOnline) return;
    for (final QueuedNotificationAction action in _store.readAll()) {
      if (!_connectivity.isOnline) break; // dropped offline mid-drain
      final Result<Unit> result = await _reconcile(action);
      if (result.isOk) {
        await _store.remove(action.key);
        _bump();
      } else {
        final Failure? failure = result.failureOrNull;
        if (_isTransient(failure)) {
          continue; // leave queued; retry on next reconnect
        }
        _logger.w('notification.sync.drop ${action.key} (${failure?.code})');
        await _store.remove(action.key);
        _bump();
      }
    }
  }

  Future<Result<Unit>> _reconcile(QueuedNotificationAction a) =>
      switch (a.kind) {
        NotificationActionKind.read => _repository.markRead(a.targetId),
        NotificationActionKind.archive => _repository.archive(a.targetId),
        NotificationActionKind.delete => _repository.delete(a.targetId),
        NotificationActionKind.readAll => _repository.markAllRead(),
      };

  bool _isTransient(Failure? failure) =>
      failure is NetworkFailure || failure is RateLimitFailure;

  void _bump() => revision.value = _store.count;
}

/// The read/write surface the engine needs from the outbox — declared here so the
/// engine depends on a narrow contract (and tests can supply a fake) rather than
/// the concrete Hive-backed store.
abstract interface class NotificationOutboxReader {
  int get count;
  List<QueuedNotificationAction> readAll();
  Future<void> put(QueuedNotificationAction action);
  Future<void> remove(String key);
}

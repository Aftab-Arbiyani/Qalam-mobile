/// The offline social-action sync engine (docs/40 §23, §24) — mirrors the drafts
/// `DraftSyncEngine` pattern: event-driven flush on connectivity restore, a
/// re-entrancy-guarded single drain, transient-vs-terminal failure classification,
/// and a `ValueNotifier` revision so presentation can show a pending badge without
/// a data→presentation dependency. Reconciles each queued desired-state by driving
/// the server to it via [EngagementRepository]; a terminal failure drops the entry
/// (the next fresh server read corrects the UI).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/utils/result.dart';
import '../domain/engagement_repository.dart';
import '../domain/value_objects/queued_social_action.dart';
import 'social_outbox_store.dart';

class SocialSyncEngine {
  SocialSyncEngine({
    required EngagementRepository engagement,
    required SocialOutboxStore store,
    required ConnectivityService connectivity,
    required AppLogger logger,
  }) : _engagement = engagement,
       _store = store,
       _connectivity = connectivity,
       _logger = logger;

  final EngagementRepository _engagement;
  final SocialOutboxStore _store;
  final ConnectivityService _connectivity;
  final AppLogger _logger;

  /// Bumped whenever the queue size changes — the offline-pending indicator
  /// listens to this and re-reads [pendingCount].
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

  /// Persist a desired-state action. The caller has already applied the optimistic
  /// UI update. If online, attempt an immediate drain; otherwise it waits for the
  /// next reconnect.
  Future<void> enqueue(QueuedSocialAction action) async {
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
    for (final QueuedSocialAction action in _store.readAll()) {
      if (!_connectivity.isOnline) break; // dropped offline mid-drain
      final Result<Object?> result = await _reconcile(action);
      if (result.isOk) {
        await _store.remove(action.key);
        _bump();
      } else {
        final Failure? failure = result.failureOrNull;
        if (_isTransient(failure)) {
          continue; // leave queued; retry on next reconnect
        }
        // Terminal (e.g. 404/409/permission): drop it — a fresh read corrects UI.
        _logger.w('social.sync.drop ${action.key} (${failure?.code})');
        await _store.remove(action.key);
        _bump();
      }
    }
  }

  Future<Result<Object?>> _reconcile(QueuedSocialAction a) {
    switch (a.category) {
      case SocialCategory.pieceLike:
        return a.desired ? _engagement.like(a.targetId) : _engagement.unlike(a.targetId);
      case SocialCategory.pieceBookmark:
        return a.desired
            ? _engagement.bookmark(a.targetId)
            : _engagement.unbookmark(a.targetId);
      case SocialCategory.userFollow:
        return a.desired
            ? _engagement.follow(a.targetId)
            : _engagement.unfollow(a.targetId);
    }
  }

  bool _isTransient(Failure? failure) =>
      failure is NetworkFailure || failure is RateLimitFailure;

  void _bump() => revision.value = _store.count;
}

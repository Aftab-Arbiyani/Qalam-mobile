/// Offline draft synchronization engine (docs/40 §23, §42; M4 offline drafts).
///
/// Drains the local outbox — drafts whose [DraftSyncState] is dirty — through the
/// SAME [PieceEditorRepository] the online path uses (the brief: "offline sync
/// reuses the same repository interfaces as online publishing"). For each queued
/// draft it, in order: (1) creates or updates the piece content, doing a CLIENT-side
/// conflict check first (the frozen `v1` API has no stale-write rejection, so we
/// compare the server `updatedAt` against our sync base — docs/40 §42.1); (2)
/// uploads a pending cover; (3) runs the queued lifecycle intent (publish/schedule/
/// delete). Successes are written back as `synced`; transient (transport) failures
/// stay `pending` for the next reconnect; domain/validation failures become
/// `failed` with a reason; a detected divergence becomes `conflict`.
///
/// Retry is EVENT-DRIVEN, not a battery-draining timer: it runs on connectivity
/// restore ([start]), on app-resume / screen actions, and on explicit user retry
/// (docs/40 §36 "respect the wire"). One drain runs at a time (re-entrancy guarded).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/draft.dart';
import '../../domain/entities/draft_sync.dart';
import '../../domain/repositories/piece_editor_repository.dart';
import '../datasources/draft_local_data_source.dart';

class DraftSyncEngine {
  DraftSyncEngine({
    required PieceEditorRepository repository,
    required DraftLocalDataSource store,
    required ConnectivityService connectivity,
    required AppLogger logger,
  }) : _repo = repository,
       _store = store,
       _connectivity = connectivity,
       _logger = logger;

  final PieceEditorRepository _repo;
  final DraftLocalDataSource _store;
  final ConnectivityService _connectivity;
  final AppLogger _logger;

  StreamSubscription<bool>? _connSub;
  Future<void>? _draining;

  /// Bumped after every store mutation so listeners (drafts list / current draft
  /// controllers) refresh — without the engine importing the presentation layer.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Current cover-upload progress (0.0–1.0), or null when no upload is running —
  /// surfaced to the editor's cover field for the progress indicator.
  final ValueNotifier<double?> coverProgress = ValueNotifier<double?>(null);

  /// Begin background synchronization: drain now if online, and on every
  /// reconnect. Idempotent — safe to call once from the app root.
  void start() {
    _connSub ??= _connectivity.onStatusChange.listen((bool online) {
      if (online) unawaited(syncAll());
    });
    if (_connectivity.isOnline) unawaited(syncAll());
  }

  void dispose() {
    unawaited(_connSub?.cancel());
    _connSub = null;
    revision.dispose();
    coverProgress.dispose();
  }

  /// Drain the whole pending queue once (FIFO). Concurrent calls share one drain.
  Future<void> syncAll() {
    final Future<void>? running = _draining;
    if (running != null) return running;
    final Future<void> run = _drain();
    _draining = run;
    return run.whenComplete(() => _draining = null);
  }

  /// Sync a single draft on demand (an immediate publish/save action). Returns the
  /// final persisted draft, or null if it was deleted.
  Future<Draft?> syncDraftById(String localId) async {
    final Draft? draft = _store.read(localId);
    if (draft == null) return null;
    return _syncOne(draft);
  }

  Future<void> _drain() async {
    if (!_connectivity.isOnline) return;
    for (final Draft draft in _store.pending()) {
      if (!_connectivity.isOnline) break; // stop early if we dropped offline
      if (!_isSyncable(draft)) continue;
      await _syncOne(draft);
    }
  }

  /// A draft can only be pushed once it has the API-required language (or if it is
  /// simply a delete). Language-less drafts stay queued until the writer sets one.
  bool _isSyncable(Draft draft) =>
      draft.intent == DraftIntent.delete || draft.hasLanguage;

  Future<Draft?> _syncOne(Draft draft) async {
    if (draft.intent == DraftIntent.delete) return _syncDelete(draft);
    if (!_isSyncable(draft)) return draft; // wait for a language

    // Capture the queued lifecycle intent + schedule BEFORE pushing content — the
    // create/update response adopts server truth (intent→save, scheduledAt→server),
    // so the lifecycle action must be re-applied afterwards.
    final DraftIntent intent = draft.intent;
    final DateTime? scheduledAt = draft.scheduledAt;

    await _persist(draft.copyWith(syncState: DraftSyncState.syncing));

    // 1. Push content (create, or update with a conflict check). Both branches
    // resolve to a Draft carrying the outcome in its sync state.
    final Draft pushed = draft.isRemote
        ? await _pushUpdate(draft)
        : await _pushCreate(draft);

    // Anything other than a clean sync (failed / pending / conflict) stops here,
    // persisted for the next drain or user resolution.
    if (pushed.syncState != DraftSyncState.synced) return _persist(pushed);

    // 2. Upload a pending cover (needs the now-known remote id).
    Draft withCover = pushed;
    if (pushed.pendingCoverPath != null && pushed.isRemote) {
      coverProgress.value = 0;
      final Result<String> coverRes = await _repo.uploadCover(
        pushed.remoteId!,
        filePath: pushed.pendingCoverPath!,
        uploadKey: pushed.localId,
        onProgress: (double p) => coverProgress.value = p,
      );
      coverProgress.value = null;
      switch (coverRes) {
        case Ok<String>(:final String value):
          withCover = pushed.copyWith(
            coverImageKey: value.isNotEmpty ? value : pushed.coverImageKey,
            pendingCoverPath: null,
          );
        case Err<String>(:final Failure failure):
          if (_isTransient(failure)) {
            // Content is safe; leave the cover queued for the next drain.
            return _persist(pushed.copyWith(syncState: DraftSyncState.pending));
          }
          _logger.w('Cover upload failed', error: failure.code);
          withCover = pushed.copyWith(pendingCoverPath: null); // give up on it
      }
    }

    // 3. Run the queued lifecycle intent (re-applied on top of server truth).
    return _runIntent(withCover, intent, scheduledAt);
  }

  Future<Draft> _pushUpdate(Draft draft) async {
    // Conflict check: did the server change since our last sync base?
    final DateTime? base = draft.remoteUpdatedAt;
    if (base != null) {
      final Result<Draft> head = await _repo.fetchDraft(draft.remoteId!);
      if (head case Ok<Draft>(:final Draft value)) {
        final DateTime? serverAt = value.remoteUpdatedAt;
        if (serverAt != null && serverAt.isAfter(base)) {
          return draft.copyWith(
            syncState: DraftSyncState.conflict,
            lastError: 'server_changed',
          );
        }
      }
      // A transport error on the HEAD read → fall through; the update attempt
      // will surface the real failure rather than blocking on the check.
    }
    final Result<Draft> res = await _repo.updateDraft(draft);
    return res.fold((Draft d) => d, (Failure f) => _failed(draft, f));
  }

  Future<Draft> _pushCreate(Draft draft) async {
    final Result<Draft> res = await _repo.createDraft(draft);
    return res.fold((Draft d) => d, (Failure f) => _failed(draft, f));
  }

  /// Mark [draft] pending (transient) or failed (terminal), carrying the reason.
  Draft _failed(Draft draft, Failure failure) => draft.copyWith(
    syncState: _isTransient(failure)
        ? DraftSyncState.pending
        : DraftSyncState.failed,
    lastError: failure.code,
  );

  Future<Draft?> _runIntent(
    Draft draft,
    DraftIntent intent,
    DateTime? scheduledAt,
  ) async {
    switch (intent) {
      case DraftIntent.save:
        return _persist(draft.copyWith(syncState: DraftSyncState.synced));
      case DraftIntent.publish:
        final Result<Draft> res = await _repo.publish(draft);
        return res.fold(_persist, (Failure f) => _persistFailure(draft, f));
      case DraftIntent.schedule:
        if (scheduledAt == null) {
          return _persist(draft.copyWith(syncState: DraftSyncState.synced));
        }
        final Result<Draft> res = await _repo.schedule(draft, scheduledAt);
        return res.fold(_persist, (Failure f) => _persistFailure(draft, f));
      case DraftIntent.delete:
        return _syncDelete(draft);
    }
  }

  Future<Draft?> _syncDelete(Draft draft) async {
    if (!draft.isRemote) {
      await _store.remove(draft.localId);
      revision.value++;
      return null;
    }
    final Result<Unit> res = await _repo.deleteDraft(draft.remoteId!);
    if (res case Ok<Unit>()) {
      await _store.remove(draft.localId);
      revision.value++;
      return null;
    }
    final Failure failure = res.failureOrNull!;
    return _persistFailure(draft, failure);
  }

  Future<Draft> _persistFailure(Draft draft, Failure failure) => _persist(
    draft.copyWith(
      syncState: _isTransient(failure)
          ? DraftSyncState.pending
          : DraftSyncState.failed,
      lastError: failure.code,
    ),
  );

  Future<Draft> _persist(Draft draft) async {
    await _store.write(draft);
    revision.value++;
    return draft;
  }

  /// Transient = worth an automatic retry on reconnect (offline / timeout /
  /// network / 5xx / rate-limit). Domain/validation failures are terminal until
  /// the writer edits and re-queues.
  bool _isTransient(Failure failure) =>
      failure is NetworkFailure || failure is RateLimitFailure;
}

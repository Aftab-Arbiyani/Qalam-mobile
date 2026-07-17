/// An immutable snapshot of the synchronization engine's state (docs/40 §23) —
/// what the sync indicator, offline banner and queue-status surfaces render. The
/// engine publishes a new [SyncStatus] on every meaningful change through a
/// `ValueNotifier`, so presentation watches ONE value instead of reaching into the
/// engine's internals.
library;

/// The engine's coarse phase, chosen so the UI can pick an icon/colour directly.
enum SyncPhase {
  /// Nothing queued and online — fully in sync.
  idle,

  /// A drain is in progress.
  syncing,

  /// Offline — queued work waits for reconnect.
  offline,

  /// Online but some operations failed or are in conflict and need attention.
  error,
}

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.pending = 0,
    this.failed = 0,
    this.conflicts = 0,
    this.lastSyncedAt,
    this.lastError,
  });

  final SyncPhase phase;

  /// Operations waiting (or backing off) to be sent.
  final int pending;

  /// Operations that exhausted automatic retries — surfaced for manual retry.
  final int failed;

  /// Operations parked awaiting user conflict resolution.
  final int conflicts;

  /// When the queue last fully drained to empty (for "Last synced …").
  final DateTime? lastSyncedAt;

  /// The most recent failure code, for diagnostics.
  final String? lastError;

  /// Anything the user might want to see in the queue surface.
  int get outstanding => pending + failed + conflicts;

  bool get hasWork => outstanding > 0;
  bool get isSyncing => phase == SyncPhase.syncing;
  bool get isOffline => phase == SyncPhase.offline;
  bool get needsAttention => failed > 0 || conflicts > 0;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pending,
    int? failed,
    int? conflicts,
    Object? lastSyncedAt = _sentinel,
    Object? lastError = _sentinel,
  }) => SyncStatus(
    phase: phase ?? this.phase,
    pending: pending ?? this.pending,
    failed: failed ?? this.failed,
    conflicts: conflicts ?? this.conflicts,
    lastSyncedAt: lastSyncedAt == _sentinel
        ? this.lastSyncedAt
        : lastSyncedAt as DateTime?,
    lastError: lastError == _sentinel ? this.lastError : lastError as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is SyncStatus &&
      other.phase == phase &&
      other.pending == pending &&
      other.failed == failed &&
      other.conflicts == conflicts &&
      other.lastSyncedAt == lastSyncedAt &&
      other.lastError == lastError;

  @override
  int get hashCode =>
      Object.hash(phase, pending, failed, conflicts, lastSyncedAt, lastError);

  static const Object _sentinel = Object();
}

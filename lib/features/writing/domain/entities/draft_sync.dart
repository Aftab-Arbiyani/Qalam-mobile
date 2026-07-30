/// Draft synchronization vocabulary (M4 offline drafts; docs/40 §23, §42).
///
/// The frozen `v1` API has NO optimistic-concurrency / stale-write rejection
/// (`PATCH /pieces/:id` is owner-only, last-writer-wins). So conflict detection is
/// CLIENT-side: before pushing a queued edit the sync engine re-reads the server
/// piece and compares its `updatedAt` against the base the local copy was last
/// synced from; a mismatch means someone edited elsewhere → [DraftSyncState.conflict]
/// for the user to resolve. We never invent a server rule the backend doesn't have.
///
/// Pure Dart, wire-independent (these values are LOCAL Hive state, not sent to the
/// server); `.name` is the stable persisted token.
library;

/// Where a local draft stands relative to the server.
enum DraftSyncState {
  /// Local copy matches the last server truth; nothing queued.
  synced,

  /// Local edits (or a queued publish/schedule/delete) await the network.
  pending,

  /// A sync attempt is in flight right now.
  syncing,

  /// The last attempt failed for a non-transient reason (validation/domain rule);
  /// it will not auto-retry until the draft is edited or retried by the user.
  failed,

  /// The server changed under us since our last sync — needs user resolution.
  conflict;

  static DraftSyncState fromName(String? value) => values.firstWhere(
    (DraftSyncState e) => e.name == value,
    orElse: () => DraftSyncState.synced,
  );

  bool get isDirty => this == pending || this == syncing || this == failed;
}

/// The pending lifecycle action a queued draft must perform once its edits land.
/// `save` is the default (create/update only); the others map to the dedicated
/// backend lifecycle endpoints and run AFTER the draft's content is pushed.
enum DraftIntent {
  save,
  publish,
  schedule,
  delete;

  static DraftIntent fromName(String? value) => values.firstWhere(
    (DraftIntent e) => e.name == value,
    orElse: () => DraftIntent.save,
  );
}

/// How a detected conflict is resolved by the user.
enum ConflictResolution {
  /// Overwrite the server with the local copy (a normal PATCH; last write wins).
  keepLocal,

  /// Discard local edits and adopt the server copy.
  keepServer,
}

/// A single queued offline operation (docs/40 §23, §24) — the atom of the unified
/// synchronization engine. Every deferred write in the app (a like, a bookmark, a
/// follow, a comment, a profile edit, a settings change, a draft publish) is
/// modelled as ONE of these, regardless of feature. There is exactly one queue and
/// one operation type in the codebase — features never define their own.
///
/// An operation carries a *desired terminal state*, not an event: keying by
/// [dedupKey] within a [type] lets a later intent collapse an earlier one (toggle
/// like twice offline → one op), which makes replay idempotent. The handler
/// registered for [type] owns reconciliation ([SyncHandler.reconcile]) and how two
/// ops with the same [dedupKey] merge ([SyncHandler.merge]). Persisted as JSON in
/// the durable `prefs` box so a queued op survives a cold restart.
library;

import '../utils/typedefs.dart';

/// The lifecycle status of a queued operation as the engine drains it.
enum SyncOpStatus {
  /// Waiting to be drained (the default when enqueued or after a transient retry).
  pending('pending'),

  /// Currently being reconciled with the server (in a drain pass).
  inFlight('in_flight'),

  /// A terminal, non-conflict failure exhausted retries — kept for surfacing, not
  /// retried automatically (the user can retry or discard it).
  failed('failed'),

  /// The server diverged from the queued base — needs user conflict resolution
  /// before it can replay (docs/40 §42.1).
  conflict('conflict');

  const SyncOpStatus(this.wire);
  final String wire;

  static SyncOpStatus fromWire(String? value) => values.firstWhere(
    (SyncOpStatus s) => s.wire == value,
    orElse: () => SyncOpStatus.pending,
  );
}

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.type,
    required this.dedupKey,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.status = SyncOpStatus.pending,
    this.nextAttemptAt,
    this.lastError,
    this.label,
  });

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: (json['id'] as String?) ?? '',
    type: (json['type'] as String?) ?? '',
    dedupKey: (json['dedupKey'] as String?) ?? '',
    payload: json['payload'] is Map
        ? Json.from(json['payload'] as Map<dynamic, dynamic>)
        : const <String, dynamic>{},
    createdAt:
        DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    status: SyncOpStatus.fromWire(json['status'] as String?),
    nextAttemptAt: DateTime.tryParse((json['nextAttemptAt'] as String?) ?? ''),
    lastError: json['lastError'] as String?,
    label: json['label'] as String?,
  );

  /// Unique id for this enqueue — traceability + the history log. Distinct from
  /// [storageKey]: two enqueues that collapse share a [storageKey] but not an [id].
  final String id;

  /// The handler key (e.g. `social.like`, `notification.read`, `profile.update`).
  final String type;

  /// Collapse identity WITHIN a type — one pending op per (type, dedupKey).
  final String dedupKey;

  /// Handler-specific data needed to replay the op against the server.
  final Json payload;

  final DateTime createdAt;

  /// How many reconcile attempts have been made (drives backoff + the fail cap).
  final int attempts;

  final SyncOpStatus status;

  /// Earliest time a transient-failed op may be retried (exponential backoff). Null
  /// means "eligible now".
  final DateTime? nextAttemptAt;

  /// The last failure code, for diagnostics and the retry/conflict UI.
  final String? lastError;

  /// A short human-readable description for the queue UI (e.g. "Like · My Piece").
  final String? label;

  /// Primary key in the outbox — one entry per (type, dedupKey).
  String get storageKey => '$type::$dedupKey';

  /// Eligible to be drained now: pending (not failed/conflict/in-flight) and past
  /// its backoff gate.
  bool isReady(DateTime now) =>
      status == SyncOpStatus.pending &&
      (nextAttemptAt == null || !nextAttemptAt!.isAfter(now));

  SyncOperation copyWith({
    int? attempts,
    SyncOpStatus? status,
    Object? nextAttemptAt = _sentinel,
    Object? lastError = _sentinel,
  }) => SyncOperation(
    id: id,
    type: type,
    dedupKey: dedupKey,
    payload: payload,
    createdAt: createdAt,
    label: label,
    attempts: attempts ?? this.attempts,
    status: status ?? this.status,
    nextAttemptAt: nextAttemptAt == _sentinel
        ? this.nextAttemptAt
        : nextAttemptAt as DateTime?,
    lastError: lastError == _sentinel ? this.lastError : lastError as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type,
    'dedupKey': dedupKey,
    'payload': payload,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'attempts': attempts,
    'status': status.wire,
    'nextAttemptAt': ?nextAttemptAt?.toUtc().toIso8601String(),
    'lastError': ?lastError,
    'label': ?label,
  };

  static const Object _sentinel = Object();
}

/// The contract a feature implements to plug into the unified synchronization
/// engine (docs/40 §23). A handler is registered once per [type]; the engine owns
/// the queue, connectivity, retry/backoff, status and history, and calls back into
/// the handler only to (a) reconcile one operation with the server and (b) decide
/// how a new operation collapses onto an already-queued one with the same dedup
/// key. Features never touch connectivity or the outbox directly — this is the
/// single seam that keeps every offline feature on ONE engine.
library;

import '../error/failure.dart';
import '../utils/result.dart';
import 'sync_operation.dart';

/// The result of reconciling one operation. The engine reacts differently to each
/// so a handler expresses intent explicitly rather than the engine guessing from a
/// failure code.
sealed class SyncOutcome {
  const SyncOutcome();

  /// The op reconciled cleanly — remove it from the queue.
  const factory SyncOutcome.success() = SyncSuccess;

  /// Transport / rate-limit failure — keep the op and retry it later (backoff).
  const factory SyncOutcome.transient(Failure failure) = SyncTransient;

  /// A terminal failure the server will never accept (404/403/validation) — drop
  /// the op; a fresh read reconciles the optimistic UI.
  const factory SyncOutcome.terminal(Failure failure) = SyncTerminal;

  /// The server diverged from the op's base — park it as a conflict for the user
  /// to resolve (keep local / keep server), never auto-retry.
  const factory SyncOutcome.conflict({String detail}) = SyncConflictOutcome;
}

final class SyncSuccess extends SyncOutcome {
  const SyncSuccess();
}

final class SyncTransient extends SyncOutcome {
  const SyncTransient(this.failure);
  final Failure failure;
}

final class SyncTerminal extends SyncOutcome {
  const SyncTerminal(this.failure);
  final Failure failure;
}

final class SyncConflictOutcome extends SyncOutcome {
  const SyncConflictOutcome({this.detail = ''});
  final String detail;
}

abstract interface class SyncHandler {
  /// The operation [SyncOperation.type] this handler owns (e.g. `social.like`).
  String get type;

  /// Drive the server to the operation's desired state. Must be idempotent —
  /// replays happen (a retried op, a resumed drain). Returns how the engine should
  /// treat the outcome.
  Future<SyncOutcome> reconcile(SyncOperation op);

  /// Collapse an [incoming] op onto an [existing] queued op with the same
  /// [SyncOperation.storageKey]. Return the op to keep (usually [incoming], "latest
  /// intent wins"), or null to drop BOTH (a self-cancelling toggle). The default
  /// keeps the latest.
  SyncOperation? merge(SyncOperation incoming, SyncOperation existing) =>
      incoming;
}

/// Shared transient-vs-terminal classification (docs/40 §36) — the single source
/// of truth every handler and background task uses instead of re-deriving it.
/// Transient = worth an automatic retry (offline / timeout / transport / 5xx /
/// rate-limit). Everything else is terminal until the user re-queues.
bool isTransientFailure(Failure? failure) =>
    failure is NetworkFailure || failure is RateLimitFailure;

/// Map a repository [Result] to a [SyncOutcome] using the shared transient rule —
/// the common case for a handler that just drives one repository call.
SyncOutcome syncOutcomeFromResult(Result<Object?> result) => result.fold(
  (Object? _) => const SyncOutcome.success(),
  (Failure failure) => isTransientFailure(failure)
      ? SyncOutcome.transient(failure)
      : SyncOutcome.terminal(failure),
);

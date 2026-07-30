/// Notification-action + notification-preference handlers for the unified sync
/// engine (docs/40 §23, §24) — the replacement for the old bespoke
/// `NotificationSyncEngine` + `NotificationOutboxStore`. A queued read / archive /
/// delete / read-all is a [SyncOperation]; per-notification actions dedup on the
/// notification id (a stronger action supersedes a weaker one for the same id),
/// read-all is a global op keyed on a sentinel. Preference toggles are the
/// "Queued Settings Changes" surface — one pending op per category, latest wins.
library;

import '../../../../core/sync/sync_handler.dart';
import '../../../../core/sync/sync_operation.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../../domain/repositories/notification_repository.dart';

/// The one-way action a queued notification op reconciles. Ordering encodes
/// precedence when collapsing intents on the same id: delete ⟩ archive ⟩ read.
enum NotificationActionKind {
  read('read'),
  archive('archive'),
  delete('delete'),
  readAll('read_all');

  const NotificationActionKind(this.wire);
  final String wire;

  static NotificationActionKind fromWire(String? value) => values.firstWhere(
    (NotificationActionKind k) => k.wire == value,
    orElse: () => NotificationActionKind.read,
  );
}

/// Sentinel dedup key for the global mark-all-read op (never collapsed with a
/// per-row action).
const String kNotificationAllSentinel = '__all__';

/// The [SyncOperation.type] for a queued notification action.
const String kNotificationOpType = 'notification.action';

SyncOperation buildNotificationOperation({
  required NotificationActionKind kind,
  required String targetId,
  String? label,
}) {
  final DateTime now = DateTime.now();
  return SyncOperation(
    id: 'notif-${kind.wire}-$targetId-${now.microsecondsSinceEpoch}',
    type: kNotificationOpType,
    dedupKey: targetId,
    payload: <String, dynamic>{'kind': kind.wire, 'targetId': targetId},
    createdAt: now,
    label: label,
  );
}

class NotificationSyncHandler implements SyncHandler {
  NotificationSyncHandler(this._repository);

  final NotificationRepository _repository;

  @override
  String get type => kNotificationOpType;

  @override
  Future<SyncOutcome> reconcile(SyncOperation op) async {
    final NotificationActionKind kind = NotificationActionKind.fromWire(
      op.payload['kind'] as String?,
    );
    final String targetId = (op.payload['targetId'] as String?) ?? '';
    final result = switch (kind) {
      NotificationActionKind.read => await _repository.markRead(targetId),
      NotificationActionKind.archive => await _repository.archive(targetId),
      NotificationActionKind.delete => await _repository.delete(targetId),
      NotificationActionKind.readAll => await _repository.markAllRead(),
    };
    return syncOutcomeFromResult(result);
  }

  /// A stronger (later-ordered) kind wins for the same notification id, regardless
  /// of arrival order — mirrors the old outbox's supersedes rule exactly.
  @override
  SyncOperation? merge(SyncOperation incoming, SyncOperation existing) {
    final int incomingRank = NotificationActionKind.fromWire(
      incoming.payload['kind'] as String?,
    ).index;
    final int existingRank = NotificationActionKind.fromWire(
      existing.payload['kind'] as String?,
    ).index;
    return incomingRank >= existingRank ? incoming : existing;
  }
}

// ── Settings: notification preferences ───────────────────────────────────────

/// The [SyncOperation.type] for a queued notification-preference toggle.
const String kNotificationPrefOpType = 'settings.notification_preference';

SyncOperation buildNotificationPrefOperation({
  required NotificationPreferenceCategory category,
  required bool value,
  String? label,
}) {
  final DateTime now = DateTime.now();
  return SyncOperation(
    id: 'notifpref-${category.wire}-${now.microsecondsSinceEpoch}',
    type: kNotificationPrefOpType,
    dedupKey: category.wire,
    payload: <String, dynamic>{'category': category.wire, 'value': value},
    createdAt: now,
    label: label,
  );
}

class NotificationPreferenceSyncHandler implements SyncHandler {
  NotificationPreferenceSyncHandler(this._repository);

  final NotificationPreferencesRepository _repository;

  @override
  String get type => kNotificationPrefOpType;

  @override
  Future<SyncOutcome> reconcile(SyncOperation op) async {
    final NotificationPreferenceCategory? category =
        NotificationPreferenceCategory.values
            .where((NotificationPreferenceCategory c) =>
                c.wire == (op.payload['category'] as String?))
            .firstOrNull;
    if (category == null) {
      return const SyncOutcome.success(); // unknown category — nothing to do
    }
    final bool value = (op.payload['value'] as bool?) ?? true;
    final result = await _repository.update(category, value);
    return syncOutcomeFromResult(result);
  }

  /// Latest toggle for a category wins.
  @override
  SyncOperation? merge(SyncOperation incoming, SyncOperation existing) =>
      incoming;
}

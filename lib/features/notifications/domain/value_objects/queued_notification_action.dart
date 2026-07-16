/// A notification action queued while offline (docs/40 §23, §24) — mirrors the
/// social outbox's *desired terminal state* model. Read / archive / delete are
/// one-way transitions, so one pending action per notification id is enough
/// (latest intent wins, keyed by [targetId]); replaying simply drives the server
/// to that state and is idempotent. Persisted as JSON in the durable `prefs` box
/// so a queued action survives a cold restart.
library;

/// The one-way action a queued entry reconciles. Ordering encodes precedence when
/// collapsing intents on the same id: delete supersedes archive supersedes read.
/// [readAll] is a global action (keyed on a sentinel id), never collapsed against
/// per-row actions.
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

class QueuedNotificationAction {
  const QueuedNotificationAction({
    required this.kind,
    required this.targetId,
    required this.createdAt,
  });

  factory QueuedNotificationAction.fromJson(Map<String, dynamic> json) =>
      QueuedNotificationAction(
        kind: NotificationActionKind.fromWire(json['kind'] as String?),
        targetId: (json['targetId'] as String?) ?? '',
        createdAt:
            DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );

  final NotificationActionKind kind;
  final String targetId;
  final DateTime createdAt;

  /// Dedup identity — one pending action per notification. A later action on the
  /// same id (via [supersedes]) replaces an earlier, weaker one.
  String get key => targetId;

  /// Whether [this] should replace an already-queued [other] for the same target
  /// — a stronger (later-ordered) kind wins regardless of arrival order.
  bool supersedes(QueuedNotificationAction other) =>
      kind.index >= other.kind.index;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind.wire,
    'targetId': targetId,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}

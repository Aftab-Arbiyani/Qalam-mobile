/// The offline notification-action outbox (docs/40 §23, §26) — queued read /
/// archive / delete actions persisted as a single JSON map in the durable `prefs`
/// box (never wiped on a cache-schema bump, so a queued action survives a cold
/// restart). One entry per notification id; a stronger action supersedes a weaker
/// one for the same id ([QueuedNotificationAction.supersedes]). Parse failures
/// skip the bad entry — a queue is best-effort. Mirrors `SocialOutboxStore`.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../domain/value_objects/queued_notification_action.dart';
import 'notification_sync_engine.dart' show NotificationOutboxReader;

class NotificationOutboxStore implements NotificationOutboxReader {
  NotificationOutboxStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'notification_outbox';

  @override
  List<QueuedNotificationAction> readAll() {
    final Object? raw = _box.get(_key);
    if (raw is! String || raw.isEmpty) {
      return const <QueuedNotificationAction>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return const <QueuedNotificationAction>[];
      final List<QueuedNotificationAction> out = <QueuedNotificationAction>[];
      for (final Object? value in decoded.values) {
        if (value is Map) {
          try {
            out.add(
              QueuedNotificationAction.fromJson(
                Map<String, dynamic>.from(value),
              ),
            );
          } on Object {
            // Skip a corrupt entry.
          }
        }
      }
      out.sort(
        (QueuedNotificationAction a, QueuedNotificationAction b) =>
            a.createdAt.compareTo(b.createdAt),
      );
      return out;
    } on Object {
      return const <QueuedNotificationAction>[];
    }
  }

  @override
  int get count => readAll().length;

  /// Queue [action], letting a stronger action for the same id win (read →
  /// archive → delete). A weaker action never downgrades an already-queued one.
  @override
  Future<void> put(QueuedNotificationAction action) async {
    final Map<String, Map<String, dynamic>> map = _asMap();
    final Map<String, dynamic>? existingJson = map[action.key];
    if (existingJson != null) {
      final QueuedNotificationAction existing =
          QueuedNotificationAction.fromJson(existingJson);
      if (!action.supersedes(existing)) return;
    }
    map[action.key] = action.toJson();
    await _write(map);
  }

  @override
  Future<void> remove(String key) async {
    final Map<String, Map<String, dynamic>> map = _asMap();
    map.remove(key);
    await _write(map);
  }

  Future<void> clear() => _box.delete(_key);

  Map<String, Map<String, dynamic>> _asMap() {
    final Map<String, Map<String, dynamic>> map =
        <String, Map<String, dynamic>>{};
    for (final QueuedNotificationAction a in readAll()) {
      map[a.key] = a.toJson();
    }
    return map;
  }

  Future<void> _write(Map<String, Map<String, dynamic>> map) =>
      _box.put(_key, jsonEncode(map));
}

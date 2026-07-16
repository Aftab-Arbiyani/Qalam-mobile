/// The offline social-action outbox (docs/40 §23, §26) — queued like / bookmark /
/// follow desired-states, persisted as a single JSON map in the durable `prefs`
/// box (never wiped on a cache-schema bump, so a queued action survives a cold
/// restart). Deduped by `category:targetId` (latest desired-state wins). Parse
/// failures skip the bad entry — a queue is best-effort.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../domain/value_objects/queued_social_action.dart';

class SocialOutboxStore {
  SocialOutboxStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'social_outbox';

  List<QueuedSocialAction> readAll() {
    final Object? raw = _box.get(_key);
    if (raw is! String || raw.isEmpty) return const <QueuedSocialAction>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return const <QueuedSocialAction>[];
      final List<QueuedSocialAction> out = <QueuedSocialAction>[];
      for (final Object? value in decoded.values) {
        if (value is Map) {
          try {
            out.add(
              QueuedSocialAction.fromJson(Map<String, dynamic>.from(value)),
            );
          } on Object {
            // Skip a corrupt entry.
          }
        }
      }
      out.sort(
        (QueuedSocialAction a, QueuedSocialAction b) =>
            a.createdAt.compareTo(b.createdAt),
      );
      return out;
    } on Object {
      return const <QueuedSocialAction>[];
    }
  }

  int get count => readAll().length;

  Future<void> put(QueuedSocialAction action) async {
    final Map<String, Map<String, dynamic>> map = _asMap();
    map[action.key] = action.toJson();
    await _write(map);
  }

  Future<void> remove(String key) async {
    final Map<String, Map<String, dynamic>> map = _asMap();
    map.remove(key);
    await _write(map);
  }

  Future<void> clear() => _box.delete(_key);

  Map<String, Map<String, dynamic>> _asMap() {
    final Map<String, Map<String, dynamic>> map =
        <String, Map<String, dynamic>>{};
    for (final QueuedSocialAction a in readAll()) {
      map[a.key] = a.toJson();
    }
    return map;
  }

  Future<void> _write(Map<String, Map<String, dynamic>> map) =>
      _box.put(_key, jsonEncode(map));
}

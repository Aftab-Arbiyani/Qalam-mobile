/// The single durable outbox for the whole app (docs/40 §23, §26) — replaces the
/// per-feature outboxes (social / notification / …). Every queued [SyncOperation]
/// lives here, keyed by [SyncOperation.storageKey] so one pending op exists per
/// (type, dedupKey). Stored as a single JSON map in the durable `prefs` box: it is
/// unsynced user intent, never TTL cache, so it is NEVER wiped on a cache-schema
/// bump. Parse failures skip the bad entry — a queue is best-effort.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import 'sync_operation.dart';

/// The narrow read/write surface the engine depends on (so tests can supply a
/// fake instead of a real Hive box).
abstract interface class SyncOutboxReader {
  int get count;
  List<SyncOperation> readAll();
  SyncOperation? read(String storageKey);
  Future<void> upsert(SyncOperation op);
  Future<void> remove(String storageKey);
  Future<void> clear();
}

class SyncOutboxStore implements SyncOutboxReader {
  SyncOutboxStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'sync_outbox';

  @override
  List<SyncOperation> readAll() {
    final Object? raw = _box.get(_key);
    if (raw is! String || raw.isEmpty) return const <SyncOperation>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return const <SyncOperation>[];
      final List<SyncOperation> out = <SyncOperation>[];
      for (final Object? value in decoded.values) {
        if (value is Map) {
          try {
            out.add(SyncOperation.fromJson(Map<String, dynamic>.from(value)));
          } on Object {
            // Skip a corrupt entry rather than failing the whole queue.
          }
        }
      }
      out.sort(
        (SyncOperation a, SyncOperation b) =>
            a.createdAt.compareTo(b.createdAt),
      );
      return out;
    } on Object {
      return const <SyncOperation>[];
    }
  }

  @override
  int get count => readAll().length;

  @override
  SyncOperation? read(String storageKey) {
    for (final SyncOperation op in readAll()) {
      if (op.storageKey == storageKey) return op;
    }
    return null;
  }

  @override
  Future<void> upsert(SyncOperation op) async {
    final Map<String, Map<String, dynamic>> map = _asMap();
    map[op.storageKey] = op.toJson();
    await _write(map);
  }

  @override
  Future<void> remove(String storageKey) async {
    final Map<String, Map<String, dynamic>> map = _asMap();
    map.remove(storageKey);
    await _write(map);
  }

  @override
  Future<void> clear() => _box.delete(_key);

  Map<String, Map<String, dynamic>> _asMap() {
    final Map<String, Map<String, dynamic>> map =
        <String, Map<String, dynamic>>{};
    for (final SyncOperation op in readAll()) {
      map[op.storageKey] = op.toJson();
    }
    return map;
  }

  Future<void> _write(Map<String, Map<String, dynamic>> map) =>
      _box.put(_key, jsonEncode(map));
}

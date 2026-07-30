/// The synchronization history log (docs/40 §23) — a bounded, durable record of
/// what the engine did with each queued operation (synced / dropped / failed /
/// conflict), newest first. Backs the "Synchronization History" surface so a user
/// can see that their offline likes/edits eventually reconciled. Persisted in the
/// durable `prefs` box (it is a small audit trail, not TTL cache) and capped so it
/// never grows unbounded.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

/// How a queued operation ultimately resolved.
enum SyncHistoryResult {
  synced('synced'),
  dropped('dropped'),
  failed('failed'),
  conflict('conflict');

  const SyncHistoryResult(this.wire);
  final String wire;

  static SyncHistoryResult fromWire(String? value) => values.firstWhere(
    (SyncHistoryResult r) => r.wire == value,
    orElse: () => SyncHistoryResult.synced,
  );
}

class SyncHistoryEntry {
  const SyncHistoryEntry({
    required this.type,
    required this.result,
    required this.at,
    this.label,
    this.error,
  });

  factory SyncHistoryEntry.fromJson(Map<String, dynamic> json) =>
      SyncHistoryEntry(
        type: (json['type'] as String?) ?? '',
        result: SyncHistoryResult.fromWire(json['result'] as String?),
        at:
            DateTime.tryParse((json['at'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        label: json['label'] as String?,
        error: json['error'] as String?,
      );

  final String type;
  final SyncHistoryResult result;
  final DateTime at;
  final String? label;
  final String? error;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'result': result.wire,
    'at': at.toUtc().toIso8601String(),
    'label': ?label,
    'error': ?error,
  };
}

class SyncHistoryStore {
  SyncHistoryStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'sync_history';

  /// Cap on retained entries (oldest dropped first).
  static const int maxEntries = 100;

  /// All entries, newest first. Skips unparseable records.
  List<SyncHistoryEntry> readAll() {
    final Object? raw = _box.get(_key);
    if (raw is! String || raw.isEmpty) return const <SyncHistoryEntry>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <SyncHistoryEntry>[];
      final List<SyncHistoryEntry> out = <SyncHistoryEntry>[];
      for (final Object? value in decoded) {
        if (value is Map) {
          try {
            out.add(
              SyncHistoryEntry.fromJson(Map<String, dynamic>.from(value)),
            );
          } on Object {
            // Skip a corrupt entry.
          }
        }
      }
      return out;
    } on Object {
      return const <SyncHistoryEntry>[];
    }
  }

  /// Prepend [entry] (newest first) and trim to [maxEntries].
  Future<void> record(SyncHistoryEntry entry) async {
    final List<SyncHistoryEntry> all = <SyncHistoryEntry>[entry, ...readAll()];
    final List<SyncHistoryEntry> trimmed = all.length > maxEntries
        ? all.sublist(0, maxEntries)
        : all;
    await _box.put(
      _key,
      jsonEncode(
        trimmed.map((SyncHistoryEntry e) => e.toJson()).toList(growable: false),
      ),
    );
  }

  Future<void> clear() => _box.delete(_key);
}

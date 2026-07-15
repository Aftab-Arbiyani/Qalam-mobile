/// Local reading-history store (docs/40 §23, §26) — the only place the Hive
/// `reading` box is touched. A device-local record of what was read, how far, and
/// for how long, so "Recently Read", "Continue Reading", and "Resume" work with
/// no backend support and fully offline.
///
/// Entries are stored as JSON strings keyed by piece id; parse failures (from an
/// older on-disk shape) are skipped rather than crashing (forward-compatible). The
/// timeline is bounded to [maxEntries] most-recent records to cap the box size
/// (docs/40 §37).
library;

import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../utils/typedefs.dart';
import 'reading_history_entry.dart';

class ReadingHistoryStore {
  ReadingHistoryStore(this._box);

  final Box<dynamic> _box;

  /// Cap on retained history records (oldest evicted first).
  static const int maxEntries = 300;

  static const String _prefix = 'h:';

  String _key(String pieceId) => '$_prefix$pieceId';

  /// The most recent entry for [pieceId], or null if never read.
  ReadingHistoryEntry? read(String pieceId) => _parse(_box.get(_key(pieceId)));

  /// Upsert an entry, then evict the oldest records beyond [maxEntries].
  Future<void> write(ReadingHistoryEntry entry) async {
    await _box.put(_key(entry.pieceId), jsonEncode(entry.toJson()));
    await _prune();
  }

  Future<void> remove(String pieceId) => _box.delete(_key(pieceId));

  /// All entries, newest first (by `lastReadAt`). Skips unparseable records.
  List<ReadingHistoryEntry> readAll() {
    final List<ReadingHistoryEntry> entries = <ReadingHistoryEntry>[];
    for (final dynamic key in _box.keys) {
      if (key is! String || !key.startsWith(_prefix)) continue;
      final ReadingHistoryEntry? entry = _parse(_box.get(key));
      if (entry != null) entries.add(entry);
    }
    entries.sort(
      (ReadingHistoryEntry a, ReadingHistoryEntry b) =>
          b.lastReadAt.compareTo(a.lastReadAt),
    );
    return entries;
  }

  Future<void> clear() => _box.clear();

  Future<void> _prune() async {
    final List<ReadingHistoryEntry> all = readAll();
    if (all.length <= maxEntries) return;
    for (final ReadingHistoryEntry stale in all.sublist(maxEntries)) {
      await _box.delete(_key(stale.pieceId));
    }
  }

  ReadingHistoryEntry? _parse(Object? raw) {
    if (raw is! String) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return ReadingHistoryEntry.fromJson(Json.from(decoded));
    } on Object {
      return null; // Older/corrupt shape — drop it rather than crash.
    }
  }
}

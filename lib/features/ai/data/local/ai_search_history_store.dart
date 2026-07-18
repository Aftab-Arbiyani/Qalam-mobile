/// Device-local AI search history (docs 40 §23) — the recent semantic-search queries,
/// newest first, deduped case-insensitively, capped. Offline-first and available to
/// anonymous browsers. Distinct from the M6 keyword-search recents (different query
/// semantics); same durable `prefs`-box pattern, new key.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

class AiSearchHistoryStore {
  AiSearchHistoryStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'ai_search_history';
  static const int _maxEntries = 20;

  List<String> readAll() {
    final Object? raw = _box.get(_key);
    if (raw is! String || raw.isEmpty) return const <String>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <String>[];
      return decoded.whereType<String>().toList(growable: false);
    } on Object {
      return const <String>[];
    }
  }

  /// Prepend [query] (moving a case-insensitive duplicate to the top), cap, persist.
  Future<List<String>> add(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return readAll();
    final String lower = trimmed.toLowerCase();
    final List<String> next = <String>[
      trimmed,
      ...readAll().where((String q) => q.toLowerCase() != lower),
    ].take(_maxEntries).toList();
    await _write(next);
    return next;
  }

  Future<List<String>> remove(String query) async {
    final String lower = query.toLowerCase();
    final List<String> next = readAll()
        .where((String q) => q.toLowerCase() != lower)
        .toList();
    await _write(next);
    return next;
  }

  Future<void> clear() => _box.delete(_key);

  Future<void> _write(List<String> entries) =>
      _box.put(_key, jsonEncode(entries));
}

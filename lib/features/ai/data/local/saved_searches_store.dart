/// Device-local mirror of the caller's saved AI searches (docs 36 / docs 40 §23) —
/// the offline-first copy, newest first, deduped by name, capped. The server
/// (`/ai/search/saved`) is authoritative for signed-in users and merged in by the
/// controller. Same shape as the search recents store (new key). Parse failures skip
/// the bad entry — a device cache is disposable.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../domain/entities/saved_search.dart';

class SavedSearchesStore {
  SavedSearchesStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'ai_saved_searches';
  static const int _maxEntries = 50;

  List<SavedSearch> readAll() {
    final Object? raw = _box.get(_key);
    if (raw is! String || raw.isEmpty) return const <SavedSearch>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <SavedSearch>[];
      final List<SavedSearch> out = <SavedSearch>[];
      for (final Object? item in decoded) {
        if (item is Map) {
          try {
            out.add(SavedSearch.fromJson(Map<String, dynamic>.from(item)));
          } on Object {
            // Skip a corrupt entry.
          }
        }
      }
      return out;
    } on Object {
      return const <SavedSearch>[];
    }
  }

  /// Replace the whole list (used to merge the server copy), deduped by key, capped.
  Future<List<SavedSearch>> replaceAll(List<SavedSearch> entries) async {
    final Set<String> seen = <String>{};
    final List<SavedSearch> deduped = <SavedSearch>[];
    for (final SavedSearch e in entries) {
      if (seen.add(e.key)) deduped.add(e);
    }
    final List<SavedSearch> next = deduped.take(_maxEntries).toList();
    await _write(next);
    return next;
  }

  Future<void> clear() => _box.delete(_key);

  Future<void> _write(List<SavedSearch> entries) => _box.put(
    _key,
    jsonEncode(entries.map((SavedSearch e) => e.toJson()).toList()),
  );
}

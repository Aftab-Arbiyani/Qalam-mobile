/// Device-local recent searches (docs/40 §23, §25) — the offline-first mirror of
/// search history. Stored as a single JSON list in the `prefs` box (device data
/// that survives cache clears and logout), newest first, deduped by normalized
/// query+scope, capped at [_maxEntries]. Available to anonymous browsers and
/// offline (the server `/search/recent` is the authoritative copy for signed-in
/// users and is merged in by the controller). Parse failures skip the bad entry.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../domain/entities/recent_search.dart';

class SearchRecentsStore {
  SearchRecentsStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'search_recents';
  static const String _pendingClearKey = 'search_recents_pending_clear';
  static const int _maxEntries = 20;

  /// A "clear all" that could not reach the server yet (offline / failed). The
  /// next server sync must finish the clear before merging, or the cleared
  /// history would resurrect from the server copy.
  bool get pendingServerClear => _box.get(_pendingClearKey) == true;

  Future<void> setPendingServerClear(bool value) =>
      value ? _box.put(_pendingClearKey, true) : _box.delete(_pendingClearKey);

  List<RecentSearch> readAll() {
    final Object? raw = _box.get(_key);
    if (raw is! String || raw.isEmpty) return const <RecentSearch>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <RecentSearch>[];
      final List<RecentSearch> out = <RecentSearch>[];
      for (final Object? item in decoded) {
        if (item is Map) {
          try {
            out.add(RecentSearch.fromJson(Map<String, dynamic>.from(item)));
          } on Object {
            // Skip a corrupt entry — a cache is disposable.
          }
        }
      }
      return out;
    } on Object {
      return const <RecentSearch>[];
    }
  }

  /// Prepend [entry] (moving an existing same-key entry to the top), cap the list,
  /// and persist. Returns the new list.
  Future<List<RecentSearch>> add(RecentSearch entry) async {
    final List<RecentSearch> current = readAll()
        .where((RecentSearch e) => e.key != entry.key)
        .toList();
    final List<RecentSearch> next = <RecentSearch>[
      entry,
      ...current,
    ].take(_maxEntries).toList();
    await _write(next);
    return next;
  }

  /// Replace the whole list with [entries] (used to merge server recents in),
  /// deduped by key with the FIRST occurrence winning, capped.
  Future<List<RecentSearch>> replaceAll(List<RecentSearch> entries) async {
    final Set<String> seen = <String>{};
    final List<RecentSearch> deduped = <RecentSearch>[];
    for (final RecentSearch e in entries) {
      if (seen.add(e.key)) deduped.add(e);
    }
    final List<RecentSearch> next = deduped.take(_maxEntries).toList();
    await _write(next);
    return next;
  }

  Future<List<RecentSearch>> remove(String key) async {
    final List<RecentSearch> next = readAll()
        .where((RecentSearch e) => e.key != key)
        .toList();
    await _write(next);
    return next;
  }

  Future<void> clear() => _box.delete(_key);

  Future<void> _write(List<RecentSearch> entries) => _box.put(
    _key,
    jsonEncode(entries.map((RecentSearch e) => e.toJson()).toList()),
  );
}

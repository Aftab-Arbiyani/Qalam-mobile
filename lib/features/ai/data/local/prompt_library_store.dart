/// On-device AI preferences (AF2) — the Prompt Library (favourites, custom presets,
/// prompt history) and conversation pins. Device-scoped, local-only (the frozen `v1`
/// has no server surface for user prompt presets or conversation pinning), stored as
/// JSON strings in the shared Hive `prefs` box (mirrors [PreferencesStore] for
/// `searchFilters`). Never holds a secret.
library;

import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../domain/value_objects/prompt_preset.dart';

class PromptLibraryStore {
  PromptLibraryStore(this._box);

  final Box<dynamic> _box;

  static const String _kFavorites = 'ai_prompt_favorites';
  static const String _kCustom = 'ai_prompt_custom';
  static const String _kHistory = 'ai_prompt_history';
  static const String _kPinnedConversations = 'ai_pinned_conversations';

  /// Cap on remembered history entries (newest kept).
  static const int historyCap = 30;

  Set<String> favoriteIds() {
    final Object? raw = _box.get(_kFavorites);
    if (raw is! String) return <String>{};
    final Object? decoded = _tryDecode(raw);
    if (decoded is! List) return <String>{};
    return decoded.whereType<String>().toSet();
  }

  Future<void> setFavoriteIds(Set<String> ids) =>
      _box.put(_kFavorites, jsonEncode(ids.toList(growable: false)));

  List<PromptPreset> customPresets() {
    final Object? raw = _box.get(_kCustom);
    if (raw is! String) return <PromptPreset>[];
    final Object? decoded = _tryDecode(raw);
    if (decoded is! List) return <PromptPreset>[];
    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> m) => PromptPreset.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  Future<void> setCustomPresets(List<PromptPreset> presets) => _box.put(
        _kCustom,
        jsonEncode(presets.map((PromptPreset p) => p.toJson()).toList(growable: false)),
      );

  List<String> history() {
    final Object? raw = _box.get(_kHistory);
    if (raw is! String) return <String>[];
    final Object? decoded = _tryDecode(raw);
    if (decoded is! List) return <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }

  Future<void> setHistory(List<String> entries) => _box.put(
        _kHistory,
        jsonEncode(entries.take(historyCap).toList(growable: false)),
      );

  Future<void> clearHistory() => _box.delete(_kHistory);

  Set<String> pinnedConversationIds() {
    final Object? raw = _box.get(_kPinnedConversations);
    if (raw is! String) return <String>{};
    final Object? decoded = _tryDecode(raw);
    if (decoded is! List) return <String>{};
    return decoded.whereType<String>().toSet();
  }

  Future<void> setPinnedConversationIds(Set<String> ids) =>
      _box.put(_kPinnedConversations, jsonEncode(ids.toList(growable: false)));

  static Object? _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}

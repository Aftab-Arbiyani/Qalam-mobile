/// The search filters controller (docs/40 §8.4, §25) — client UI state holding
/// the active [SearchFilters], loaded from and written back to device prefs so a
/// session's narrowing survives (and is restored next launch). Kept alive so the
/// filter set is shared across the query, all result tabs, and app-resume. Synced
/// actions only; no async work beyond the prefs write.
library;

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/value_objects/search_filters.dart';

part 'search_filters_controller.g.dart';

@Riverpod(keepAlive: true)
class SearchFiltersController extends _$SearchFiltersController {
  @override
  SearchFilters build() {
    final String? raw = ref.watch(preferencesStoreProvider).searchFilters;
    if (raw == null || raw.isEmpty) return SearchFilters.none;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map) {
        // The tag pivot is a session-only narrowing (see [_persist]) — never
        // restore one a previous version may have written.
        return SearchFilters.fromJson(
          Map<String, dynamic>.from(decoded),
        ).copyWith(tag: null);
      }
    } on Object {
      // Corrupt prefs value — fall back to the empty filter set.
    }
    return SearchFilters.none;
  }

  Future<void> _persist(SearchFilters filters) async {
    state = filters;
    // The tag filter only exists via the tap-a-tag-result pivot; restoring it
    // on a later launch would invisibly narrow unrelated searches, so it
    // lives for the session only and is never written to prefs.
    final SearchFilters durable = filters.copyWith(tag: null);
    final store = ref.read(preferencesStoreProvider);
    if (durable.isEmpty) {
      await store.clearSearchFilters();
    } else {
      await store.setSearchFilters(jsonEncode(durable.toJson()));
    }
  }

  Future<void> setLanguages(List<String> codes) =>
      _persist(state.copyWith(languages: codes));

  Future<void> toggleLanguage(String code) {
    final List<String> next = state.languages.contains(code)
        ? (List<String>.of(state.languages)..remove(code))
        : (List<String>.of(state.languages)..add(code));
    return _persist(state.copyWith(languages: next));
  }

  Future<void> setGenres(List<String> slugs) =>
      _persist(state.copyWith(genres: slugs));

  Future<void> toggleGenre(String slug) {
    final List<String> next = state.genres.contains(slug)
        ? (List<String>.of(state.genres)..remove(slug))
        : (List<String>.of(state.genres)..add(slug));
    return _persist(state.copyWith(genres: next));
  }

  Future<void> setTag(String? slug) => _persist(state.copyWith(tag: slug));

  Future<void> setDateRange({DateTime? from, DateTime? to}) =>
      _persist(state.copyWith(dateFrom: from, dateTo: to));

  Future<void> setReadingTime({int? minSeconds, int? maxSeconds}) => _persist(
    state.copyWith(
      minReadingTimeSeconds: minSeconds,
      maxReadingTimeSeconds: maxSeconds,
    ),
  );

  Future<void> setSort(SearchSort sort) => _persist(state.copyWith(sort: sort));

  /// Reset every filter (and sort) to the default and clear the persisted value.
  Future<void> reset() => _persist(SearchFilters.none);
}

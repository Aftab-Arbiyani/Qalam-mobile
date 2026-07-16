/// The search "URL"-state controller (docs/40 §8.1, §8.4) — the single source of
/// the query text, the debounced query that drives suggestions, the *submitted*
/// query that drives results, and the active result tab. Pure UI state: it holds
/// no server data and does no I/O beyond recording a submitted query into recents.
/// Debounce (300 ms) is hand-rolled with a [Timer] disposed with the notifier.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/limits.dart';
import 'recent_searches_controller.dart';

part 'search_controller.g.dart';

/// Where the search screen is, derived from the query state.
enum SearchPhase {
  /// Empty query — show the discovery landing (recents, trending, shelves).
  discovery,

  /// Typing (query changed since last submit) — show autocomplete suggestions.
  suggesting,

  /// A query has been submitted — show the tabbed results.
  results,
}

class SearchState {
  const SearchState({
    this.rawQuery = '',
    this.debouncedQuery = '',
    this.submittedQuery = '',
    this.activeType = SearchType.all,
  });

  /// Live text in the field.
  final String rawQuery;

  /// The debounced query (≥ [Limits.searchQueryMin] chars) that drives
  /// autocomplete; empty when the field is too short or just submitted.
  final String debouncedQuery;

  /// The committed query that drives results; empty when browsing discovery.
  final String submittedQuery;

  /// The active result tab.
  final SearchType activeType;

  bool get hasSubmitted => submittedQuery.trim().isNotEmpty;

  bool get canSubmit => rawQuery.trim().length >= Limits.searchQueryMin;

  SearchPhase get phase {
    if (hasSubmitted && rawQuery.trim() == submittedQuery.trim()) {
      return SearchPhase.results;
    }
    if (rawQuery.trim().length >= Limits.searchQueryMin) {
      return SearchPhase.suggesting;
    }
    return SearchPhase.discovery;
  }

  SearchState copyWith({
    String? rawQuery,
    String? debouncedQuery,
    String? submittedQuery,
    SearchType? activeType,
  }) => SearchState(
    rawQuery: rawQuery ?? this.rawQuery,
    debouncedQuery: debouncedQuery ?? this.debouncedQuery,
    submittedQuery: submittedQuery ?? this.submittedQuery,
    activeType: activeType ?? this.activeType,
  );
}

@riverpod
class SearchQueryController extends _$SearchQueryController {
  Timer? _debounce;

  static const Duration _debounceWindow = Duration(milliseconds: 300);

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  /// The field text changed — update it and (debounced) the suggestion query.
  void onQueryChanged(String value) {
    _debounce?.cancel();
    state = state.copyWith(rawQuery: value);
    final String trimmed = value.trim();
    if (trimmed.length < Limits.searchQueryMin) {
      state = state.copyWith(debouncedQuery: '');
      return;
    }
    _debounce = Timer(_debounceWindow, () {
      // The controller may have been disposed while the timer was pending.
      state = state.copyWith(debouncedQuery: trimmed);
    });
  }

  /// Commit a query (from the field, a suggestion, a recent, or a trend chip),
  /// optionally focusing a specific result tab. Records it into recent
  /// searches. Returns false when the query is too short to search, so the
  /// caller can surface the minimum-length hint.
  bool submit([String? query, SearchType? type]) {
    final String q = (query ?? state.rawQuery).trim();
    if (q.length < Limits.searchQueryMin) return false;
    _debounce?.cancel();
    state = state.copyWith(
      rawQuery: q,
      submittedQuery: q,
      debouncedQuery: '',
      activeType: type ?? state.activeType,
    );
    ref
        .read(recentSearchesControllerProvider.notifier)
        .record(q, state.activeType);
    return true;
  }

  /// Switch the active result tab (does not re-run the query).
  void setActiveType(SearchType type) {
    if (type == state.activeType) return;
    state = state.copyWith(activeType: type);
  }

  /// Clear the field and return to the discovery landing.
  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }
}

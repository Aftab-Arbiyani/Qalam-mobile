/// Suggestion + trending providers (docs/40 §8.3, E8). [autocomplete] watches the
/// debounced query from [SearchQueryController] and returns prefix suggestions — a new
/// keystroke supersedes the last (the repository cancels the in-flight request).
/// [trendingSearches] is the cached snapshot shown on the discovery landing.
/// Both are best-effort: suggestions collapse to empty on error (they are a
/// convenience), while trending surfaces its failure so the shelf can hide.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/enums.dart';
import '../../domain/entities/autocomplete_result.dart';
import '../../domain/entities/trending_searches.dart';
import '../providers/search_providers.dart';
import 'search_controller.dart';

part 'search_suggestions_controller.g.dart';

@riverpod
Future<AutocompleteResult> autocomplete(Ref ref) async {
  // Select only the fields that should re-run the request — watching the whole
  // state would re-fire a (stale) request on every raw keystroke, defeating
  // the debounce.
  final (String query, SearchType type) = ref.watch(
    searchQueryControllerProvider.select(
      (SearchState s) => (s.debouncedQuery, s.activeType),
    ),
  );
  if (query.isEmpty) return const AutocompleteResult();
  final result = await ref
      .read(searchRepositoryProvider)
      .autocomplete(query, type: type);
  // Suggestions are a convenience — a cancelled or failed request yields nothing
  // rather than an error surface.
  return result.valueOrNull ?? const AutocompleteResult();
}

@riverpod
Future<TrendingSearches> trendingSearches(Ref ref) async {
  final result = await ref.read(searchRepositoryProvider).trending();
  return result.fold(
    (TrendingSearches value) => value,
    (Object failure) => throw failure,
  );
}

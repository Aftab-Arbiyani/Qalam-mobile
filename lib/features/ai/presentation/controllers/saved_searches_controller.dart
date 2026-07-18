/// Saved searches (AF4) — local-first mirror of the caller's server-saved searches.
/// `build()` returns the device copy immediately; `syncFromServer()` merges the
/// authoritative server list; save/remove write local-first then reach the server
/// best-effort. Kept alive for the app lifetime.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/saved_search.dart';
import '../providers/ai_providers.dart';
import '../providers/retrieval_providers.dart';

part 'saved_searches_controller.g.dart';

@Riverpod(keepAlive: true)
class SavedSearchesController extends _$SavedSearchesController {
  @override
  List<SavedSearch> build() => ref.watch(savedSearchesStoreProvider).readAll();

  /// Merge the authoritative server list into the local mirror (best-effort).
  Future<void> syncFromServer() async {
    final Result<List<SavedSearch>> result = await ref
        .read(aiRepositoryProvider)
        .listSavedSearches();
    if (result case Ok<List<SavedSearch>>(:final List<SavedSearch> value)) {
      state = await ref.read(savedSearchesStoreProvider).replaceAll(value);
    }
  }

  /// Save a search on the server, then refresh the local mirror from the response.
  Future<Result<SavedSearch>> save({
    required String name,
    required String query,
    String? queryType,
    String? storyId,
  }) async {
    final Result<SavedSearch> result = await ref
        .read(aiRepositoryProvider)
        .saveSearch(
          name: name,
          query: query,
          queryType: queryType,
          storyId: storyId,
        );
    if (result case Ok<SavedSearch>(:final SavedSearch value)) {
      final List<SavedSearch> next = <SavedSearch>[
        value,
        ...state.where((SavedSearch s) => s.key != value.key),
      ];
      state = await ref.read(savedSearchesStoreProvider).replaceAll(next);
    }
    return result;
  }

  /// Remove a saved search: drop locally immediately, delete on the server best-effort.
  Future<void> remove(SavedSearch entry) async {
    state = await ref
        .read(savedSearchesStoreProvider)
        .replaceAll(
          state.where((SavedSearch s) => s.key != entry.key).toList(),
        );
    if (entry.id.isNotEmpty) {
      await ref.read(aiRepositoryProvider).deleteSavedSearch(entry.id);
    }
  }
}

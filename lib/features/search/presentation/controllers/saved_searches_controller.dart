/// Saved searches — local-first mirror of the caller's server-saved searches.
/// `build()` returns the device copy immediately; `syncFromServer()` merges the
/// authoritative server list; save/remove write local-first then reach the server
/// best-effort. Kept alive for the app lifetime.
///
/// **D5 moved this into `features/search`** — it is the search screen's state, and it
/// only lived in `features/ai` because AF4 arrived there.
///
/// **It is authenticated, and that is enforced here rather than at the render.** Every
/// route behind it needs a session; firing one without a session is a 401, and a 401
/// outside `/auth/*` is terminal to `ApiClient` — it ends the session and clears the
/// caches. That is how the equivalent web surface broke a signed-out reader's page when
/// its feature flag came out (`platfrom/docs/48` §3.25), because the flag had been
/// keeping the request off public pages by accident rather than by design.
///
/// It also **clears on sign-out**. The mirror is per-account and the device box is not:
/// leaving it would show the previous reader's saved searches to whoever signs in next.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/retrieval/domain/saved_search.dart';
import '../../../../shared/retrieval/retrieval_providers.dart';

part 'saved_searches_controller.g.dart';

@Riverpod(keepAlive: true)
class SavedSearchesController extends _$SavedSearchesController {
  @override
  List<SavedSearch> build() {
    if (!_authed) {
      // Best-effort, and deliberately not awaited: `build` must answer synchronously,
      // and an empty state is correct the moment the session ends whether or not the
      // box write has landed.
      unawaited(
        ref.read(savedSearchesStoreProvider).replaceAll(const <SavedSearch>[]),
      );
      return const <SavedSearch>[];
    }
    return ref.watch(savedSearchesStoreProvider).readAll();
  }

  bool get _authed =>
      ref.watch(sessionControllerProvider).asData?.value.isAuthenticated ??
      false;

  /// Merge the authoritative server list into the local mirror (best-effort).
  /// A no-op with no session — see the library note on why that matters.
  Future<void> syncFromServer() async {
    if (!_authed) return;
    final Result<List<SavedSearch>> result = await ref
        .read(retrievalRepositoryProvider)
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
        .read(retrievalRepositoryProvider)
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
      await ref.read(retrievalRepositoryProvider).deleteSavedSearch(entry.id);
    }
  }
}

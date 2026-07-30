/// Recent searches (docs/40 §23, E8) — device-local first (offline, anonymous),
/// merged with the signed-in user's server-recorded history when online. Kept
/// alive so history is consistent across the screen's lifetime. Recording is
/// optimistic and local-immediate; the backend records a signed-in user's search
/// automatically on the query call, so we never POST. Deleting / clearing update
/// local instantly and propagate to the server best-effort.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/recent_search.dart';
import '../providers/search_providers.dart';

part 'recent_searches_controller.g.dart';

@Riverpod(keepAlive: true)
class RecentSearchesController extends _$RecentSearchesController {
  @override
  List<RecentSearch> build() => ref.watch(searchRecentsStoreProvider).readAll();

  bool get _online => ref.read(connectivityServiceProvider).isOnline;

  bool get _authed =>
      ref.read(sessionControllerProvider).stateOrUnknown.isAuthenticated;

  /// Pull the server's recorded recents and merge them ahead of local-only ones.
  /// No-op when anonymous or offline. Best-effort — a failure leaves local intact.
  Future<void> syncFromServer() async {
    if (!_authed || !_online) return;
    final store = ref.read(searchRecentsStoreProvider);
    // Finish an offline "clear all" first — merging before the server copy is
    // gone would resurrect the history the user already cleared.
    if (store.pendingServerClear) {
      final cleared = await ref
          .read(searchRepositoryProvider)
          .clearServerRecents();
      if (cleared.isErr) return;
      await store.setPendingServerClear(false);
    }
    final result = await ref.read(searchRepositoryProvider).serverRecents();
    final List<RecentSearch>? server = result.valueOrNull;
    if (server == null) return;
    // Server order (newest first) wins; local-only entries fill in behind.
    state = await store.replaceAll(<RecentSearch>[...server, ...state]);
  }

  /// Record a submitted query locally (newest first, deduped, capped).
  Future<void> record(String query, SearchType type, {DateTime? at}) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return;
    state = await ref
        .read(searchRecentsStoreProvider)
        .add(
          RecentSearch(
            query: trimmed,
            searchType: type,
            searchedAt: at ?? DateTime.now(),
          ),
        );
  }

  /// Remove one recent (local instantly; server best-effort).
  Future<void> remove(RecentSearch entry) async {
    state = await ref.read(searchRecentsStoreProvider).remove(entry.key);
    if (!_authed || !_online) return;
    final repo = ref.read(searchRepositoryProvider);
    String? serverId = entry.serverId;
    if (serverId == null) {
      // Recorded locally since the last sync — the backend auto-recorded it
      // too, so look its id up by key or the next sync resurrects it.
      final List<RecentSearch>? server =
          (await repo.serverRecents()).valueOrNull;
      serverId = server
          ?.where((RecentSearch s) => s.key == entry.key)
          .firstOrNull
          ?.serverId;
    }
    if (serverId != null) await repo.deleteServerRecent(serverId);
  }

  /// Clear all history (local instantly; the server side is retried on the
  /// next sync if it cannot be reached now).
  Future<void> clear() async {
    final store = ref.read(searchRecentsStoreProvider);
    await store.clear();
    state = const <RecentSearch>[];
    if (!_authed) return;
    final bool cleared =
        _online &&
        (await ref.read(searchRepositoryProvider).clearServerRecents()).isOk;
    await store.setPendingServerClear(!cleared);
  }
}

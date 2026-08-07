/// AI search history (AF4) — device-local recent semantic-search queries, shown as
/// chips on the search landing. Local-first (the backend auto-records queries on the
/// search call, so there is no POST here). Kept alive for the app lifetime.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/retrieval_providers.dart';

part 'ai_search_history_controller.g.dart';

@Riverpod(keepAlive: true)
class AiSearchHistoryController extends _$AiSearchHistoryController {
  @override
  List<String> build() => ref.watch(aiSearchHistoryStoreProvider).readAll();

  Future<void> record(String query) async {
    final List<String> next = await ref
        .read(aiSearchHistoryStoreProvider)
        .add(query);
    if (ref.mounted) state = next;
  }

  Future<void> remove(String query) async {
    final List<String> next = await ref
        .read(aiSearchHistoryStoreProvider)
        .remove(query);
    if (ref.mounted) state = next;
  }

  Future<void> clear() async {
    await ref.read(aiSearchHistoryStoreProvider).clear();
    if (ref.mounted) state = const <String>[];
  }
}

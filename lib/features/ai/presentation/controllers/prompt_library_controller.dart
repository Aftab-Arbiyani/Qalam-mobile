/// The Prompt Library controller (AF2) — built-in presets + user custom presets,
/// favourites, and prompt history, all persisted on-device via [PromptLibraryStore].
/// Synchronous (the Hive box is in-memory), kept alive so favourites/history survive
/// while the app runs; writes flush to disk immediately.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/value_objects/prompt_preset.dart';
import '../providers/ai_providers.dart';

part 'prompt_library_controller.g.dart';

class PromptLibraryState {
  const PromptLibraryState({
    required this.presets,
    required this.favoriteIds,
    required this.history,
  });

  /// Built-in presets followed by the user's custom presets.
  final List<PromptPreset> presets;
  final Set<String> favoriteIds;

  /// Recently used instructions, newest first.
  final List<String> history;

  List<PromptPreset> get builtIn =>
      presets.where((PromptPreset p) => p.isBuiltIn).toList(growable: false);
  List<PromptPreset> get custom =>
      presets.where((PromptPreset p) => !p.isBuiltIn).toList(growable: false);
  List<PromptPreset> get favorites =>
      presets.where((PromptPreset p) => favoriteIds.contains(p.id)).toList(growable: false);

  bool isFavorite(String id) => favoriteIds.contains(id);
}

@Riverpod(keepAlive: true)
class PromptLibraryController extends _$PromptLibraryController {
  @override
  PromptLibraryState build() => _read();

  PromptLibraryState _read() {
    final store = ref.read(promptLibraryStoreProvider);
    return PromptLibraryState(
      presets: <PromptPreset>[...kBuiltInPromptPresets, ...store.customPresets()],
      favoriteIds: store.favoriteIds(),
      history: store.history(),
    );
  }

  Future<void> toggleFavorite(String id) async {
    final store = ref.read(promptLibraryStoreProvider);
    final Set<String> next = <String>{...state.favoriteIds};
    if (!next.remove(id)) next.add(id);
    await store.setFavoriteIds(next);
    state = _read();
  }

  /// Save a new custom preset from a title + instruction. Returns the created preset.
  Future<PromptPreset> addCustom({required String title, required String instruction}) async {
    final store = ref.read(promptLibraryStoreProvider);
    final PromptPreset preset = PromptPreset.custom(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      instruction: instruction,
      createdAt: DateTime.now(),
    );
    await store.setCustomPresets(<PromptPreset>[...store.customPresets(), preset]);
    state = _read();
    return preset;
  }

  Future<void> deleteCustom(String id) async {
    final store = ref.read(promptLibraryStoreProvider);
    await store.setCustomPresets(
      store.customPresets().where((PromptPreset p) => p.id != id).toList(growable: false),
    );
    final Set<String> favs = <String>{...state.favoriteIds}..remove(id);
    await store.setFavoriteIds(favs);
    state = _read();
  }

  /// Record a used instruction in history (deduped, newest first, capped).
  Future<void> recordUse(String instruction) async {
    final String trimmed = instruction.trim();
    if (trimmed.isEmpty) return;
    final store = ref.read(promptLibraryStoreProvider);
    final List<String> next = <String>[
      trimmed,
      ...store.history().where((String h) => h != trimmed),
    ];
    await store.setHistory(next);
    state = _read();
  }

  Future<void> clearHistory() async {
    await ref.read(promptLibraryStoreProvider).clearHistory();
    state = _read();
  }
}

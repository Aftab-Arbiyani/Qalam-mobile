/// Editor-preferences controller (docs/40 §8.4, §26.1). A keep-alive UI-state
/// notifier holding the writer's editor typography + surface + autosave toggle,
/// persisting each change to the device `prefs` box so it survives navigation,
/// restart, and logout. Client/UI state — never synced.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../domain/value_objects/editor_preferences.dart';

part 'editor_preferences_controller.g.dart';

@Riverpod(keepAlive: true)
class EditorPreferencesController extends _$EditorPreferencesController {
  @override
  EditorPreferences build() {
    final prefs = ref.watch(preferencesStoreProvider);
    return EditorPreferences(
      fontSize: EditorFontSize.fromWire(prefs.editorFontSize),
      lineHeight: EditorLineHeight.fromWire(prefs.editorLineHeight),
      width: EditorWidth.fromWire(prefs.editorWidth),
      surface: EditorSurface.fromWire(prefs.editorSurface),
      autosaveEnabled: prefs.editorAutosave,
    );
  }

  Future<void> setFontSize(EditorFontSize value) async {
    await ref.read(preferencesStoreProvider).setEditorFontSize(value.wire);
    state = state.copyWith(fontSize: value);
  }

  Future<void> setLineHeight(EditorLineHeight value) async {
    await ref.read(preferencesStoreProvider).setEditorLineHeight(value.wire);
    state = state.copyWith(lineHeight: value);
  }

  Future<void> setWidth(EditorWidth value) async {
    await ref.read(preferencesStoreProvider).setEditorWidth(value.wire);
    state = state.copyWith(width: value);
  }

  Future<void> setSurface(EditorSurface value) async {
    await ref.read(preferencesStoreProvider).setEditorSurface(value.wire);
    state = state.copyWith(surface: value);
  }

  Future<void> setAutosaveEnabled(bool value) async {
    await ref.read(preferencesStoreProvider).setEditorAutosave(value);
    state = state.copyWith(autosaveEnabled: value);
  }
}

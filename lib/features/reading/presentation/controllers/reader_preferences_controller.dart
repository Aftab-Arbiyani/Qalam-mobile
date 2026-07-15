/// Reader-preferences controller (docs/40 §8.4, docs/41 §4.3, §35). A keep-alive
/// UI-state notifier holding the reader-adjustable typography ([ReaderPreferences])
/// and persisting each change to the device `prefs` box so it survives navigation,
/// app restarts, and logout. Changes apply live to the reading renderer.
///
/// This is client/UI state (not server state): it is device-scoped and never
/// synced. Theme mode is a separate device pref owned by `themeModeController`.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../domain/value_objects/reader_preferences.dart';

part 'reader_preferences_controller.g.dart';

@Riverpod(keepAlive: true)
class ReaderPreferencesController extends _$ReaderPreferencesController {
  @override
  ReaderPreferences build() {
    final prefs = ref.watch(preferencesStoreProvider);
    return ReaderPreferences(
      fontSize: ReadingFontSize.fromWire(prefs.readingSize),
      lineHeight: ReadingLineHeight.fromWire(prefs.readingLineHeight),
      width: ReadingWidth.fromWire(prefs.readingWidth),
    );
  }

  Future<void> setFontSize(ReadingFontSize value) async {
    await ref.read(preferencesStoreProvider).setReadingSize(value.wire);
    state = state.copyWith(fontSize: value);
  }

  Future<void> setLineHeight(ReadingLineHeight value) async {
    await ref.read(preferencesStoreProvider).setReadingLineHeight(value.wire);
    state = state.copyWith(lineHeight: value);
  }

  Future<void> setWidth(ReadingWidth value) async {
    await ref.read(preferencesStoreProvider).setReadingWidth(value.wire);
    state = state.copyWith(width: value);
  }
}

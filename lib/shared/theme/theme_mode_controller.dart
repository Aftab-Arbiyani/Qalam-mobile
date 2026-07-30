/// Theme-mode controller (docs/41 §22) — persisted `ThemeMode` (System/Light/
/// Dark). The client drives rendering; the value is stored in the device `prefs`
/// box (survives logout). Default is System.
library;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';

part 'theme_mode_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => _parse(ref.watch(preferencesStoreProvider).themeMode);

  Future<void> set(ThemeMode mode) async {
    await ref.read(preferencesStoreProvider).setThemeMode(mode.name);
    state = mode;
  }

  ThemeMode _parse(String? value) => ThemeMode.values.firstWhere(
    (ThemeMode m) => m.name == value,
    orElse: () => ThemeMode.system,
  );
}

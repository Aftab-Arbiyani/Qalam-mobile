/// Non-secret device preferences (docs/40 §26.1) — persisted in the Hive `prefs`
/// box. These survive logout (they are device, not session, state): theme mode,
/// reading size / line-height / width, reduced-motion override, the remember-me
/// flag that gates silent session restore (docs/40 §14.5), and the
/// onboarding-completed flag that gates the first-launch onboarding flow
/// (docs/40 §11.5, M2).
///
/// NEVER holds a secret or PII — tokens live in secure storage (docs/40 §27),
/// profile data is server-state. These are device-scoped booleans/enums only.
library;

import 'package:hive_ce_flutter/hive_flutter.dart';

class PreferencesStore {
  PreferencesStore(this._box);

  final Box<dynamic> _box;

  static const String _kThemeMode = 'theme_mode';
  static const String _kReducedMotion = 'reduced_motion';
  static const String _kReadingSize = 'reading_size';
  static const String _kReadingLineHeight = 'reading_line_height';
  static const String _kReadingWidth = 'reading_width';
  static const String _kRememberMe = 'remember_me';
  static const String _kOnboardingComplete = 'onboarding_complete';
  static const String _kEditorFontSize = 'editor_font_size';
  static const String _kEditorLineHeight = 'editor_line_height';
  static const String _kEditorWidth = 'editor_width';
  static const String _kEditorSurface = 'editor_surface';
  static const String _kEditorAutosave = 'editor_autosave';

  String? get themeMode => _box.get(_kThemeMode) as String?;
  Future<void> setThemeMode(String value) => _box.put(_kThemeMode, value);

  bool get reducedMotion => (_box.get(_kReducedMotion) as bool?) ?? false;
  Future<void> setReducedMotion(bool value) => _box.put(_kReducedMotion, value);

  /// Reader font-size step (`small` | `medium` | `large`, docs/41 §4.3).
  String get readingSize => (_box.get(_kReadingSize) as String?) ?? 'medium';
  Future<void> setReadingSize(String value) => _box.put(_kReadingSize, value);

  /// Reader line-height step (`compact` | `normal` | `relaxed`).
  String get readingLineHeight =>
      (_box.get(_kReadingLineHeight) as String?) ?? 'normal';
  Future<void> setReadingLineHeight(String value) =>
      _box.put(_kReadingLineHeight, value);

  /// Reader column width step (`narrow` | `medium` | `wide`).
  String get readingWidth => (_box.get(_kReadingWidth) as String?) ?? 'medium';
  Future<void> setReadingWidth(String value) => _box.put(_kReadingWidth, value);

  bool get rememberMe => (_box.get(_kRememberMe) as bool?) ?? false;
  Future<void> setRememberMe(bool value) => _box.put(_kRememberMe, value);

  /// Whether the first-launch onboarding flow has been seen/skipped. Persisted
  /// so onboarding shows exactly once per install (docs/40 §11.5).
  bool get onboardingComplete =>
      (_box.get(_kOnboardingComplete) as bool?) ?? false;
  Future<void> setOnboardingComplete(bool value) =>
      _box.put(_kOnboardingComplete, value);

  // ── Editor preferences (M4) — device-scoped writing surface prefs. ────────────

  /// Editor body font-size step (`small` | `medium` | `large`).
  String get editorFontSize =>
      (_box.get(_kEditorFontSize) as String?) ?? 'medium';
  Future<void> setEditorFontSize(String value) =>
      _box.put(_kEditorFontSize, value);

  /// Editor line-height step (`compact` | `normal` | `relaxed`).
  String get editorLineHeight =>
      (_box.get(_kEditorLineHeight) as String?) ?? 'normal';
  Future<void> setEditorLineHeight(String value) =>
      _box.put(_kEditorLineHeight, value);

  /// Editor writing-column width step (`narrow` | `medium` | `wide`).
  String get editorWidth => (_box.get(_kEditorWidth) as String?) ?? 'medium';
  Future<void> setEditorWidth(String value) => _box.put(_kEditorWidth, value);

  /// Editor surface theme (`system` | `sepia` | `dark`).
  String get editorSurface =>
      (_box.get(_kEditorSurface) as String?) ?? 'system';
  Future<void> setEditorSurface(String value) =>
      _box.put(_kEditorSurface, value);

  /// Whether debounced autosave is enabled (default on).
  bool get editorAutosave => (_box.get(_kEditorAutosave) as bool?) ?? true;
  Future<void> setEditorAutosave(bool value) =>
      _box.put(_kEditorAutosave, value);
}

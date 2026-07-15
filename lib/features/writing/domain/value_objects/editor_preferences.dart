/// Editor preferences (M4; docs/40 §26.1) — the writer-adjustable writing surface:
/// font size, line height, column width, surface theme, and the autosave toggle.
/// A pure value object with correct equality (so a provider `select` rebuilds only
/// on real change), persisted per-device (survives logout) and applied live to the
/// block editor. Distinct from the READER's preferences (a separate feature); the
/// two never import each other.
library;

import 'package:flutter/foundation.dart';

import '../../../../shared/domain/enums.dart';

/// Editor body font size. RTL (Nastaliq) is bumped a step, never below 20 —
/// matching the reader's script accommodation (docs/41 §4.4).
enum EditorFontSize {
  small('small', 16, 18),
  medium('medium', 18, 20),
  large('large', 20, 24);

  const EditorFontSize(this.wire, this.latinPx, this.rtlPx);

  final String wire;
  final double latinPx;
  final double rtlPx;

  double pxFor(TextDirectionKind direction) =>
      direction == TextDirectionKind.rtl ? rtlPx : latinPx;

  static EditorFontSize fromWire(String? value) => values.firstWhere(
    (EditorFontSize e) => e.wire == value,
    orElse: () => EditorFontSize.medium,
  );
}

/// Editor line-height multiplier applied to the per-script base leading.
enum EditorLineHeight {
  compact('compact', 1.4, 1.9),
  normal('normal', 1.6, 2.1),
  relaxed('relaxed', 1.9, 2.3);

  const EditorLineHeight(this.wire, this.latin, this.rtl);

  final String wire;
  final double latin;
  final double rtl;

  double heightFor(TextDirectionKind direction) =>
      direction == TextDirectionKind.rtl ? rtl : latin;

  static EditorLineHeight fromWire(String? value) => values.firstWhere(
    (EditorLineHeight e) => e.wire == value,
    orElse: () => EditorLineHeight.normal,
  );
}

/// Writing column width cap (bites only on tablet/landscape so the measure stays
/// comfortable; `wide` removes the cap).
enum EditorWidth {
  narrow('narrow', 560),
  medium('medium', 680),
  wide('wide', 4096);

  const EditorWidth(this.wire, this.maxWidth);

  final String wire;
  final double maxWidth;

  static EditorWidth fromWire(String? value) => values.firstWhere(
    (EditorWidth e) => e.wire == value,
    orElse: () => EditorWidth.medium,
  );
}

/// Editor surface tone. `system` follows the app theme; `sepia`/`dark` pin a
/// distraction-free writing background regardless of the app theme.
enum EditorSurface {
  system('system'),
  sepia('sepia'),
  dark('dark');

  const EditorSurface(this.wire);

  final String wire;

  static EditorSurface fromWire(String? value) => values.firstWhere(
    (EditorSurface e) => e.wire == value,
    orElse: () => EditorSurface.system,
  );
}

@immutable
class EditorPreferences {
  const EditorPreferences({
    this.fontSize = EditorFontSize.medium,
    this.lineHeight = EditorLineHeight.normal,
    this.width = EditorWidth.medium,
    this.surface = EditorSurface.system,
    this.autosaveEnabled = true,
  });

  final EditorFontSize fontSize;
  final EditorLineHeight lineHeight;
  final EditorWidth width;
  final EditorSurface surface;
  final bool autosaveEnabled;

  static const EditorPreferences initial = EditorPreferences();

  EditorPreferences copyWith({
    EditorFontSize? fontSize,
    EditorLineHeight? lineHeight,
    EditorWidth? width,
    EditorSurface? surface,
    bool? autosaveEnabled,
  }) => EditorPreferences(
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    width: width ?? this.width,
    surface: surface ?? this.surface,
    autosaveEnabled: autosaveEnabled ?? this.autosaveEnabled,
  );

  double bodyPx(TextDirectionKind direction) => fontSize.pxFor(direction);

  double lineHeightFor(TextDirectionKind direction) =>
      lineHeight.heightFor(direction);

  @override
  bool operator ==(Object other) =>
      other is EditorPreferences &&
      other.fontSize == fontSize &&
      other.lineHeight == lineHeight &&
      other.width == width &&
      other.surface == surface &&
      other.autosaveEnabled == autosaveEnabled;

  @override
  int get hashCode =>
      Object.hash(fontSize, lineHeight, width, surface, autosaveEnabled);
}

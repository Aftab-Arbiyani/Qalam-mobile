/// Elevation tokens (docs/41 §8) — warm ink-tinted drop shadows in LIGHT; NONE in
/// dark (dark expresses elevation with a border + one surface step, never a
/// shadow — see the components + [QTokens]).
library;

import 'package:flutter/widgets.dart';

abstract final class QElevation {
  // Ink `#24211B` at low alpha — never gray-black.
  static const List<BoxShadow> _level1 = <BoxShadow>[
    BoxShadow(color: Color(0x0F24211B), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x1424211B), offset: Offset(0, 1), blurRadius: 3),
  ];

  static const List<BoxShadow> _level2 = <BoxShadow>[
    BoxShadow(color: Color(0x0D24211B), offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(color: Color(0x1424211B), offset: Offset(0, 4), blurRadius: 12),
  ];

  static const List<BoxShadow> _level3 = <BoxShadow>[
    BoxShadow(color: Color(0x0F24211B), offset: Offset(0, 4), blurRadius: 8),
    BoxShadow(color: Color(0x1F24211B), offset: Offset(0, 16), blurRadius: 32),
  ];

  /// Shadows for [level] (1–3) in the given [brightness]. Dark → none.
  static List<BoxShadow> forLevel(Brightness brightness, int level) {
    if (brightness == Brightness.dark) return const <BoxShadow>[];
    return switch (level) {
      1 => _level1,
      2 => _level2,
      _ => _level3,
    };
  }
}

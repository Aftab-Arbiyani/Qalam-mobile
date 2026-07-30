/// `QTokens` — the [ThemeExtension] carrying Qalam tokens that Material's
/// `ColorScheme`/`TextTheme` cannot express (docs/41 §3.3): the full semantic
/// palette (`-text`/`-bg` triplets, accent variants, strong border) and the warm
/// elevation shadows. Widgets read it via `QTokens.of(context)`.
///
/// [lerp] is a discrete swap (no interpolation of the brand palette): a theme
/// change flips wholesale, matching the token-swap model.
library;

import 'package:flutter/material.dart';

import 'tokens/color_tokens.dart';
import 'tokens/elevation_tokens.dart';

@immutable
class QTokens extends ThemeExtension<QTokens> {
  const QTokens({
    required this.colors,
    required this.brightness,
    required this.shadow1,
    required this.shadow2,
    required this.shadow3,
  });

  factory QTokens.forBrightness(Brightness brightness) {
    final QColorSet colors = brightness == Brightness.dark
        ? QColorSet.dark
        : QColorSet.light;
    return QTokens(
      colors: colors,
      brightness: brightness,
      shadow1: QElevation.forLevel(brightness, 1),
      shadow2: QElevation.forLevel(brightness, 2),
      shadow3: QElevation.forLevel(brightness, 3),
    );
  }

  final QColorSet colors;
  final Brightness brightness;
  final List<BoxShadow> shadow1;
  final List<BoxShadow> shadow2;
  final List<BoxShadow> shadow3;

  bool get isDark => brightness == Brightness.dark;

  static QTokens of(BuildContext context) =>
      Theme.of(context).extension<QTokens>()!;

  @override
  QTokens copyWith({
    QColorSet? colors,
    Brightness? brightness,
    List<BoxShadow>? shadow1,
    List<BoxShadow>? shadow2,
    List<BoxShadow>? shadow3,
  }) {
    return QTokens(
      colors: colors ?? this.colors,
      brightness: brightness ?? this.brightness,
      shadow1: shadow1 ?? this.shadow1,
      shadow2: shadow2 ?? this.shadow2,
      shadow3: shadow3 ?? this.shadow3,
    );
  }

  @override
  QTokens lerp(ThemeExtension<QTokens>? other, double t) {
    if (other is! QTokens) return this;
    return t < 0.5 ? this : other;
  }
}

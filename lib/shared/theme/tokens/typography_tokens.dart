/// Typography tokens (docs/41 §4) — the 1.25 scale (12→49) + reading sizes and
/// per-script line-heights. Font asset bundling (Inter / Lora / Noto Devanagari /
/// Noto Nastaliq Urdu) lands in the design-system polish; M1 keeps `fontFamily`
/// unset (system default) so goldens are deterministic, while the intended
/// families are recorded here and carried in [QTokens] for the reading surface.
library;

import 'package:flutter/material.dart';

abstract final class QFontSizes {
  static const double xs = 12; // caption
  static const double sm = 14; // body-sm / buttons / inputs
  static const double base = 16; // body
  static const double lg = 20; // title-sm
  static const double xl = 25; // title
  static const double xxl = 31; // heading
  static const double xxxl = 39; // display (reading)
  static const double hero = 49; // onboarding only
}

abstract final class QLineHeights {
  static const double ui = 1.5;
  static const double reading = 1.7; // Latin
  static const double devanagari = 1.8; // Hindi
  static const double nastaliq = 2.1; // Urdu — never below 2.0
}

/// Intended families (bundled later). Chrome uses [ui]; reading uses [reading]
/// for Latin/Hindi and [readingUrdu] for Urdu (reading surfaces only).
abstract final class QFontFamilies {
  static const String ui = 'Inter';
  static const String reading = 'Lora';
  static const String readingUrdu = 'Noto Nastaliq Urdu';
  static const List<String> uiFallback = <String>[
    'Noto Sans Devanagari',
    'Noto Naskh Arabic',
  ];
  static const List<String> readingFallback = <String>['Noto Serif Devanagari'];
}

/// The Material [TextTheme] built from the scale, mapping M3 roles → Qalam roles.
TextTheme buildTextTheme({required Color primary, required Color secondary}) {
  TextStyle style(
    double size,
    FontWeight weight,
    double height, {
    Color? color,
  }) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color ?? primary,
  );

  return TextTheme(
    displaySmall: style(QFontSizes.hero, FontWeight.w600, 1.15),
    headlineMedium: style(QFontSizes.xxxl, FontWeight.w600, 1.25),
    headlineSmall: style(QFontSizes.xxl, FontWeight.w600, 1.3),
    titleLarge: style(QFontSizes.xl, FontWeight.w500, 1.35),
    titleMedium: style(QFontSizes.lg, FontWeight.w500, 1.4),
    bodyLarge: style(QFontSizes.base, FontWeight.w400, QLineHeights.ui),
    bodyMedium: style(QFontSizes.sm, FontWeight.w400, QLineHeights.ui),
    labelLarge: style(QFontSizes.sm, FontWeight.w500, QLineHeights.ui),
    bodySmall: style(
      QFontSizes.xs,
      FontWeight.w400,
      QLineHeights.ui,
      color: secondary,
    ),
  );
}

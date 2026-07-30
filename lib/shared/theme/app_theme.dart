/// Material 3 theme construction (docs/41 §3).
///
/// Two themes (light/dark) built entirely from Qalam tokens. Material's tonal
/// (surface-tint) elevation is suppressed — elevation is warm shadows in light,
/// border+surface in dark. Inputs use STATIC labels (no floating). Dynamic color
/// is plumbed but OFF by default (docs/41 §6): the brand palette always wins
/// unless [useDynamicColor] is explicitly enabled.
library;

import 'package:flutter/material.dart';

import 'q_tokens.dart';
import 'tokens/color_tokens.dart';
import 'tokens/radius_tokens.dart';
import 'tokens/typography_tokens.dart';

ThemeData buildQalamTheme({
  required Brightness brightness,
  ColorScheme? dynamicScheme,
  bool useDynamicColor = false,
}) {
  final QColorSet c = brightness == Brightness.dark
      ? QColorSet.dark
      : QColorSet.light;
  final bool isDark = brightness == Brightness.dark;

  final ColorScheme brandScheme =
      (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        brightness: brightness,
        primary: c.accent,
        onPrimary: c.accentContrast,
        secondary: c.accent,
        onSecondary: c.accentContrast,
        error: c.danger,
        onError: isDark ? c.accentContrast : const Color(0xFFFFFFFF),
        surface: c.bgSurface,
        onSurface: c.textPrimary,
        onSurfaceVariant: c.textSecondary,
        outline: c.borderStrong,
        outlineVariant: c.border,
        surfaceContainerLowest: c.bgSurface,
        surfaceContainerLow: c.bgSurface,
        surfaceContainer: c.bgRaised,
        surfaceContainerHigh: c.bgRaised,
        surfaceContainerHighest: c.bgRaised,
        surfaceTint: Colors.transparent, // suppress M3 tonal elevation overlay
      );

  // Dynamic color: opt-in only. When enabled, harmonize toward the device scheme
  // but keep the brand primary; default (M1) keeps the brand palette untouched.
  final ColorScheme scheme = (useDynamicColor && dynamicScheme != null)
      ? dynamicScheme.copyWith(primary: c.accent, onPrimary: c.accentContrast)
      : brandScheme;

  final TextTheme textTheme = buildTextTheme(
    primary: c.textPrimary,
    secondary: c.textSecondary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bgCanvas,
    canvasColor: c.bgCanvas,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bgCanvas,
      surfaceTintColor: Colors.transparent,
      foregroundColor: c.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: c.bgSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: QRadii.cardRadius,
        side: BorderSide(color: c.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.bgSurface,
      // Static labels — floating labels misbehave in RTL + Nastaliq (docs/41 §3.2).
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: QRadii.controlRadius,
        borderSide: BorderSide(color: c.borderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: QRadii.controlRadius,
        borderSide: BorderSide(color: c.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: QRadii.controlRadius,
        borderSide: BorderSide(color: c.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: QRadii.controlRadius,
        borderSide: BorderSide(color: c.danger, width: 2),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: c.textMuted),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.bgSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: QRadii.sheetRadius),
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.bgSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: QRadii.modalRadius),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.bgSurface,
      contentTextStyle: textTheme.bodyMedium,
      actionTextColor: c.accent,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: QRadii.cardRadius),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.bgCanvas,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.accentSubtle,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.bodySmall),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.bgRaised,
      side: BorderSide(color: c.border),
      shape: const RoundedRectangleBorder(borderRadius: QRadii.controlRadius),
      labelStyle: textTheme.bodySmall?.copyWith(color: c.textSecondary),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),
    extensions: <ThemeExtension<dynamic>>[QTokens.forBrightness(brightness)],
  );
}

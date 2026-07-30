/// Color tokens (docs/41 §5) — "warm paper and ink". Exact hexes from ADR §7,
/// byte-identical to the web `--q-*` tokens. A [QColorSet] holds the full palette
/// for one brightness; [QColorSet.light] / [QColorSet.dark] are the two sets the
/// theme is built from.
library;

import 'package:flutter/widgets.dart';

@immutable
class QColorSet {
  const QColorSet({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderStrong,
    required this.accent,
    required this.accentHover,
    required this.accentActive,
    required this.accentSubtle,
    required this.accentContrast,
    required this.success,
    required this.successText,
    required this.successBg,
    required this.warning,
    required this.warningText,
    required this.warningBg,
    required this.danger,
    required this.dangerText,
    required this.dangerBg,
    required this.info,
    required this.infoText,
    required this.infoBg,
  });

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgRaised;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color borderStrong;
  final Color accent;
  final Color accentHover;
  final Color accentActive;
  final Color accentSubtle;
  final Color accentContrast;
  final Color success;
  final Color successText;
  final Color successBg;
  final Color warning;
  final Color warningText;
  final Color warningBg;
  final Color danger;
  final Color dangerText;
  final Color dangerBg;
  final Color info;
  final Color infoText;
  final Color infoBg;

  /// Dialog/sheet scrim — the ink at 55% (both themes).
  static const Color scrim = Color(0x8C131110);

  static const QColorSet light = QColorSet(
    bgCanvas: Color(0xFFFAF7F1),
    bgSurface: Color(0xFFFFFFFF),
    bgRaised: Color(0xFFF3EEE5),
    textPrimary: Color(0xFF24211B),
    textSecondary: Color(0xFF6B655A),
    textMuted: Color(0xFF8F887A),
    border: Color(0xFFE7E1D6),
    borderStrong: Color(0xFF8F887A),
    accent: Color(0xFF9E4B28),
    accentHover: Color(0xFFB45A32),
    accentActive: Color(0xFF833E21),
    accentSubtle: Color(0xFFF5E7DE),
    accentContrast: Color(0xFFFFFFFF),
    success: Color(0xFF3E7C4F),
    successText: Color(0xFF2F6B40),
    successBg: Color(0xFFEAF0E7),
    warning: Color(0xFFA97A1F),
    warningText: Color(0xFF7E5B12),
    warningBg: Color(0xFFF7EEDC),
    danger: Color(0xFFB3382E),
    dangerText: Color(0xFFB3382E),
    dangerBg: Color(0xFFF8E7E4),
    info: Color(0xFF3B6EA8),
    infoText: Color(0xFF3B6EA8),
    infoBg: Color(0xFFEBF2F9),
  );

  static const QColorSet dark = QColorSet(
    bgCanvas: Color(0xFF131110),
    bgSurface: Color(0xFF1C1917),
    bgRaised: Color(0xFF26221E),
    textPrimary: Color(0xFFECE6DA),
    textSecondary: Color(0xFFA69F90),
    textMuted: Color(0xFF7A7367),
    border: Color(0xFF2E2A24),
    borderStrong: Color(0xFF7A7367),
    accent: Color(0xFFD07349),
    accentHover: Color(0xFFDD8A63),
    accentActive: Color(0xFFC2653C),
    accentSubtle: Color(0xFF3A2A20),
    accentContrast: Color(0xFF131110),
    success: Color(0xFF6FA97E),
    successText: Color(0xFF6FA97E),
    successBg: Color(0xFF1E2A20),
    warning: Color(0xFFC9974A),
    warningText: Color(0xFFC9974A),
    warningBg: Color(0xFF2E2718),
    danger: Color(0xFFD0655B),
    dangerText: Color(0xFFDA7E74),
    dangerBg: Color(0xFF2F1D1A),
    info: Color(0xFF7396C2),
    infoText: Color(0xFF7396C2),
    infoBg: Color(0xFF1D2530),
  );
}

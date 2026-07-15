/// Haptic feedback (docs/41 §19). Subtle, paired with a visual change, and it
/// respects the OS haptic setting (the platform channel is a no-op when disabled).
/// Centralized so feature code never calls `HapticFeedback` directly.
library;

import 'package:flutter/services.dart';

abstract final class QHaptics {
  /// A tap that caused a discrete state change (like/bookmark/follow toggle).
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// A light confirmation (clap tap, pull-to-refresh trigger).
  static Future<void> light() => HapticFeedback.lightImpact();

  /// A committed action (swipe-action commit, destructive confirm).
  static Future<void> medium() => HapticFeedback.mediumImpact();
}

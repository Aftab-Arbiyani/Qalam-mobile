/// Motion tokens (docs/41 §12): 150/250/400ms + three easings. Widgets read
/// these via the reduced-motion-aware helpers in `shared/motion/motion.dart` —
/// never inline a duration or curve literal.
library;

import 'package:flutter/animation.dart';

abstract final class QDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

abstract final class QCurves {
  /// Default — quick start, soft landing.
  static const Cubic standard = Cubic(0.2, 0, 0, 1);

  /// Entrances — decelerating ("settling on paper").
  static const Cubic decelerate = Cubic(0.16, 1, 0.3, 1);

  /// Exits only — leave faster than they arrive.
  static const Cubic accelerate = Cubic(0.3, 0, 1, 1);
}

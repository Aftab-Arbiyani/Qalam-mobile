/// Reduced-motion-aware motion helpers (docs/41 §13). Every animation routes
/// through these so a single switch (OS `disableAnimations` + the in-app override)
/// degrades all motion: transform animations become short opacity/instant, the
/// shimmer goes static. Widgets never inline a duration/curve.
library;

import 'package:flutter/widgets.dart';

import '../theme/tokens/motion_tokens.dart';

abstract final class Motion {
  /// Whether motion should be reduced for [context]. The in-app appearance
  /// override merges in via a provider the caller can OR into this.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// A duration, capped to [QDurations.fast] under reduced motion.
  static Duration duration(BuildContext context, Duration value) =>
      reduced(context) && value > QDurations.fast ? QDurations.fast : value;

  /// A curve, flattened to linear under reduced motion.
  static Curve curve(BuildContext context, Curve value) =>
      reduced(context) ? Curves.linear : value;
}

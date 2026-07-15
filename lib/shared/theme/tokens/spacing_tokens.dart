/// Spacing scale (docs/41 §7) — 4px base. Off-scale values are banned. Use these
/// constants (and the gap helpers) instead of raw numbers.
library;

import 'package:flutter/widgets.dart';

abstract final class QSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16; // mobile page gutter
  static const double s5 = 24; // default card / sheet padding
  static const double s6 = 32; // section gap (mobile)
  static const double s7 = 48; // large section gap
  static const double s8 = 64;
  static const double s9 = 96;

  /// The default mobile page gutter.
  static const EdgeInsets pagePadding = EdgeInsets.all(s4);

  /// Default card / sheet padding.
  static const EdgeInsets cardPadding = EdgeInsets.all(s5);
}

/// Vertical/horizontal gap helpers so widget trees read cleanly.
abstract final class Gap {
  static const Widget h1 = SizedBox(width: QSpacing.s1);
  static const Widget h2 = SizedBox(width: QSpacing.s2);
  static const Widget h3 = SizedBox(width: QSpacing.s3);
  static const Widget h4 = SizedBox(width: QSpacing.s4);
  static const Widget v1 = SizedBox(height: QSpacing.s1);
  static const Widget v2 = SizedBox(height: QSpacing.s2);
  static const Widget v3 = SizedBox(height: QSpacing.s3);
  static const Widget v4 = SizedBox(height: QSpacing.s4);
  static const Widget v5 = SizedBox(height: QSpacing.s5);
  static const Widget v6 = SizedBox(height: QSpacing.s6);
}

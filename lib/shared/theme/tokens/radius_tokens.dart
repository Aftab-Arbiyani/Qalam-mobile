/// Border-radius scale (docs/41 §9): 6 controls / 10 cards / 16 sheets / full.
library;

import 'package:flutter/widgets.dart';

abstract final class QRadii {
  static const double control = 6;
  static const double card = 10;
  static const double modal = 16;
  static const double full = 9999;

  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(control),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius modalRadius = BorderRadius.all(
    Radius.circular(modal),
  );

  /// Bottom sheets round only the top corners.
  static const BorderRadius sheetRadius = BorderRadius.only(
    topLeft: Radius.circular(modal),
    topRight: Radius.circular(modal),
  );
}

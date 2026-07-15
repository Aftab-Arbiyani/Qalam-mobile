/// Adaptive breakpoints (docs/41 §23) — the standard scale (no custom
/// breakpoints). Drives phone vs tablet/landscape layouts. Max two columns ever.
library;

import 'package:flutter/widgets.dart';

enum QBreakpoint { compact, small, medium, expanded }

abstract final class QBreakpoints {
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;

  static QBreakpoint of(double width) {
    if (width >= lg) return QBreakpoint.expanded;
    if (width >= md) return QBreakpoint.medium;
    if (width >= sm) return QBreakpoint.small;
    return QBreakpoint.compact;
  }

  /// At `>= lg` the bottom bar becomes a navigation rail / two-pane layout.
  static bool usesRail(double width) => width >= lg;
}

/// Picks a builder by width. Falls back to the compact builder when a wider one
/// is not supplied.
class QAdaptiveLayout extends StatelessWidget {
  const QAdaptiveLayout({
    required this.compact,
    this.medium,
    this.expanded,
    super.key,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final QBreakpoint bp = QBreakpoints.of(constraints.maxWidth);
        return switch (bp) {
          QBreakpoint.expanded => (expanded ?? medium ?? compact)(context),
          QBreakpoint.medium => (medium ?? compact)(context),
          QBreakpoint.small || QBreakpoint.compact => compact(context),
        };
      },
    );
  }
}

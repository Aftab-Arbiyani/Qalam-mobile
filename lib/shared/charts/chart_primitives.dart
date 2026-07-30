/// Shared chart data + palette primitives (docs/41 §charts) — the small building
/// blocks every analytics chart consumes, so line / bar / pie stay consistent and
/// theme-aware. Colours come from the design-system [QColorSet]; charts never
/// hard-code hexes.
library;

import 'package:flutter/widgets.dart';

import '../theme/tokens/color_tokens.dart';

/// A named series of y-values for a line/area chart.
@immutable
class ChartSeries {
  const ChartSeries({
    required this.label,
    required this.color,
    required this.values,
  });

  final String label;
  final Color color;
  final List<double> values;
}

/// A single categorical bar.
@immutable
class ChartBar {
  const ChartBar({required this.label, required this.value, this.color});

  final String label;
  final double value;
  final Color? color;
}

/// A single pie/donut slice.
@immutable
class ChartSlice {
  const ChartSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

/// The categorical palette, ordered for maximum separation on warm-paper themes.
List<Color> chartPalette(QColorSet colors) => <Color>[
  colors.accent,
  colors.info,
  colors.success,
  colors.warning,
  colors.danger,
  colors.textSecondary,
];

/// The colour for the [index]-th categorical series (wraps the palette).
Color chartColorAt(QColorSet colors, int index) {
  final List<Color> palette = chartPalette(colors);
  return palette[index % palette.length];
}

/// A lightweight, dependency-free donut chart with a legend (docs/41 §charts).
/// Renders [ChartSlice]s as arcs plus a wrapped legend of label + percentage.
/// Theme-aware and accessible — the arc is one semantics node with a text summary;
/// the legend rows carry the same label/percentage as visible text.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/q_tokens.dart';
import '../theme/tokens/spacing_tokens.dart';
import 'chart_primitives.dart';

class QPieChart extends StatelessWidget {
  const QPieChart({
    required this.slices,
    required this.semanticLabel,
    this.size = 132,
    super.key,
  });

  final List<ChartSlice> slices;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final double total = slices.fold<double>(
      0,
      (double s, ChartSlice c) => s + c.value,
    );

    return Row(
      children: <Widget>[
        Semantics(
          label: semanticLabel,
          image: true,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _PiePainter(
                slices: slices,
                total: total,
                trackColor: tokens.colors.border,
              ),
            ),
          ),
        ),
        Gap.h4,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final ChartSlice slice in slices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: slice.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Gap.h2,
                      Expanded(
                        child: Text(
                          slice.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Gap.h2,
                      Text(
                        total <= 0
                            ? '0%'
                            : '${((slice.value / total) * 100).round()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({
    required this.slices,
    required this.total,
    required this.trackColor,
  });

  final List<ChartSlice> slices;
  final double total;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2;
    final double stroke = radius * 0.32;
    final Rect rect = Rect.fromCircle(
      center: center,
      radius: radius - stroke / 2,
    );

    // Track ring (drawn even when empty so the chart reads as a chart).
    canvas.drawCircle(
      center,
      radius - stroke / 2,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (total <= 0) return;
    double start = -math.pi / 2;
    for (final ChartSlice slice in slices) {
      if (slice.value <= 0) continue;
      final double sweep = (slice.value / total) * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep - 0.02, // tiny gap between slices
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.total != total;
}

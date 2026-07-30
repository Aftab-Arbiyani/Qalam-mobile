/// A lightweight, dependency-free line/area chart (docs/41 §charts). A single
/// [CustomPainter] draws one or more [ChartSeries] over a shared x-axis with a
/// baseline, subtle gridlines, and an optional area fill for a single series.
/// Theme-aware (colours from [QTokens]) and accessible: the whole chart is one
/// semantics node with a text summary for screen readers.
library;

import 'package:flutter/material.dart';

import '../theme/q_tokens.dart';
import 'chart_primitives.dart';

class QLineChart extends StatelessWidget {
  const QLineChart({
    required this.series,
    required this.semanticLabel,
    this.height = 180,
    this.fillArea = true,
    super.key,
  });

  final List<ChartSeries> series;
  final String semanticLabel;
  final double height;
  final bool fillArea;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _LineChartPainter(
              series: series,
              gridColor: tokens.colors.border,
              baselineColor: tokens.colors.borderStrong,
              fillArea: fillArea,
            ),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.gridColor,
    required this.baselineColor,
    required this.fillArea,
  });

  final List<ChartSeries> series;
  final Color gridColor;
  final Color baselineColor;
  final bool fillArea;

  @override
  void paint(Canvas canvas, Size size) {
    final int pointCount = series.fold<int>(
      0,
      (int max, ChartSeries s) => s.values.length > max ? s.values.length : max,
    );
    if (pointCount < 2) return;

    double minY = double.infinity;
    double maxY = -double.infinity;
    for (final ChartSeries s in series) {
      for (final double v in s.values) {
        if (v < minY) minY = v;
        if (v > maxY) maxY = v;
      }
    }
    if (!minY.isFinite || !maxY.isFinite) return;
    if (minY == maxY) {
      // Flat series — centre it so the line is visible.
      minY -= 1;
      maxY += 1;
    }

    const double padTop = 8;
    const double padBottom = 8;
    final double chartHeight = size.height - padTop - padBottom;
    final double dx = size.width / (pointCount - 1);

    // Horizontal gridlines (quartiles).
    final Paint grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final double y = padTop + chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    double yOf(double value) =>
        padTop + chartHeight * (1 - (value - minY) / (maxY - minY));

    for (final ChartSeries s in series) {
      if (s.values.length < 2) continue;
      final Path line = Path();
      for (int i = 0; i < s.values.length; i++) {
        final Offset p = Offset(dx * i, yOf(s.values[i]));
        if (i == 0) {
          line.moveTo(p.dx, p.dy);
        } else {
          line.lineTo(p.dx, p.dy);
        }
      }

      if (fillArea && series.length == 1) {
        final Path area = Path.from(line)
          ..lineTo(dx * (s.values.length - 1), size.height - padBottom)
          ..lineTo(0, size.height - padBottom)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                s.color.withValues(alpha: 0.22),
                s.color.withValues(alpha: 0.0),
              ],
            ).createShader(Offset.zero & size),
        );
      }

      canvas.drawPath(
        line,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.fillArea != fillArea;
}

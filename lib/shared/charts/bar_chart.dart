/// A lightweight, dependency-free bar chart (docs/41 §charts). Draws one rounded
/// bar per [ChartBar] with a baseline and x-axis labels. Theme-aware and
/// accessible — the chart is one semantics node with a text summary, and each bar
/// value is folded into that summary for screen readers.
library;

import 'package:flutter/material.dart';

import '../theme/q_tokens.dart';
import 'chart_primitives.dart';

class QBarChart extends StatelessWidget {
  const QBarChart({
    required this.bars,
    required this.semanticLabel,
    this.height = 180,
    super.key,
  });

  final List<ChartBar> bars;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final Color barColor = tokens.colors.accent;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _BarChartPainter(
              bars: bars,
              barColor: barColor,
              baselineColor: tokens.colors.border,
              labelColor: tokens.colors.textMuted,
              labelStyle: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.bars,
    required this.barColor,
    required this.baselineColor,
    required this.labelColor,
    required this.labelStyle,
  });

  final List<ChartBar> bars;
  final Color barColor;
  final Color baselineColor;
  final Color labelColor;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    const double labelBand = 18;
    final double chartHeight = size.height - labelBand;
    final double maxVal = bars.fold<double>(
      0,
      (double m, ChartBar b) => b.value > m ? b.value : m,
    );
    final double slot = size.width / bars.length;
    final double barWidth = (slot * 0.56).clamp(4, 40);

    // Baseline.
    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      Paint()
        ..color = baselineColor
        ..strokeWidth = 1,
    );

    for (int i = 0; i < bars.length; i++) {
      final ChartBar bar = bars[i];
      final double cx = slot * i + slot / 2;
      final double h = maxVal <= 0 ? 0 : chartHeight * (bar.value / maxVal);
      if (h > 0) {
        final RRect rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - barWidth / 2, chartHeight - h, barWidth, h),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(rect, Paint()..color = bar.color ?? barColor);
      }

      if (labelStyle != null) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: bar.label,
            style: labelStyle!.copyWith(color: labelColor),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout(maxWidth: slot);
        tp.paint(
          canvas,
          Offset(cx - tp.width / 2, chartHeight + (labelBand - tp.height) / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) =>
      oldDelegate.bars != bars || oldDelegate.barColor != barColor;
}

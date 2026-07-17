/// Analytics loading skeletons (docs/41 §32) — a metric-grid placeholder and a
/// section placeholder shown while the aggregates load, so the dashboard paints its
/// shape immediately instead of a spinner (docs/40 §36 perceived performance).
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';
import 'metric_card.dart';

class MetricGridSkeleton extends StatelessWidget {
  const MetricGridSkeleton({this.count = 6, super.key});

  final int count;

  @override
  Widget build(BuildContext context) => MetricGrid(
    children: <Widget>[
      for (int i = 0; i < count; i++) const _MetricCardSkeleton(),
    ],
  );
}

class _MetricCardSkeleton extends StatelessWidget {
  const _MetricCardSkeleton();

  @override
  Widget build(BuildContext context) => const QCard(
    padding: QCardPadding.md,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        QSkeleton(width: 20, height: 20),
        Gap.v3,
        QSkeleton(width: 60, height: 22),
        SizedBox(height: 6),
        QSkeleton(width: 90, height: 12),
      ],
    ),
  );
}

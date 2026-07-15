/// Reading-progress bar (docs/41 §11.19, §35) — a 2px accent bar that fills in the
/// reading direction (right→left for Urdu). Exposes a `progressbar` semantic with
/// the value in whole percent for screen readers. Reused by the reader chrome and
/// the Continue-Reading cards.
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';

class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({
    required this.progress,
    this.height = 2,
    this.direction = TextDirection.ltr,
    super.key,
  });

  /// 0.0–1.0.
  final double progress;
  final double height;
  final TextDirection direction;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final double clamped = progress.clamp(0.0, 1.0);
    return Semantics(
      label: 'Reading progress',
      value: '${(clamped * 100).round()}%',
      child: SizedBox(
        height: height,
        child: Directionality(
          textDirection: direction,
          child: DecoratedBox(
            decoration: BoxDecoration(color: tokens.colors.bgRaised),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: clamped,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: tokens.colors.accent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

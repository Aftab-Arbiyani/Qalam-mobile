/// Badge (docs/41 §11.9). A notification dot or a count pill (capped "9+"), in the
/// accent — never alarm-red. A screen-reader label is REQUIRED.
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';

class QBadge extends StatelessWidget {
  const QBadge.dot({required this.semanticLabel, super.key}) : count = null;
  const QBadge.count({
    required int this.count,
    required this.semanticLabel,
    super.key,
  });

  final int? count;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final Color accent = tokens.colors.accent;

    if (count == null) {
      return Semantics(
        label: semanticLabel,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
      );
    }

    final String text = count! > 9 ? '9+' : '$count';
    return Semantics(
      label: semanticLabel,
      child: Container(
        constraints: const BoxConstraints(minWidth: 16),
        height: 16,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: tokens.colors.accentContrast,
            fontSize: 10,
            height: 1,
          ),
        ),
      ),
    );
  }
}

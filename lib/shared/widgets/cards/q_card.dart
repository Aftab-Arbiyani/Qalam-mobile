/// Card primitive (docs/41 §11.2). Surface + hairline border + `shadow-1` in
/// light (border-only in dark). `interactive` adds press feedback and raises to
/// `shadow-2`. Padding presets: none / md(16) / lg(24).
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import '../../theme/tokens/radius_tokens.dart';

enum QCardPadding { none, md, lg }

class QCard extends StatelessWidget {
  const QCard({
    required this.child,
    this.padding = QCardPadding.lg,
    this.onTap,
    super.key,
  });

  final Widget child;
  final QCardPadding padding;
  final VoidCallback? onTap;

  EdgeInsets get _insets => switch (padding) {
    QCardPadding.none => EdgeInsets.zero,
    QCardPadding.md => const EdgeInsets.all(16),
    QCardPadding.lg => const EdgeInsets.all(24),
  };

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final bool interactive = onTap != null;

    final Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colors.bgSurface,
        borderRadius: QRadii.cardRadius,
        border: Border.all(color: tokens.colors.border),
        boxShadow: tokens.shadow1,
      ),
      child: Padding(padding: _insets, child: child),
    );

    if (!interactive) return surface;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: QRadii.cardRadius,
        onTap: onTap,
        child: surface,
      ),
    );
  }
}

/// Metric + trend cards (docs/41 §30). [MetricCard] is a single headline figure
/// with an icon and label; [MetricGrid] lays them two-up responsively. Both are
/// const-friendly and carry a merged semantics label so a screen reader announces
/// "Views, 1.2K" as one node instead of three fragments.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final Color accent = color ?? tokens.colors.accent;

    return Semantics(
      container: true,
      label: '$label, $value${caption == null ? '' : ', $caption'}',
      child: ExcludeSemantics(
        child: QCard(
          padding: QCardPadding.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 20, color: accent),
              Gap.v3,
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
              if (caption != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.colors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A responsive two-up grid of metric cards. Uses the available width to pick the
/// column count (2 on phones, 3 on wide/tablet) — docs/30 responsive.
class MetricGrid extends StatelessWidget {
  const MetricGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 600 ? 3 : 2;
        const double gap = QSpacing.s3;
        final double itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final Widget child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

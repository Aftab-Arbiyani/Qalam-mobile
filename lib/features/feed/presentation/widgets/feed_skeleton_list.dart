/// First-load skeleton for feed surfaces (docs/41 §11.15) — a short column of
/// piece-card skeletons matching the real card min-height so there is no reflow
/// when content lands. Appears within 100ms; static under reduced motion.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';

class FeedSkeletonList extends StatelessWidget {
  const FeedSkeletonList({this.count = 6, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: QSpacing.s2),
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: QSpacing.s4,
          vertical: QSpacing.s2,
        ),
        child: QCard(padding: QCardPadding.none, child: QPieceCardSkeleton()),
      ),
    );
  }
}

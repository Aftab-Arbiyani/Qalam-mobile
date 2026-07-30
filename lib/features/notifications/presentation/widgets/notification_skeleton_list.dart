/// The first-load skeleton for the inbox (docs/41 §11.15) — rows that match the
/// real [NotificationTile] min-height so content arrives without reflow. Shimmer
/// goes static under reduced motion (handled by [QSkeleton]).
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';

class NotificationSkeletonList extends StatelessWidget {
  const NotificationSkeletonList({this.count = 8, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: QSpacing.s2),
      itemCount: count,
      itemBuilder: (BuildContext context, int _) => const _RowSkeleton(),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QSpacing.s4,
        vertical: QSpacing.s3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QSkeleton.avatar(size: 40),
          const SizedBox(width: QSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const QSkeleton(),
                const SizedBox(height: 6),
                QSkeleton.line(width: 140),
                const SizedBox(height: 6),
                QSkeleton.line(width: 48, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

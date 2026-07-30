/// Skeleton loaders (docs/41 §11.15). A shimmering placeholder that appears
/// within 100ms and matches real content min-heights (no reflow). The shimmer
/// sweeps inline-start → inline-end (mirrors in RTL) and goes STATIC under
/// reduced motion.
library;

import 'package:flutter/material.dart';

import '../../motion/motion.dart';
import '../../theme/q_tokens.dart';
import '../../theme/tokens/radius_tokens.dart';
import '../../theme/tokens/spacing_tokens.dart';

class QSkeleton extends StatefulWidget {
  const QSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = QRadii.cardRadius,
    this.shape = BoxShape.rectangle,
  });

  /// A circular avatar skeleton of [size].
  factory QSkeleton.avatar({double size = 32, Key? key}) =>
      QSkeleton(key: key, width: size, height: size, shape: BoxShape.circle);

  /// A single text line.
  factory QSkeleton.line({double? width, double height = 14, Key? key}) =>
      QSkeleton(key: key, width: width, height: height);

  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final BoxShape shape;

  @override
  State<QSkeleton> createState() => _QSkeletonState();
}

class _QSkeletonState extends State<QSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final bool reduced = Motion.reduced(context);

    if (reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }

    final Color base = tokens.colors.bgRaised;
    final Color highlight = tokens.colors.bgSurface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final double t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: reduced ? base : null,
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : widget.borderRadius,
            gradient: reduced
                ? null
                : LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: <Color>[base, highlight, base],
                    stops: <double>[
                      (t - 0.3).clamp(0.0, 1.0),
                      t.clamp(0.0, 1.0),
                      (t + 0.3).clamp(0.0, 1.0),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// A composite piece-card skeleton matching the real card's min-height.
class QPieceCardSkeleton extends StatelessWidget {
  const QPieceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: QSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              QSkeleton.avatar(),
              Gap.h3,
              QSkeleton.line(width: 120),
            ],
          ),
          Gap.v4,
          const QSkeleton(height: 20),
          Gap.v2,
          QSkeleton.line(width: 220),
        ],
      ),
    );
  }
}

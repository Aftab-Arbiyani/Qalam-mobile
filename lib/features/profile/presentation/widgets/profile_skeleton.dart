/// The profile loading skeleton (docs/41 §17) — a banner block, an overlapping
/// avatar circle, and a few text lines that mirror the real header's rhythm, so
/// the first paint doesn't jump when data arrives. Composed from the shared
/// [QSkeleton] primitives (shimmer honors reduced-motion).
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const AspectRatio(
          aspectRatio: 3,
          child: QSkeleton(
            height: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s4,
            0,
            QSpacing.s4,
            QSpacing.s4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Transform.translate(
                offset: const Offset(0, -44),
                child: QSkeleton.avatar(size: 88),
              ),
              QSkeleton.line(width: 180, height: 22),
              Gap.v2,
              QSkeleton.line(width: 120),
              Gap.v5,
              QSkeleton.line(width: double.infinity, height: 64),
              Gap.v4,
              QSkeleton.line(width: double.infinity),
              Gap.v2,
              QSkeleton.line(width: 240),
            ],
          ),
        ),
      ],
    );
  }
}

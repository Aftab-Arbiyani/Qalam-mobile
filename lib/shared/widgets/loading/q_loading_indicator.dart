/// Loading indicator (docs/41 §11.15). A calm accent spinner. Spinners appear
/// ONLY inside buttons or as a last-resort full-screen loader — content surfaces
/// use skeletons ([QSkeleton]) instead.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens/spacing_tokens.dart';

class QLoadingIndicator extends StatelessWidget {
  const QLoadingIndicator({super.key, this.size = 24, this.label});

  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Widget spinner = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
    if (label == null) return Center(child: spinner);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          spinner,
          Gap.v3,
          Text(label!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Pull-to-refresh (docs/41 §16). A themed [RefreshIndicator]. The refresh
/// action refetches the surface's Live/Content tier; existing content stays
/// visible while it runs.
library;

import 'package:flutter/material.dart';

class QRefresh extends StatelessWidget {
  const QRefresh({required this.onRefresh, required this.child, super.key});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: child,
    );
  }
}

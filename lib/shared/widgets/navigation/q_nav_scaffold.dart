/// Bottom-navigation shell scaffold (docs/41 §11.7, §24). Wraps a go_router
/// `StatefulNavigationShell` (one navigator per branch, so each tab keeps its own
/// stack + scroll). Re-tapping the active destination pops that branch to root.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/q_tokens.dart';
import 'q_nav_destination.dart';

class QNavScaffold extends StatelessWidget {
  const QNavScaffold({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<QNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: <Widget>[
          for (final QNavDestination d in destinations)
            NavigationDestination(
              icon: Icon(
                d.icon,
                color: d.accented ? tokens.colors.accent : null,
              ),
              selectedIcon: Icon(
                d.selectedIcon,
                color: d.accented ? tokens.colors.accent : null,
              ),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

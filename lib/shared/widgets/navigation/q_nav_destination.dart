/// A bottom-navigation destination (docs/41 §11.7). The Write destination is
/// [accented] — the primary compose CTA — so its icon is always the accent color.
library;

import 'package:flutter/widgets.dart';

class QNavDestination {
  const QNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.accented = false,
    this.badge,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool accented;

  /// An optional overlay (e.g. an unread-count [QBadge]) pinned to the icon's
  /// top-end corner — used by the Notifications destination (docs/41 §11.7, §37).
  final Widget? badge;
}

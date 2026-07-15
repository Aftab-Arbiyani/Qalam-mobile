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
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool accented;
}

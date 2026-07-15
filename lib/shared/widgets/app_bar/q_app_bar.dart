/// App bar (docs/41 §11 navigation). A themed [AppBar] — flat, canvas-colored,
/// start-aligned title. Chrome-recede on reading surfaces is handled by the
/// reading feature (M5), not here.
library;

import 'package:flutter/material.dart';

class QAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.bottom,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      bottom: bottom,
    );
  }
}

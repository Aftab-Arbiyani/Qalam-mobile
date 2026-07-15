/// Scaffold wrapper (docs/41 §27, §30). Applies safe-area handling and shows the
/// offline banner above the body. Feature pages use this instead of a bare
/// [Scaffold] so connectivity + safe-area behavior is consistent everywhere.
library;

import 'package:flutter/material.dart';

import 'connectivity_banner.dart';

class QScaffold extends StatelessWidget {
  const QScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showOfflineBanner = true,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showOfflineBanner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        top: appBar == null,
        bottom: false,
        child: Column(
          children: <Widget>[
            if (showOfflineBanner) const ConnectivityBanner(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

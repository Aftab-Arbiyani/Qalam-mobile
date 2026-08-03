/// The dark-launch state for a monetization surface (AF5).
///
/// **`QALAM_ENABLE_MONETIZATION` used to gate exactly one thing on mobile: whether the
/// Premium section appeared in the settings hub.** The `/billing/*` routes are registered
/// unconditionally, so every screen behind them stayed deep-linkable in a dark build and
/// rendered normally — issuing live `/monetization/*` requests for a platform the build
/// says is off (docs/48 §3.7, M5-4). Web's five pages all opened with this branch;
/// mobile's did not.
///
/// The routes are still registered, deliberately. Web's are too: gating the route table
/// would mean a dark build 404s a link that a flag flip makes valid, which is a worse
/// answer than a screen saying plainly that the feature has not shipped. The honest
/// state belongs on the screen.
///
/// One widget rather than five inline copies, because the five say nearly the same thing
/// and the failure mode is drift — one of them quietly implying the feature exists while
/// its neighbours say it does not.
library;

import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class MonetizationOffScreen extends StatelessWidget {
  const MonetizationOffScreen({
    required this.appBarTitle,
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final String appBarTitle;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: QAppBar(title: appBarTitle),
    body: QEmptyState(icon: icon, title: title, message: message),
  );
}

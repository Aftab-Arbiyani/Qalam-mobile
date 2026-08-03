/// Leaving an AI surface for the plan comparison (AF5 ↔ AF2).
///
/// An entitlement denial is the only blocked AI state whose remedy the writer controls,
/// so it is the only one that carries an action (see [AiErrorCopy.canUpgrade]).
///
/// Navigating to the **route** rather than reaching for monetization's own widgets is
/// what keeps this feature from importing another (docs/26 §4): the AI panel knows the
/// route, not the billing UI.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';

/// Close the sheet the writer is in, then open the plan comparison.
///
/// The router is captured **before** the pop: once the sheet's route is gone its
/// [BuildContext] is defunct, and `context.push` on it throws rather than navigating.
/// That ordering is the whole reason this is a function and not two lines at each call
/// site — it is easy to get backwards and it fails at runtime, not at compile time.
void openPlansFromSheet(BuildContext context) {
  final GoRouter router = GoRouter.of(context);
  Navigator.of(context).maybePop();
  router.push(Routes.billingPlans);
}

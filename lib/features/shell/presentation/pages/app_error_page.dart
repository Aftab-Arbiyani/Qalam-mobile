/// Dedicated error surfaces (docs/40 §10.2, docs/41 §32) for `/401`, `/403`, and
/// `/offline`. Renders the shared [QErrorView] (literary copy from the catalog, a
/// support reference, never a stack trace) with a single primary action back to
/// safe ground. Most error states are handled inline by screens or the auth
/// interceptor; these routes exist so a deep link into an error condition still
/// resolves to a real, calm screen.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/states/q_error_view.dart';

class AppErrorPage extends StatelessWidget {
  const AppErrorPage({
    required this.failure,
    required this.actionPath,
    super.key,
  });

  final Failure failure;

  /// Where the primary action sends the user (login for 401, feed otherwise).
  final String actionPath;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return QScaffold(
      appBar: const QAppBar(title: ''),
      body: QErrorView(
        failure: failure,
        onRetry: () => context.go(actionPath),
        retryLabel: actionPath == Routes.login
            ? l10n.actionSignIn
            : l10n.actionRetry,
      ),
    );
  }
}

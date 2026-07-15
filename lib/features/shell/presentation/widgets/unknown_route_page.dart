import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

/// Unknown-route surface (docs/40 §10) — a dead end that offers an exit.
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return QScaffold(
      appBar: QAppBar(title: l10n.appTitle),
      body: QEmptyState(
        icon: Icons.explore_off_outlined,
        title: l10n.unknownRouteTitle,
        message: l10n.unknownRouteBody,
        action: QButton(
          label: l10n.navFeed,
          variant: QButtonVariant.primary,
          onPressed: () => context.go(Routes.feed),
        ),
      ),
    );
  }
}

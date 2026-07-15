import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

/// Protected demo surface (docs/40 §11) — reaching it while anonymous (always, in
/// M1) redirects to the login placeholder with `returnTo`, proving the guard.
class SettingsPlaceholderPage extends StatelessWidget {
  const SettingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return QScaffold(
      appBar: QAppBar(title: l10n.settingsTitle),
      body: QEmptyState(
        icon: Icons.lock_outline,
        title: l10n.comingSoonLabel,
        message: l10n.settingsBody,
      ),
    );
  }
}

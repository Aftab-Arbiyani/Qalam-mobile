/// A shared placeholder surface for the M1 shell tabs (docs/40 §47). Real feature
/// screens replace these in M2–M10. Kept DRY so the five tabs don't duplicate
/// scaffold/empty-state boilerplate.
library;

import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    required this.title,
    required this.icon,
    required this.body,
    this.actions,
    super.key,
  });

  final String title;
  final IconData icon;
  final String body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return QScaffold(
      appBar: QAppBar(title: title, actions: actions),
      body: QEmptyState(icon: icon, title: l10n.comingSoonLabel, message: body),
    );
  }
}

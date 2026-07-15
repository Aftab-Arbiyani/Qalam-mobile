import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/feature_placeholder.dart';

/// Notifications tab — placeholder (real inbox ships in M9).
class NotificationsPlaceholderPage extends StatelessWidget {
  const NotificationsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return FeaturePlaceholder(
      title: l10n.navNotifications,
      icon: Icons.notifications_outlined,
      body: l10n.placeholderNotificationsBody,
    );
  }
}

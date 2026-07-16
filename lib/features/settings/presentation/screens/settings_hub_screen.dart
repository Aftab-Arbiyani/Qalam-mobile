/// Settings hub (docs/40 §10.2) at `/settings`. A navigation-only index that links
/// to the per-area settings screens. It is deliberately thin and owns no
/// feature state: each section screen lives in the feature that owns its data
/// (account → auth, appearance → reading, privacy → profile), so this hub imports
/// no other feature — it only pushes routes by name (the app's cross-feature
/// contract). Also surfaces the debug design-system gallery.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/settings/settings_tiles.dart';

class SettingsHubScreen extends ConsumerWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QScaffold(
      appBar: const QAppBar(title: 'Settings'),
      body: ListView(
        padding: QSpacing.pagePadding,
        children: <Widget>[
          QSettingsSection(
            children: <Widget>[
              QSettingsTile(
                icon: Icons.person_outline,
                title: 'Account',
                subtitle: 'Password, sign-in method, this device',
                onTap: () => context.push(Routes.settingsAccount),
              ),
              QSettingsTile(
                icon: Icons.palette_outlined,
                title: 'Appearance & reading',
                subtitle: 'Theme, text size, default feed',
                onTap: () => context.push(Routes.settingsAppearance),
              ),
              QSettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: 'Private account, what you show',
                onTap: () => context.push(Routes.settingsPrivacy),
              ),
              QSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Choose what you\'re notified about',
                onTap: () => context.push(Routes.settingsNotifications),
              ),
            ],
          ),
          Gap.v5,
          QSettingsSection(
            title: 'Developer',
            children: <Widget>[
              QSettingsTile(
                icon: Icons.widgets_outlined,
                title: 'Design gallery',
                subtitle: 'Component catalog',
                onTap: () => context.push(Routes.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

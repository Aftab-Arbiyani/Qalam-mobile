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
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/settings/settings_tiles.dart';

class SettingsHubScreen extends ConsumerWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool monetizationOn = ref.watch(appConfigProvider).enableMonetization;
    final bool collaborationOn = ref
        .watch(appConfigProvider)
        .enableCollaboration;
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
              QSettingsTile(
                icon: Icons.sd_storage_outlined,
                title: 'Storage & cache',
                subtitle: 'Manage on-device storage and offline data',
                onTap: () => context.push(Routes.settingsStorage),
              ),
            ],
          ),
          Gap.v5,
          QSettingsSection(
            title: 'Insights',
            children: <Widget>[
              QSettingsTile(
                icon: Icons.query_stats_outlined,
                title: 'Creator analytics',
                subtitle: 'Views, reads, followers and growth',
                onTap: () => context.push(Routes.creatorAnalytics),
              ),
              QSettingsTile(
                icon: Icons.auto_stories_outlined,
                title: 'Reading analytics',
                subtitle: 'Your streak, time read and history',
                onTap: () => context.push(Routes.readingAnalytics),
              ),
            ],
          ),
          if (collaborationOn) ...<Widget>[
            Gap.v5,
            QSettingsSection(
              title: 'Collaboration',
              children: <Widget>[
                // The inbound half of AF6 — the only entry point to `/me/invitations`,
                // which had none before (defect **R-1**, `docs/56` §2.4). The
                // story-scoped surfaces are reached from a story's overflow menu.
                QSettingsTile(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Story invitations',
                  subtitle: 'Invitations to collaborate on someone\'s story',
                  onTap: () => context.push(Routes.invitationsInbox),
                ),
              ],
            ),
          ],
          if (monetizationOn) ...<Widget>[
            Gap.v5,
            QSettingsSection(
              title: 'Premium',
              children: <Widget>[
                QSettingsTile(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Subscription & billing',
                  subtitle: 'Your plan, usage, credits and invoices',
                  onTap: () => context.push(Routes.billing),
                ),
              ],
            ),
          ],
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

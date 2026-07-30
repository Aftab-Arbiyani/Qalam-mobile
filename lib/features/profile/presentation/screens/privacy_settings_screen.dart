/// Privacy settings (docs/40 §19.3, §45) at `/settings/privacy`. Two kinds of
/// control:
///
/// - **Private account** — real, server-backed (`Profile.isPrivate` via `PATCH /me`).
///   Toggling it optimistically updates the live profile; a failure reverts + warns.
/// - **Content display** — reading-history / bookmarks tiles on your own profile.
///   These are LOCAL display gates: the frozen `v1` never exposes another user's
///   reading history or bookmarks, so there is nothing cross-user to enforce; the
///   toggles honestly control only what this device shows.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/preferences/app_preferences_controllers.dart';
import '../../../../shared/preferences/content_privacy.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/settings/settings_tiles.dart';
import '../../domain/entities/profile.dart';
import '../controllers/my_profile_controller.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Profile? profile = ref.watch(
      myProfileControllerProvider.select((v) => v.asData?.value),
    );
    final ContentPrivacy privacy = ref.watch(contentPrivacyControllerProvider);
    final ContentPrivacyController privacyController = ref.read(
      contentPrivacyControllerProvider.notifier,
    );

    return QScaffold(
      appBar: const QAppBar(title: 'Privacy'),
      body: ListView(
        padding: QSpacing.pagePadding,
        children: <Widget>[
          QSettingsSection(
            title: 'Account',
            children: <Widget>[
              QSettingsSwitchTile(
                icon: Icons.lock_outline,
                title: 'Private account',
                subtitle:
                    'New followers must request approval, and only followers '
                    'see your work.',
                value: profile?.isPrivate ?? false,
                onChanged: profile == null
                    ? null
                    : (bool value) => _setPrivate(context, ref, value),
              ),
            ],
          ),
          Gap.v5,
          QSettingsSection(
            title: 'What you show',
            children: <Widget>[
              QSettingsSwitchTile(
                icon: Icons.history,
                title: 'Show reading history count',
                subtitle: 'Display the number on your own profile.',
                value: privacy.showReadingHistory,
                onChanged: privacyController.setShowReadingHistory,
              ),
              QSettingsSwitchTile(
                icon: Icons.bookmark_outline,
                title: 'Show bookmarks count',
                subtitle: 'Display the number on your own profile.',
                value: privacy.showBookmarks,
                onChanged: privacyController.setShowBookmarks,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setPrivate(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final failure = await ref
        .read(myProfileControllerProvider.notifier)
        .setPrivate(value);
    if (failure != null && context.mounted) {
      QSnackbar.show(
        context,
        message: "Couldn't update privacy. Please try again.",
        variant: QSnackbarVariant.danger,
      );
    }
  }
}

/// Notification preferences (docs/40 §32, docs/41 §37) — the per-category toggle
/// screen at `/settings/notifications`. Reuses the shared settings tiles; each
/// switch flips optimistically via [NotificationPreferencesController]. The seven
/// categories are the only ones the backend exposes — there are no push/email
/// channel toggles yet (they arrive additively with the Phase-2 FCM seam).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';
import '../../../../shared/widgets/settings/settings_tiles.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/notification_preferences.dart';
import '../controllers/notification_preferences_controller.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<NotificationPreferences> state = ref.watch(
      notificationPreferencesControllerProvider,
    );

    return QScaffold(
      appBar: QAppBar(title: l10n.notificationPrefsTitle),
      body: state.when(
        loading: () => const _PrefsSkeleton(),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(
                  code: ErrorCodes.apiUnexpected,
                  message: error.toString(),
                ),
          onRetry: () =>
              ref.invalidate(notificationPreferencesControllerProvider),
        ),
        data: (NotificationPreferences prefs) => _PrefsList(prefs: prefs),
      ),
    );
  }
}

class _PrefsList extends ConsumerWidget {
  const _PrefsList({required this.prefs});

  final NotificationPreferences prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<_Row> rows = _rows(l10n);

    return ListView(
      padding: QSpacing.pagePadding,
      children: <Widget>[
        Text(
          l10n.notificationPrefsSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: QSpacing.s4),
        QSettingsSection(
          children: <Widget>[
            for (final _Row row in rows)
              QSettingsSwitchTile(
                title: row.title,
                subtitle: row.subtitle,
                value: row.category.valueOf(prefs),
                onChanged: (_) {
                  QHaptics.selection();
                  unawaited(
                    ref
                        .read(
                          notificationPreferencesControllerProvider.notifier,
                        )
                        .toggle(row.category),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  List<_Row> _rows(AppLocalizations l10n) => <_Row>[
    _Row(
      NotificationPreferenceCategory.follow,
      l10n.notificationPrefFollow,
      l10n.notificationPrefFollowDesc,
    ),
    _Row(
      NotificationPreferenceCategory.comment,
      l10n.notificationPrefComment,
      l10n.notificationPrefCommentDesc,
    ),
    _Row(
      NotificationPreferenceCategory.reply,
      l10n.notificationPrefReply,
      l10n.notificationPrefReplyDesc,
    ),
    _Row(
      NotificationPreferenceCategory.reaction,
      l10n.notificationPrefReaction,
      l10n.notificationPrefReactionDesc,
    ),
    _Row(
      NotificationPreferenceCategory.mention,
      l10n.notificationPrefMention,
      l10n.notificationPrefMentionDesc,
    ),
    _Row(
      NotificationPreferenceCategory.response,
      l10n.notificationPrefResponse,
      l10n.notificationPrefResponseDesc,
    ),
    _Row(
      NotificationPreferenceCategory.system,
      l10n.notificationPrefSystem,
      l10n.notificationPrefSystemDesc,
    ),
  ];
}

class _Row {
  const _Row(this.category, this.title, this.subtitle);

  final NotificationPreferenceCategory category;
  final String title;
  final String subtitle;
}

class _PrefsSkeleton extends StatelessWidget {
  const _PrefsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: QSpacing.pagePadding,
      children: <Widget>[
        for (int i = 0; i < 7; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: QSpacing.s3),
            child: QSkeleton(height: 24),
          ),
      ],
    );
  }
}

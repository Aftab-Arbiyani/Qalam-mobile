/// AI settings (`/settings/ai`) — B5 (`platfrom/docs/45` §4.10).
///
/// One control: whether this account uses AI at all.
///
/// **It is not a client-side hide.** The switch writes `user_settings.ai_enabled`, after
/// which the SERVER refuses this account's AI requests (`AI_DISABLED_BY_USER`) and
/// `GET /ai/features` reports every feature off. The affordances disappear because the
/// server says so — a UI-only hide is the defect class this project keeps finding
/// (W3c-1, and the seven unenforced premium codes in `docs/48` §5.2).
///
/// **It governs the writer, not the story.** A co-author who has AI on may still use it
/// on a story this writer co-authors.
///
/// **Separate from the `ai_personalization` consent, on purpose.** That consent
/// (`PUT /privacy/consent`) answers "may my work be used to improve AI"; this switch
/// answers "offer me the tools at all". A writer may want the assistant without the
/// training, or the reverse, so §4.10 requires they sit beside each other rather than
/// merged, and that the difference read plainly to a non-technical writer — which is
/// what the explanatory line below is for.
///
/// > The `ai_personalization` consent has NO client surface on either platform today
/// > (`GET/PUT /privacy/consent` ships unreached — verified 2026-08-08), so there is
/// > nothing here to sit next to yet. When it gains one it belongs on this screen, as a
/// > sibling row; the copy already draws the line so the two cannot be conflated.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/settings/settings_tiles.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/user_settings.dart';
import '../controllers/ai_preference_controller.dart';

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserSettings> settings = ref.watch(
      aiPreferenceControllerProvider,
    );

    return QScaffold(
      appBar: const QAppBar(title: 'AI'),
      body: settings.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(
                  code: ErrorCodes.apiUnexpected,
                  message: '$error',
                ),
          onRetry: () => ref.invalidate(aiPreferenceControllerProvider),
        ),
        data: (UserSettings value) => ListView(
          padding: QSpacing.pagePadding,
          children: <Widget>[
            QSettingsSection(
              children: <Widget>[
                QSettingsSwitchTile(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Use AI on this account',
                  subtitle:
                      'When this is off, Qalam stops offering you AI anywhere — no '
                      'writing assistant, no Craft Coach, and no AI search or '
                      'recommendations. Your writing is unaffected.',
                  value: value.aiEnabled,
                  onChanged: (bool next) => _set(context, ref, next),
                ),
              ],
            ),
            Gap.v4,
            // The distinction §4.10 requires, in a writer's words rather than the
            // codebase's: "offer me the tools" vs "train on my work". Without it the two
            // settings read as one, and a writer who wants the assistant but not the
            // training has no way to tell which switch does which.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: QSpacing.s2),
              child: Text(
                'This is separate from whether your work may be used to improve AI '
                'features — that is a privacy consent you control on its own.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _set(BuildContext context, WidgetRef ref, bool value) async {
    final bool saved = await ref
        .read(aiPreferenceControllerProvider.notifier)
        .setEnabled(value);
    if (!context.mounted || saved) return;
    // The controller has already rolled the switch back; say why, rather than letting
    // the writer believe AI is off while the server still serves it.
    QSnackbar.show(
      context,
      message: 'Couldn\'t save that. Your AI setting is unchanged.',
      variant: QSnackbarVariant.danger,
    );
  }
}

/// Account surface (docs/40 §14.6) — the M2 "you're signed in" screen mounted on
/// the `/me` tab. It is the session/account surface, NOT the profile feature (pen
/// name, bio, pieces, follow) — M3 builds that. It shows the signed-in identity,
/// the email-verification banner, and the logout / sign-out-everywhere actions, and
/// preserves the M1 theme-toggle + design-gallery affordances.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/session/current_user.dart';
import '../../../../core/session/current_user_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/theme_mode_controller.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/feedback/q_dialog.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../controllers/account_controller.dart';
import '../widgets/email_verification_banner.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _confirmSignOutEverywhere(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await QDialog.confirm(
      context,
      title: l10n.signOutConfirmTitle,
      message: l10n.signOutConfirmBody,
      confirmLabel: l10n.actionSignOutEverywhere,
      cancelLabel: l10n.actionCancel,
      destructive: true,
    );
    if (confirmed) {
      await ref
          .read(accountControllerProvider.notifier)
          .signOut(everywhere: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final CurrentUser? user = ref.watch(currentUserControllerProvider);
    final AccountState account = ref.watch(accountControllerProvider);
    final ThemeMode mode = ref.watch(themeModeControllerProvider);

    return QScaffold(
      appBar: QAppBar(
        title: l10n.navProfile,
        actions: <Widget>[
          IconButton(
            icon: Icon(_themeIcon(mode)),
            tooltip: 'Theme: ${mode.name}',
            onPressed: () => ref
                .read(themeModeControllerProvider.notifier)
                .set(_nextTheme(mode)),
          ),
          IconButton(
            icon: const Icon(Icons.widgets_outlined),
            tooltip: l10n.galleryTitle,
            onPressed: () => context.push(Routes.gallery),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: QSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const EmailVerificationBanner(),
            Gap.v4,
            CircleAvatar(
              radius: 40,
              backgroundColor: tokens.colors.bgRaised,
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: tokens.colors.textSecondary,
              ),
            ),
            Gap.v4,
            Text(
              user != null
                  ? l10n.accountSignedInAs(user.username)
                  : l10n.accountSignedIn,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (user != null) ...<Widget>[
              Gap.v1,
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ],
            Gap.v3,
            Text(
              l10n.placeholderProfileBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.colors.textMuted,
              ),
            ),
            Gap.v6,
            QButton(
              label: l10n.actionSignOut,
              size: QButtonSize.lg,
              block: true,
              loading: account.signingOut,
              onPressed: () =>
                  ref.read(accountControllerProvider.notifier).signOut(),
            ),
            Gap.v3,
            QButton(
              label: l10n.actionSignOutEverywhere,
              variant: QButtonVariant.ghost,
              block: true,
              onPressed: account.signingOut
                  ? null
                  : () => _confirmSignOutEverywhere(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto,
    ThemeMode.light => Icons.light_mode,
    ThemeMode.dark => Icons.dark_mode,
  };

  ThemeMode _nextTheme(ThemeMode mode) => switch (mode) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  };
}

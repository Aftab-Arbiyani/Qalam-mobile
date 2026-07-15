/// Account settings (docs/40 §14.6) at `/settings/account`. The session/credential
/// surface: the signed-in identity, how this session was authenticated (the
/// connected-accounts stand-in, since `v1` exposes none), a "this device" card
/// (app version, device, remember-me — the sessions-list stand-in), change
/// password, and the sign-out actions. Logout reuses the existing
/// [AccountController]; change-email + delete-account are intentionally absent
/// (no frozen-`v1` support — documented gaps, docs/40 §45).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/session/current_user.dart';
import '../../../../core/session/current_user_controller.dart';
import '../../../../core/session/sign_in_method.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/feedback/q_dialog.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/settings/settings_tiles.dart';
import '../controllers/account_controller.dart';
import '../controllers/account_info_controller.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CurrentUser? user = ref.watch(currentUserControllerProvider);
    final SignInMethod method = ref.watch(signInMethodProvider);
    final AsyncValue<DeviceSessionInfo> device = ref.watch(
      deviceSessionInfoProvider,
    );
    final AccountState account = ref.watch(accountControllerProvider);

    return QScaffold(
      appBar: const QAppBar(title: 'Account'),
      body: ListView(
        padding: QSpacing.pagePadding,
        children: <Widget>[
          QSettingsSection(
            title: 'Account',
            children: <Widget>[
              QSettingsTile(
                icon: Icons.alternate_email,
                title: user?.username ?? 'Signed in',
                subtitle: user?.email,
              ),
              QSettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Sign-in method',
                subtitle: _methodLabel(method),
              ),
              QSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change password',
                onTap: () => context.push(Routes.settingsAccountPassword),
              ),
            ],
          ),
          Gap.v5,
          QSettingsSection(
            title: 'This device',
            children: <Widget>[
              QSettingsTile(
                icon: Icons.info_outline,
                title: 'App version',
                subtitle: device.asData?.value.appVersion ?? '…',
              ),
              QSettingsTile(
                icon: Icons.smartphone_outlined,
                title: 'Device',
                subtitle: device.asData?.value.deviceLabel ?? '…',
              ),
              QSettingsSwitchTile(
                icon: Icons.autorenew,
                title: 'Stay signed in',
                subtitle: 'Restore this session automatically on next launch.',
                value: device.asData?.value.rememberMe ?? false,
                onChanged: null,
              ),
            ],
          ),
          Gap.v5,
          QSettingsSection(
            children: <Widget>[
              QSettingsTile(
                icon: Icons.logout,
                title: l10n.actionSignOut,
                onTap: account.signingOut
                    ? null
                    : () => ref
                          .read(accountControllerProvider.notifier)
                          .signOut(),
              ),
              QSettingsTile(
                icon: Icons.devices_other_outlined,
                title: l10n.actionSignOutEverywhere,
                destructive: true,
                onTap: account.signingOut
                    ? null
                    : () => _confirmSignOutEverywhere(context, ref, l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _methodLabel(SignInMethod method) => switch (method) {
    SignInMethod.password => 'Email & password',
    SignInMethod.google => 'Google',
    SignInMethod.unknown => '—',
  };

  Future<void> _confirmSignOutEverywhere(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
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
}

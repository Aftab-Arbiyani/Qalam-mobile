/// Reset-password screen (docs/40 §14.1, docs/41 §29). Reached via the reset link
/// `/auth/reset-password?token=…`. Collects a new password (with a strength meter)
/// and a confirmation, then submits with the token. On success it shows a calm
/// "password updated" confirmation and routes to login (all sessions were revoked).
/// A missing token short-circuits to an invalid-link message.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../controllers/reset_password_form_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_l10n.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/q_password_field.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({this.token, super.key});

  final String? token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResetPasswordFormState state = ref.watch(
      resetPasswordFormControllerProvider,
    );
    final ResetPasswordFormController controller = ref.read(
      resetPasswordFormControllerProvider.notifier,
    );
    final String? token = this.token;

    if (state.success) {
      return AuthScaffold(
        title: l10n.authResetDoneTitle,
        subtitle: l10n.authResetDoneBody,
        children: <Widget>[
          QButton(
            label: l10n.actionSignIn,
            variant: QButtonVariant.primary,
            size: QButtonSize.lg,
            block: true,
            onPressed: () => context.go(Routes.login),
          ),
        ],
      );
    }

    if (token == null || token.isEmpty) {
      return AuthScaffold(
        title: l10n.authResetTitle,
        subtitle: l10n.validationTokenInvalid,
        children: <Widget>[
          QButton(
            label: l10n.authBackToLogin,
            variant: QButtonVariant.primary,
            size: QButtonSize.lg,
            block: true,
            onPressed: () => context.go(Routes.login),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: l10n.authResetTitle,
      subtitle: l10n.authResetSubtitle,
      children: <Widget>[
        if (state.formError != null) ...<Widget>[
          AuthErrorBanner(failure: state.formError!),
          Gap.v4,
        ],
        QPasswordField(
          label: l10n.fieldNewPasswordLabel,
          onChanged: controller.changePassword,
          onEditingBlur: controller.blurPassword,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.newPassword],
          errorText: authFieldErrorText(l10n, state.password.error),
        ),
        Gap.v2,
        PasswordStrengthMeter(password: state.password.value),
        Gap.v4,
        QPasswordField(
          label: l10n.fieldConfirmPasswordLabel,
          onChanged: controller.changeConfirm,
          onEditingBlur: controller.blurConfirm,
          onSubmitted: (_) => controller.submit(token: token),
          autofillHints: const <String>[AutofillHints.newPassword],
          errorText: authFieldErrorText(l10n, state.confirm.error),
        ),
        Gap.v5,
        QButton(
          label: l10n.actionResetPassword,
          variant: QButtonVariant.primary,
          size: QButtonSize.lg,
          block: true,
          loading: state.submitting,
          onPressed: () => controller.submit(token: token),
        ),
      ],
    );
  }
}

/// Register screen (docs/40 §14.3, §11.5, docs/41 §29). Email, permanent username
/// (with the "choose with care" note — never an edit path), and a password with a
/// live strength meter. On success the session is established and the screen routes
/// to the verify-email corridor (verification is a state, not a wall).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../controllers/register_form_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_l10n.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/q_password_field.dart';
import '../widgets/social_auth_buttons.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onEmailBlur);
    _usernameFocus.addListener(_onUsernameBlur);
  }

  void _onEmailBlur() {
    if (!_emailFocus.hasFocus) {
      ref.read(registerFormControllerProvider.notifier).blurEmail();
    }
  }

  void _onUsernameBlur() {
    if (!_usernameFocus.hasFocus) {
      ref.read(registerFormControllerProvider.notifier).blurUsername();
    }
  }

  @override
  void dispose() {
    _emailFocus
      ..removeListener(_onEmailBlur)
      ..dispose();
    _usernameFocus
      ..removeListener(_onUsernameBlur)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final RegisterFormState state = ref.watch(registerFormControllerProvider);
    final RegisterFormController controller = ref.read(
      registerFormControllerProvider.notifier,
    );

    ref.listen(
      registerFormControllerProvider.select((RegisterFormState s) => s.success),
      (_, bool success) {
        if (success) context.go(Routes.verifyEmail);
      },
    );

    return AuthScaffold(
      title: l10n.authRegisterTitle,
      subtitle: l10n.authRegisterSubtitle,
      children: <Widget>[
        if (state.formError != null) ...<Widget>[
          AuthErrorBanner(failure: state.formError!),
          Gap.v4,
        ],
        QTextField(
          label: l10n.fieldEmailLabel,
          hint: l10n.fieldEmailHint,
          focusNode: _emailFocus,
          onChanged: controller.changeEmail,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          errorText: authFieldErrorText(l10n, state.email.error),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.email],
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        Gap.v4,
        QTextField(
          label: l10n.fieldUsernameLabel,
          hint: l10n.authUsernameHint,
          focusNode: _usernameFocus,
          onChanged: controller.changeUsername,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          errorText: authFieldErrorText(l10n, state.username.error),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.newUsername],
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        Gap.v1,
        Row(
          children: <Widget>[
            Icon(Icons.lock_outline, size: 14, color: tokens.colors.textMuted),
            const SizedBox(width: QSpacing.s1),
            Flexible(
              child: Text(
                l10n.authUsernamePermanent,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.colors.textMuted,
                ),
              ),
            ),
          ],
        ),
        Gap.v4,
        QPasswordField(
          label: l10n.fieldPasswordLabel,
          onChanged: controller.changePassword,
          onEditingBlur: controller.blurPassword,
          onSubmitted: (_) => controller.submit(),
          autofillHints: const <String>[AutofillHints.newPassword],
          errorText: authFieldErrorText(l10n, state.password.error),
        ),
        Gap.v2,
        PasswordStrengthMeter(password: state.password.value),
        Gap.v5,
        QButton(
          label: l10n.actionCreateAccount,
          variant: QButtonVariant.primary,
          size: QButtonSize.lg,
          block: true,
          loading: state.submitting,
          onPressed: controller.submit,
        ),
        Gap.v5,
        SocialAuthButtons(onSuccess: () => context.go(Routes.feed)),
        Gap.v5,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              l10n.authHaveAccount,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.colors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(Routes.login),
              child: Text(l10n.authSignInLink),
            ),
          ],
        ),
      ],
    );
  }
}

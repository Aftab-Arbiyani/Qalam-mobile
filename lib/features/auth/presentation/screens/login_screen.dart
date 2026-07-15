/// Login screen (docs/40 §14.3, docs/41 §29). Email + password with reactive
/// validation, remember-me, social sign-in, and a form-level error banner. On
/// success it routes to the captured `returnTo` (open-redirect-safe) — the session
/// is already established by the form controller.
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
import '../controllers/login_form_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_l10n.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/q_password_field.dart';
import '../widgets/social_auth_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({this.returnTo, super.key});

  final String? returnTo;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onEmailFocusChange);
  }

  void _onEmailFocusChange() {
    if (!_emailFocus.hasFocus) {
      ref.read(loginFormControllerProvider.notifier).blurEmail();
    }
  }

  @override
  void dispose() {
    _emailFocus
      ..removeListener(_onEmailFocusChange)
      ..dispose();
    super.dispose();
  }

  void _goHome() => context.go(Routes.safeReturnTo(widget.returnTo));

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final LoginFormState state = ref.watch(loginFormControllerProvider);
    final LoginFormController controller = ref.read(
      loginFormControllerProvider.notifier,
    );

    ref.listen(
      loginFormControllerProvider.select((LoginFormState s) => s.success),
      (_, bool success) {
        if (success) _goHome();
      },
    );

    return AuthScaffold(
      title: l10n.authLoginTitle,
      subtitle: l10n.authLoginSubtitle,
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
          autofillHints: const <String>[
            AutofillHints.username,
            AutofillHints.email,
          ],
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        Gap.v4,
        QPasswordField(
          label: l10n.fieldPasswordLabel,
          onChanged: controller.changePassword,
          onEditingBlur: controller.blurPassword,
          onSubmitted: (_) => controller.submit(),
          errorText: authFieldErrorText(l10n, state.password.error),
        ),
        Gap.v3,
        Row(
          children: <Widget>[
            Expanded(
              child: _RememberMe(
                value: state.rememberMe,
                onChanged: controller.setRememberMe,
                label: l10n.authRememberMe,
              ),
            ),
            TextButton(
              onPressed: () => context.push(Routes.forgotPassword),
              child: Text(l10n.actionForgotPassword),
            ),
          ],
        ),
        Gap.v4,
        QButton(
          label: l10n.actionSignIn,
          variant: QButtonVariant.primary,
          size: QButtonSize.lg,
          block: true,
          loading: state.submitting,
          onPressed: controller.submit,
        ),
        Gap.v5,
        SocialAuthButtons(onSuccess: _goHome),
        Gap.v5,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              l10n.authNoAccount,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.colors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () => context.push(Routes.register),
              child: Text(l10n.authCreateOne),
            ),
          ],
        ),
      ],
    );
  }
}

/// A 44px-tall, tappable remember-me control (checkbox + label) with merged
/// semantics so screen readers announce it as one checkbox.
class _RememberMe extends StatelessWidget {
  const _RememberMe({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: QSpacing.s2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Checkbox(
                value: value,
                onChanged: (bool? v) => onChanged(v ?? false),
              ),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

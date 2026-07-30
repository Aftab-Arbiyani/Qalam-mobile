/// Forgot-password screen (docs/40 §14.1, docs/41 §29, §33). Collects an email and
/// requests a reset link; on success it swaps to a calm, enumeration-safe "check
/// your inbox" confirmation regardless of whether the address had an account.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../controllers/forgot_password_form_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_l10n.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onEmailBlur);
  }

  void _onEmailBlur() {
    if (!_emailFocus.hasFocus) {
      ref.read(forgotPasswordFormControllerProvider.notifier).blurEmail();
    }
  }

  @override
  void dispose() {
    _emailFocus
      ..removeListener(_onEmailBlur)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ForgotPasswordFormState state = ref.watch(
      forgotPasswordFormControllerProvider,
    );
    final ForgotPasswordFormController controller = ref.read(
      forgotPasswordFormControllerProvider.notifier,
    );

    if (state.sent) {
      return AuthScaffold(
        title: l10n.authForgotSentTitle,
        subtitle: l10n.authForgotSentBody(state.email.value.trim()),
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
      title: l10n.authForgotTitle,
      subtitle: l10n.authForgotSubtitle,
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
          onSubmitted: (_) => controller.submit(),
          errorText: authFieldErrorText(l10n, state.email.error),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.email],
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        Gap.v5,
        QButton(
          label: l10n.actionSendResetLink,
          variant: QButtonVariant.primary,
          size: QButtonSize.lg,
          block: true,
          loading: state.submitting,
          onPressed: controller.submit,
        ),
        Gap.v4,
        Center(
          child: TextButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.login),
            child: Text(l10n.authBackToLogin),
          ),
        ),
      ],
    );
  }
}

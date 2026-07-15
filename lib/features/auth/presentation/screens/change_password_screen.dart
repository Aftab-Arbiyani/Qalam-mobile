/// Change password (docs/40 §14.1, docs/41 §29) at `/settings/account/password`.
/// Current + new + confirm, with live validation and field-mapped server errors.
/// On success the session is re-established with the rotated tokens (handled in
/// the controller) so the user stays signed in; this screen just shows a
/// confirmation and pops. Presentation only — no I/O.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/limits.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChangePasswordState state = ref.watch(
      changePasswordControllerProvider,
    );
    final ChangePasswordController controller = ref.read(
      changePasswordControllerProvider.notifier,
    );

    ref.listen<ChangePasswordState>(changePasswordControllerProvider, (
      ChangePasswordState? previous,
      ChangePasswordState next,
    ) {
      if (next.success && !(previous?.success ?? false)) {
        QSnackbar.show(context, message: 'Password changed.');
        Navigator.of(context).maybePop();
      }
    });

    return QScaffold(
      appBar: const QAppBar(title: 'Change password'),
      body: ListView(
        padding: QSpacing.pagePadding,
        children: <Widget>[
          if (state.formError != null) ...<Widget>[_ErrorBanner(), Gap.v4],
          QTextField(
            label: 'Current password',
            obscureText: true,
            errorText: _copy(state.currentError),
            onChanged: controller.changeCurrent,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.password],
          ),
          Gap.v4,
          QTextField(
            label: 'New password',
            obscureText: true,
            errorText: _copy(state.newError),
            onChanged: controller.changeNew,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.newPassword],
          ),
          Gap.v4,
          QTextField(
            label: 'Confirm new password',
            obscureText: true,
            errorText: _copy(state.confirmError),
            onChanged: controller.changeConfirm,
            autofillHints: const <String>[AutofillHints.newPassword],
          ),
          Gap.v6,
          QButton(
            label: 'Update password',
            variant: QButtonVariant.primary,
            size: QButtonSize.lg,
            block: true,
            loading: state.submitting,
            onPressed: controller.submit,
          ),
        ],
      ),
    );
  }

  String? _copy(ChangePasswordFieldError? error) => switch (error) {
    null => null,
    ChangePasswordFieldError.required => 'Required.',
    ChangePasswordFieldError.tooShort =>
      'Use at least ${Limits.passwordMin} characters.',
    ChangePasswordFieldError.tooLong =>
      'Use at most ${Limits.passwordMax} characters.',
    ChangePasswordFieldError.mismatch => "Passwords don't match.",
    ChangePasswordFieldError.currentInvalid => 'That password is incorrect.',
    ChangePasswordFieldError.weak => 'Choose a stronger password.',
  };
}

class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(QSpacing.s3),
      decoration: BoxDecoration(
        color: tokens.colors.dangerBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline, size: 18, color: tokens.colors.dangerText),
          Gap.h2,
          Expanded(
            child: Text(
              "Couldn't change your password. Please try again.",
              style: TextStyle(color: tokens.colors.dangerText),
            ),
          ),
        ],
      ),
    );
  }
}

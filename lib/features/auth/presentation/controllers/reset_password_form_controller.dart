/// Reset-password form controller (docs/40 §14.1, docs/41 §29). Sets a new
/// password from a reset token (carried in the route). Confirm-password is a
/// client-only guard. On success the backend has revoked every session, so the
/// screen routes to login to re-authenticate. An invalid/expired token surfaces as
/// a form-level banner (there is no visible token field).
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../providers/auth_providers.dart';
import 'auth_error_mapping.dart';
import 'auth_validators.dart';
import 'field_state.dart';

part 'reset_password_form_controller.freezed.dart';
part 'reset_password_form_controller.g.dart';

@freezed
abstract class ResetPasswordFormState with _$ResetPasswordFormState {
  const factory ResetPasswordFormState({
    @Default(FieldState()) FieldState password,
    @Default(FieldState()) FieldState confirm,
    @Default(false) bool submitting,
    @Default(false) bool success,
    Failure? formError,
  }) = _ResetPasswordFormState;

  const ResetPasswordFormState._();
}

@riverpod
class ResetPasswordFormController extends _$ResetPasswordFormController {
  @override
  ResetPasswordFormState build() => const ResetPasswordFormState();

  void changePassword(String value) => state = state.copyWith(
    password: state.password.copyWith(
      value: value,
      error: state.password.touched
          ? AuthValidators.password(value)
          : state.password.error,
    ),
    // Re-check the confirm field against the new password if it was touched.
    confirm: state.confirm.touched
        ? state.confirm.copyWith(
            error: AuthValidators.confirmPassword(value, state.confirm.value),
          )
        : state.confirm,
    formError: null,
  );

  void blurPassword() => state = state.copyWith(
    password: state.password.copyWith(
      touched: true,
      error: AuthValidators.password(state.password.value),
    ),
  );

  void changeConfirm(String value) => state = state.copyWith(
    confirm: state.confirm.copyWith(
      value: value,
      error: state.confirm.touched
          ? AuthValidators.confirmPassword(state.password.value, value)
          : state.confirm.error,
    ),
    formError: null,
  );

  void blurConfirm() => state = state.copyWith(
    confirm: state.confirm.copyWith(
      touched: true,
      error: AuthValidators.confirmPassword(
        state.password.value,
        state.confirm.value,
      ),
    ),
  );

  Future<void> submit({required String token}) async {
    if (state.submitting) return;
    final FieldState password = state.password.copyWith(
      touched: true,
      error: AuthValidators.password(state.password.value),
    );
    final FieldState confirm = state.confirm.copyWith(
      touched: true,
      error: AuthValidators.confirmPassword(
        password.value,
        state.confirm.value,
      ),
    );
    state = state.copyWith(
      password: password,
      confirm: confirm,
      formError: null,
    );
    if (password.hasError || confirm.hasError) return;

    state = state.copyWith(submitting: true);
    final Result<Unit> result = await ref
        .read(resetPasswordUseCaseProvider)
        .call(token: token, newPassword: password.value);

    switch (result) {
      case Ok<Unit>():
        state = state.copyWith(submitting: false, success: true);
      case Err<Unit>(:final Failure failure):
        final AuthSubmitError mapped = mapFailureToAuthErrors(failure);
        final AuthFieldError? pwError =
            mapped.fieldErrors[AuthFieldKey.password];
        state = state.copyWith(
          submitting: false,
          password: pwError != null
              ? state.password.copyWith(error: pwError, touched: true)
              : state.password,
          // Token errors (and anything non-field) become the banner.
          formError: pwError == null ? failure : null,
        );
    }
  }
}

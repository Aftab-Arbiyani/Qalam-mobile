/// Forgot-password form controller (docs/40 §14.1, docs/41 §29). Requests a reset
/// link; success is enumeration-safe (the backend always returns 202). The screen
/// swaps to a calm "check your inbox" confirmation on [ForgotPasswordFormState.sent]
/// regardless of whether the address had an account.
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

part 'forgot_password_form_controller.freezed.dart';
part 'forgot_password_form_controller.g.dart';

@freezed
abstract class ForgotPasswordFormState with _$ForgotPasswordFormState {
  const factory ForgotPasswordFormState({
    @Default(FieldState()) FieldState email,
    @Default(false) bool submitting,
    @Default(false) bool sent,
    Failure? formError,
  }) = _ForgotPasswordFormState;

  const ForgotPasswordFormState._();
}

@riverpod
class ForgotPasswordFormController extends _$ForgotPasswordFormController {
  @override
  ForgotPasswordFormState build() => const ForgotPasswordFormState();

  void changeEmail(String value) => state = state.copyWith(
    email: state.email.copyWith(
      value: value,
      error: state.email.touched
          ? AuthValidators.email(value)
          : state.email.error,
    ),
    formError: null,
  );

  void blurEmail() => state = state.copyWith(
    email: state.email.copyWith(
      touched: true,
      error: AuthValidators.email(state.email.value),
    ),
  );

  Future<void> submit() async {
    if (state.submitting) return;
    final FieldState email = state.email.copyWith(
      touched: true,
      error: AuthValidators.email(state.email.value),
    );
    state = state.copyWith(email: email, formError: null);
    if (email.hasError) return;

    state = state.copyWith(submitting: true);
    final Result<Unit> result = await ref
        .read(requestPasswordResetUseCaseProvider)
        .call(email: email.value.trim());

    switch (result) {
      case Ok<Unit>():
        state = state.copyWith(submitting: false, sent: true);
      case Err<Unit>(:final Failure failure):
        final AuthSubmitError mapped = mapFailureToAuthErrors(failure);
        state = state.copyWith(
          submitting: false,
          formError: mapped.banner ?? failure,
        );
    }
  }
}

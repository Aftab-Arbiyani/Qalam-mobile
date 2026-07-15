/// Login form controller (docs/40 §14.3, docs/41 §29). Owns the login form state
/// and the submit flow: validate (on blur, then on change after the first error),
/// call the sign-in use case, and on success establish the session via the core
/// session notifier. It performs no I/O itself and no navigation — the screen
/// watches [LoginFormState.success] and routes.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/session/sign_in_method.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_result.dart';
import '../providers/auth_providers.dart';
import 'auth_error_mapping.dart';
import 'auth_validators.dart';
import 'field_state.dart';

part 'login_form_controller.freezed.dart';
part 'login_form_controller.g.dart';

@freezed
abstract class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default(FieldState()) FieldState email,
    @Default(FieldState()) FieldState password,
    @Default(true) bool rememberMe,
    @Default(false) bool submitting,
    @Default(false) bool success,
    Failure? formError,
  }) = _LoginFormState;

  const LoginFormState._();
}

@riverpod
class LoginFormController extends _$LoginFormController {
  @override
  LoginFormState build() => const LoginFormState();

  void changeEmail(String value) => state = state.copyWith(
    email: _revalidate(state.email, value, AuthValidators.email),
    formError: null,
  );

  void blurEmail() =>
      state = state.copyWith(email: _touch(state.email, AuthValidators.email));

  void changePassword(String value) => state = state.copyWith(
    password: _revalidate(
      state.password,
      value,
      AuthValidators.presentPassword,
    ),
    formError: null,
  );

  void blurPassword() => state = state.copyWith(
    password: _touch(state.password, AuthValidators.presentPassword),
  );

  void setRememberMe(bool value) => state = state.copyWith(rememberMe: value);

  Future<void> submit() async {
    if (state.submitting) return;
    final FieldState email = _touch(state.email, AuthValidators.email);
    final FieldState password = _touch(
      state.password,
      AuthValidators.presentPassword,
    );
    state = state.copyWith(email: email, password: password, formError: null);
    if (email.hasError || password.hasError) return;

    state = state.copyWith(submitting: true);
    final Result<AuthResult> result = await ref
        .read(signInUseCaseProvider)
        .call(email: email.value.trim(), password: password.value);

    switch (result) {
      case Ok(:final AuthResult value):
        await ref
            .read(sessionControllerProvider.notifier)
            .establish(
              user: value.user,
              accessToken: value.accessToken,
              refreshToken: value.refreshToken,
              rememberMe: state.rememberMe,
              signInMethod: SignInMethod.password,
            );
        state = state.copyWith(submitting: false, success: true);
      case Err(:final Failure failure):
        _applyFailure(failure);
    }
  }

  void _applyFailure(Failure failure) {
    final AuthSubmitError mapped = mapFailureToAuthErrors(failure);
    state = state.copyWith(
      submitting: false,
      email: _withServerError(state.email, mapped, AuthFieldKey.email),
      password: _withServerError(state.password, mapped, AuthFieldKey.password),
      formError: mapped.banner,
    );
  }

  FieldState _revalidate(
    FieldState f,
    String value,
    AuthFieldError? Function(String) v,
  ) => f.copyWith(value: value, error: f.touched ? v(value) : f.error);

  FieldState _touch(FieldState f, AuthFieldError? Function(String) v) =>
      f.copyWith(touched: true, error: v(f.value));

  FieldState _withServerError(
    FieldState f,
    AuthSubmitError mapped,
    String key,
  ) => mapped.fieldErrors.containsKey(key)
      ? f.copyWith(error: mapped.fieldErrors[key], touched: true)
      : f;
}

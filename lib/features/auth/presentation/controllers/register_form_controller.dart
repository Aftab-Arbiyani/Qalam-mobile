/// Register form controller (docs/40 §14.3, §11.5, docs/41 §29). One logical form
/// (even though the screen presents the permanent-username confirmation as a
/// deliberate step). Validates email / username / password client-side, submits
/// once, and on success establishes the session — the screen then routes to the
/// verify-email corridor (verification is a state, not a wall).
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

part 'register_form_controller.freezed.dart';
part 'register_form_controller.g.dart';

@freezed
abstract class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState({
    @Default(FieldState()) FieldState email,
    @Default(FieldState()) FieldState username,
    @Default(FieldState()) FieldState password,
    @Default(false) bool submitting,
    @Default(false) bool success,
    Failure? formError,
  }) = _RegisterFormState;

  const RegisterFormState._();
}

@riverpod
class RegisterFormController extends _$RegisterFormController {
  @override
  RegisterFormState build() => const RegisterFormState();

  void changeEmail(String value) => state = state.copyWith(
    email: _revalidate(state.email, value, AuthValidators.email),
    formError: null,
  );

  void blurEmail() =>
      state = state.copyWith(email: _touch(state.email, AuthValidators.email));

  void changeUsername(String value) => state = state.copyWith(
    username: _revalidate(state.username, value, AuthValidators.username),
    formError: null,
  );

  void blurUsername() => state = state.copyWith(
    username: _touch(state.username, AuthValidators.username),
  );

  void changePassword(String value) => state = state.copyWith(
    password: _revalidate(state.password, value, AuthValidators.password),
    formError: null,
  );

  void blurPassword() => state = state.copyWith(
    password: _touch(state.password, AuthValidators.password),
  );

  Future<void> submit() async {
    if (state.submitting) return;
    final FieldState email = _touch(state.email, AuthValidators.email);
    final FieldState username = _touch(state.username, AuthValidators.username);
    final FieldState password = _touch(state.password, AuthValidators.password);
    state = state.copyWith(
      email: email,
      username: username,
      password: password,
      formError: null,
    );
    if (email.hasError || username.hasError || password.hasError) return;

    state = state.copyWith(submitting: true);
    final Result<AuthResult> result = await ref
        .read(registerAccountUseCaseProvider)
        .call(
          email: email.value.trim(),
          username: username.value.trim(),
          password: password.value,
        );

    switch (result) {
      case Ok(:final AuthResult value):
        await ref
            .read(sessionControllerProvider.notifier)
            .establish(
              user: value.user,
              accessToken: value.accessToken,
              refreshToken: value.refreshToken,
              rememberMe: true,
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
      username: _withServerError(state.username, mapped, AuthFieldKey.username),
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

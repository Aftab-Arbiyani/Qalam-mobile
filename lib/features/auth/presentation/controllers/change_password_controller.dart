/// Change-password form controller (docs/40 §14.1, §20, docs/41 §29). Validates
/// current / new / confirm (client-side, mirroring the shared limits), submits via
/// the change-password use case, and on success re-establishes the session with
/// the freshly-rotated tokens the server returns — so the user stays signed in on
/// THIS device even though every session was revoked. Field-specific server codes
/// (`AUTH_CURRENT_PASSWORD_INVALID`, `AUTH_PASSWORD_WEAK`) land on their field;
/// anything else becomes a form banner. No I/O or navigation here.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/domain/limits.dart';
import '../../domain/entities/auth_result.dart';
import '../providers/auth_providers.dart';

part 'change_password_controller.freezed.dart';
part 'change_password_controller.g.dart';

/// The finite set of change-password field problems the screen resolves to copy.
enum ChangePasswordFieldError {
  required,
  tooShort,
  tooLong,
  mismatch,
  currentInvalid,
  weak,
}

@freezed
abstract class ChangePasswordState with _$ChangePasswordState {
  const factory ChangePasswordState({
    @Default('') String currentPassword,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    ChangePasswordFieldError? currentError,
    ChangePasswordFieldError? newError,
    ChangePasswordFieldError? confirmError,
    @Default(false) bool submitting,
    @Default(false) bool success,
    Failure? formError,
  }) = _ChangePasswordState;

  const ChangePasswordState._();
}

@riverpod
class ChangePasswordController extends _$ChangePasswordController {
  @override
  ChangePasswordState build() => const ChangePasswordState();

  void changeCurrent(String value) => state = state.copyWith(
    currentPassword: value,
    currentError: null,
    formError: null,
  );

  void changeNew(String value) => state = state.copyWith(
    newPassword: value,
    newError: state.newError == null ? null : _validateNew(value),
    formError: null,
  );

  void changeConfirm(String value) => state = state.copyWith(
    confirmPassword: value,
    confirmError: state.confirmError == null
        ? null
        : _validateConfirm(state.newPassword, value),
    formError: null,
  );

  Future<void> submit() async {
    if (state.submitting) return;
    final ChangePasswordFieldError? currentErr = state.currentPassword.isEmpty
        ? ChangePasswordFieldError.required
        : null;
    final ChangePasswordFieldError? newErr = _validateNew(state.newPassword);
    final ChangePasswordFieldError? confirmErr = _validateConfirm(
      state.newPassword,
      state.confirmPassword,
    );
    if (currentErr != null || newErr != null || confirmErr != null) {
      state = state.copyWith(
        currentError: currentErr,
        newError: newErr,
        confirmError: confirmErr,
      );
      return;
    }

    state = state.copyWith(submitting: true, formError: null);
    final Result<AuthResult> result = await ref
        .read(changePasswordUseCaseProvider)
        .call(
          currentPassword: state.currentPassword,
          newPassword: state.newPassword,
        );

    switch (result) {
      case Ok(:final AuthResult value):
        // Adopt the rotated tokens so this device stays signed in. `user` is null
        // on the token response, so the existing current user is preserved; the
        // sign-in method is left unchanged (null).
        await ref
            .read(sessionControllerProvider.notifier)
            .establish(
              user: value.user,
              accessToken: value.accessToken,
              refreshToken: value.refreshToken,
              rememberMe: ref.read(preferencesStoreProvider).rememberMe,
            );
        state = state.copyWith(submitting: false, success: true);
      case Err(:final Failure failure):
        _applyFailure(failure);
    }
  }

  void _applyFailure(Failure failure) {
    final String code = switch (failure) {
      NetworkFailure(:final String code) => code,
      AuthFailure(:final String code) => code,
      PermissionFailure(:final String code) => code,
      NotFoundFailure(:final String code) => code,
      ValidationFailure(:final String code) => code,
      ConflictFailure(:final String code) => code,
      DomainRuleFailure(:final String code) => code,
      RateLimitFailure(:final String code) => code,
      UnexpectedFailure(:final String code) => code,
    };
    switch (code) {
      case ErrorCodes.authCurrentPasswordInvalid:
        state = state.copyWith(
          submitting: false,
          currentError: ChangePasswordFieldError.currentInvalid,
        );
      case ErrorCodes.authPasswordWeak:
        state = state.copyWith(
          submitting: false,
          newError: ChangePasswordFieldError.weak,
        );
      default:
        state = state.copyWith(submitting: false, formError: failure);
    }
  }

  ChangePasswordFieldError? _validateNew(String value) {
    if (value.isEmpty) return ChangePasswordFieldError.required;
    if (value.length < Limits.passwordMin) {
      return ChangePasswordFieldError.tooShort;
    }
    if (value.length > Limits.passwordMax) {
      return ChangePasswordFieldError.tooLong;
    }
    return null;
  }

  ChangePasswordFieldError? _validateConfirm(String password, String confirm) {
    if (confirm.isEmpty) return ChangePasswordFieldError.required;
    if (confirm != password) return ChangePasswordFieldError.mismatch;
    return null;
  }
}

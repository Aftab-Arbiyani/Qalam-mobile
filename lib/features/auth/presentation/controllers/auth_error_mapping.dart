/// Maps a domain [Failure] from an auth submission onto the form (docs/40 §22.2,
/// docs/41 §29, §32): field-level codes land on their field, everything else
/// becomes a form-level banner. This is the single place auth server errors are
/// interpreted for the UI — form controllers apply the result, they don't branch
/// on codes themselves.
library;

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import 'field_state.dart';

/// Logical field keys the auth forms understand.
abstract final class AuthFieldKey {
  static const String email = 'email';
  static const String username = 'username';
  static const String password = 'password';
  static const String token = 'token';
}

/// The resolved shape of a submit failure: per-field errors to attach, plus an
/// optional banner failure (rendered via the error catalog) when the problem is
/// not field-specific.
class AuthSubmitError {
  const AuthSubmitError({
    this.fieldErrors = const <String, AuthFieldError>{},
    this.banner,
  });

  final Map<String, AuthFieldError> fieldErrors;
  final Failure? banner;

  bool get hasFieldErrors => fieldErrors.isNotEmpty;
}

AuthSubmitError mapFailureToAuthErrors(Failure failure) {
  // Codes that map onto a specific field.
  final AuthSubmitError? byCode = switch (_codeOf(failure)) {
    ErrorCodes.authEmailTaken => const AuthSubmitError(
      fieldErrors: <String, AuthFieldError>{
        AuthFieldKey.email: AuthFieldError.emailTaken,
      },
    ),
    ErrorCodes.userUsernameTaken => const AuthSubmitError(
      fieldErrors: <String, AuthFieldError>{
        AuthFieldKey.username: AuthFieldError.usernameTaken,
      },
    ),
    ErrorCodes.authPasswordWeak => const AuthSubmitError(
      fieldErrors: <String, AuthFieldError>{
        AuthFieldKey.password: AuthFieldError.passwordWeak,
      },
    ),
    ErrorCodes.authVerificationInvalid ||
    ErrorCodes.authResetInvalid => const AuthSubmitError(
      fieldErrors: <String, AuthFieldError>{
        AuthFieldKey.token: AuthFieldError.tokenInvalid,
      },
    ),
    _ => null,
  };
  if (byCode != null) return byCode;

  // Field-level validation issues from the server (rare — the client validates
  // first). Map each detail's field path onto a logical field.
  if (failure is ValidationFailure && failure.fieldErrors.isNotEmpty) {
    final Map<String, AuthFieldError> fields = <String, AuthFieldError>{};
    for (final field in failure.fieldErrors) {
      final String path = field.field.toLowerCase();
      if (path.contains('email')) {
        fields[AuthFieldKey.email] = AuthFieldError.emailInvalid;
      } else if (path.contains('username')) {
        fields[AuthFieldKey.username] = AuthFieldError.usernameFormat;
      } else if (path.contains('password')) {
        fields[AuthFieldKey.password] = AuthFieldError.passwordTooShort;
      } else if (path.contains('token')) {
        fields[AuthFieldKey.token] = AuthFieldError.tokenInvalid;
      }
    }
    if (fields.isNotEmpty) return AuthSubmitError(fieldErrors: fields);
  }

  // Anything else is a form-level banner.
  return AuthSubmitError(banner: failure);
}

String _codeOf(Failure failure) => switch (failure) {
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

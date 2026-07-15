/// Reusable form-field state (docs/41 §29) — value + a typed validation error +
/// a `touched` flag driving the "validate on blur first, then on change after the
/// first error" discipline. Errors are carried as a typed [AuthFieldError] enum
/// (never a raw string) so validators stay pure and the screen resolves the enum
/// to localized, literary copy from the catalog (docs/40 §21.3).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'field_state.freezed.dart';

/// The finite set of field-level problems the auth forms surface — a mix of
/// client-side format checks and the handful of server codes that map onto a
/// specific field (taken email/username, weak password, invalid token).
enum AuthFieldError {
  required,
  emailInvalid,
  usernameFormat,
  usernameLength,
  passwordTooShort,
  passwordTooLong,
  passwordsMismatch,
  emailTaken,
  usernameTaken,
  passwordWeak,
  tokenInvalid,
}

@freezed
abstract class FieldState with _$FieldState {
  const factory FieldState({
    @Default('') String value,
    AuthFieldError? error,
    @Default(false) bool touched,
  }) = _FieldState;

  const FieldState._();

  bool get hasError => error != null;
}

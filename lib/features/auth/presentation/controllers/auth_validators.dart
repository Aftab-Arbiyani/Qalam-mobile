/// Pure, client-side auth validators (docs/40 §19.3, docs/41 §29). These mirror
/// the shared `@qalam/shared` limits/regexes for instant UX feedback ONLY — the
/// server is authoritative and re-validates everything. They return a typed
/// [AuthFieldError] (or null) so they are trivially unit-testable and free of any
/// localization / widget dependency.
library;

import '../../../../shared/domain/limits.dart';
import 'field_state.dart';

abstract final class AuthValidators {
  /// A permissive email shape check — the server does the authoritative check.
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static AuthFieldError? email(String value) {
    final String v = value.trim();
    if (v.isEmpty) return AuthFieldError.required;
    if (!_email.hasMatch(v)) return AuthFieldError.emailInvalid;
    return null;
  }

  /// Username is permanent and `^[a-z0-9_]{3,30}$` (docs/40 §11.5). Length is
  /// checked before format so the message is the most specific one.
  static AuthFieldError? username(String value) {
    final String v = value.trim();
    if (v.isEmpty) return AuthFieldError.required;
    if (v.length < Limits.usernameMin || v.length > Limits.usernameMax) {
      return AuthFieldError.usernameLength;
    }
    if (!Patterns.username.hasMatch(v)) return AuthFieldError.usernameFormat;
    return null;
  }

  /// Password length policy 10–128 (NIST length-over-composition). Emptiness is a
  /// `required`; below/above the bounds are their own messages.
  static AuthFieldError? password(String value) {
    if (value.isEmpty) return AuthFieldError.required;
    if (value.length < Limits.passwordMin) {
      return AuthFieldError.passwordTooShort;
    }
    if (value.length > Limits.passwordMax) {
      return AuthFieldError.passwordTooLong;
    }
    return null;
  }

  /// Login only checks presence (the server validates the rest) — never leak
  /// whether a wrong-length password is even the failing factor.
  static AuthFieldError? presentPassword(String value) =>
      value.isEmpty ? AuthFieldError.required : null;

  static AuthFieldError? confirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return AuthFieldError.required;
    if (confirm != password) return AuthFieldError.passwordsMismatch;
    return null;
  }

  static AuthFieldError? required(String value) =>
      value.trim().isEmpty ? AuthFieldError.required : null;
}

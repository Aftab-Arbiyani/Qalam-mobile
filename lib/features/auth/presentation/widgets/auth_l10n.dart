/// Presentation-side resolvers that turn the typed, localization-free validation
/// and strength values into literary, localized copy (docs/40 §21.3, docs/41 §29).
/// Keeping these out of the pure controllers/validators is what lets the domain
/// stay context-free while the UI stays translatable.
library;

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/value_objects/password_strength.dart';
import '../controllers/field_state.dart';

/// Localized message for a field-level validation error, or null when there is
/// none — feeds straight into a field's `errorText`.
String? authFieldErrorText(AppLocalizations l10n, AuthFieldError? error) =>
    switch (error) {
      null => null,
      AuthFieldError.required => l10n.validationRequired,
      AuthFieldError.emailInvalid => l10n.validationEmailInvalid,
      AuthFieldError.usernameFormat => l10n.validationUsernameFormat,
      AuthFieldError.usernameLength => l10n.validationUsernameLength,
      AuthFieldError.passwordTooShort => l10n.validationPasswordTooShort,
      AuthFieldError.passwordTooLong => l10n.validationPasswordTooLong,
      AuthFieldError.passwordsMismatch => l10n.validationPasswordsMismatch,
      AuthFieldError.emailTaken => l10n.validationEmailTaken,
      AuthFieldError.usernameTaken => l10n.validationUsernameTaken,
      AuthFieldError.passwordWeak => l10n.validationPasswordWeak,
      AuthFieldError.tokenInvalid => l10n.validationTokenInvalid,
    };

/// Localized name for a password-strength level (used in the meter's a11y label).
String passwordStrengthLevelLabel(
  AppLocalizations l10n,
  PasswordStrengthLevel level,
) => switch (level) {
  PasswordStrengthLevel.empty => l10n.pwStrengthWeak,
  PasswordStrengthLevel.weak => l10n.pwStrengthWeak,
  PasswordStrengthLevel.fair => l10n.pwStrengthFair,
  PasswordStrengthLevel.good => l10n.pwStrengthGood,
  PasswordStrengthLevel.strong => l10n.pwStrengthStrong,
};

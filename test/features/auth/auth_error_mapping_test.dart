import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/features/auth/presentation/controllers/auth_error_mapping.dart';
import 'package:qalam_mobile/features/auth/presentation/controllers/field_state.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

void main() {
  group('mapFailureToAuthErrors', () {
    test('AUTH_EMAIL_TAKEN → email field error, no banner', () {
      final AuthSubmitError r = mapFailureToAuthErrors(
        const Failure.conflict(code: ErrorCodes.authEmailTaken),
      );
      expect(r.fieldErrors[AuthFieldKey.email], AuthFieldError.emailTaken);
      expect(r.banner, isNull);
    });

    test('USER_USERNAME_TAKEN → username field error', () {
      final AuthSubmitError r = mapFailureToAuthErrors(
        const Failure.conflict(code: ErrorCodes.userUsernameTaken),
      );
      expect(
        r.fieldErrors[AuthFieldKey.username],
        AuthFieldError.usernameTaken,
      );
    });

    test('AUTH_PASSWORD_WEAK → password field error', () {
      final AuthSubmitError r = mapFailureToAuthErrors(
        const Failure.domainRule(code: ErrorCodes.authPasswordWeak),
      );
      expect(r.fieldErrors[AuthFieldKey.password], AuthFieldError.passwordWeak);
    });

    test('AUTH_INVALID_CREDENTIALS → form banner, no field errors', () {
      final AuthSubmitError r = mapFailureToAuthErrors(
        const Failure.auth(code: ErrorCodes.authInvalidCredentials),
      );
      expect(r.hasFieldErrors, isFalse);
      expect(r.banner, isA<AuthFailure>());
    });

    test('VALIDATION_FAILED details map onto fields by path', () {
      final AuthSubmitError r = mapFailureToAuthErrors(
        const Failure.validation(
          code: ErrorCodes.validationFailed,
          fieldErrors: <FieldError>[
            FieldError(field: 'email', rule: 'isEmail', message: 'x'),
            FieldError(field: 'password', rule: 'minLength', message: 'x'),
          ],
        ),
      );
      expect(r.fieldErrors[AuthFieldKey.email], AuthFieldError.emailInvalid);
      expect(
        r.fieldErrors[AuthFieldKey.password],
        AuthFieldError.passwordTooShort,
      );
    });

    test('offline network failure → banner', () {
      final AuthSubmitError r = mapFailureToAuthErrors(
        const Failure.network(code: ErrorCodes.apiOffline, isOffline: true),
      );
      expect(r.banner, isA<NetworkFailure>());
      expect(r.hasFieldErrors, isFalse);
    });
  });
}

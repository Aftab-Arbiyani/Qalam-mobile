import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/auth/presentation/controllers/auth_validators.dart';
import 'package:qalam_mobile/features/auth/presentation/controllers/field_state.dart';

void main() {
  group('AuthValidators.email', () {
    test(
      'empty → required',
      () => expect(AuthValidators.email(''), AuthFieldError.required),
    );
    test(
      'malformed → emailInvalid',
      () => expect(AuthValidators.email('nope'), AuthFieldError.emailInvalid),
    );
    test('valid → null', () => expect(AuthValidators.email('a@b.co'), isNull));
    test(
      'trims surrounding whitespace',
      () => expect(AuthValidators.email('  a@b.co '), isNull),
    );
  });

  group('AuthValidators.username', () {
    test(
      'empty → required',
      () => expect(AuthValidators.username(''), AuthFieldError.required),
    );
    test(
      'too short → usernameLength',
      () =>
          expect(AuthValidators.username('ab'), AuthFieldError.usernameLength),
    );
    test(
      'uppercase → usernameFormat',
      () => expect(
        AuthValidators.username('Writer'),
        AuthFieldError.usernameFormat,
      ),
    );
    test(
      'valid lowercase/underscore/digits → null',
      () => expect(AuthValidators.username('a_writer_9'), isNull),
    );
  });

  group('AuthValidators.password', () {
    test(
      'empty → required',
      () => expect(AuthValidators.password(''), AuthFieldError.required),
    );
    test(
      'under 10 → passwordTooShort',
      () => expect(
        AuthValidators.password('short'),
        AuthFieldError.passwordTooShort,
      ),
    );
    test(
      'valid → null',
      () => expect(AuthValidators.password('a-good-password'), isNull),
    );
  });

  group('AuthValidators.presentPassword (login)', () {
    test(
      'empty → required',
      () => expect(AuthValidators.presentPassword(''), AuthFieldError.required),
    );
    test(
      'any non-empty → null (never leaks length)',
      () => expect(AuthValidators.presentPassword('x'), isNull),
    );
  });

  group('AuthValidators.confirmPassword', () {
    test(
      'mismatch → passwordsMismatch',
      () => expect(
        AuthValidators.confirmPassword('abcdefghij', 'nope'),
        AuthFieldError.passwordsMismatch,
      ),
    );
    test(
      'match → null',
      () => expect(
        AuthValidators.confirmPassword('abcdefghij', 'abcdefghij'),
        isNull,
      ),
    );
  });
}

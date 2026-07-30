import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/features/auth/presentation/controllers/field_state.dart';
import 'package:qalam_mobile/features/auth/presentation/controllers/login_form_controller.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/harness.dart';

void main() {
  test(
    'validate-on-blur: an untouched field shows no error until blurred',
    () async {
      final ProviderContainer container = await buildTestContainer();
      addTearDown(container.dispose);
      final LoginFormController c = container.read(
        loginFormControllerProvider.notifier,
      );

      c.changeEmail('nope');
      // Not yet touched → no error while typing.
      expect(container.read(loginFormControllerProvider).email.error, isNull);

      c.blurEmail();
      expect(
        container.read(loginFormControllerProvider).email.error,
        AuthFieldError.emailInvalid,
      );

      // After the first error, further typing re-validates live.
      c.changeEmail('a@b.co');
      expect(container.read(loginFormControllerProvider).email.error, isNull);
    },
  );

  test(
    'submit with empty fields sets required errors and does not call the repo',
    () async {
      final FakeAuthRepository fake = FakeAuthRepository();
      final ProviderContainer container = await buildTestContainer(
        authRepository: fake,
      );
      addTearDown(container.dispose);
      final LoginFormController c = container.read(
        loginFormControllerProvider.notifier,
      );

      await c.submit();

      final LoginFormState state = container.read(loginFormControllerProvider);
      expect(state.email.error, AuthFieldError.required);
      expect(state.password.error, AuthFieldError.required);
      expect(fake.loginCalls, 0);
      expect(state.submitting, isFalse);
    },
  );

  test(
    'invalid credentials → form banner, no field error, submitting reset',
    () async {
      final FakeAuthRepository fake = FakeAuthRepository(
        failure: const Failure.auth(code: ErrorCodes.authInvalidCredentials),
      );
      final ProviderContainer container = await buildTestContainer(
        authRepository: fake,
      );
      addTearDown(container.dispose);
      final LoginFormController c = container.read(
        loginFormControllerProvider.notifier,
      );

      c.changeEmail('writer@qalam.test');
      c.changePassword('secret1234');
      await c.submit();

      final LoginFormState state = container.read(loginFormControllerProvider);
      expect(fake.loginCalls, 1);
      expect(state.formError, isA<AuthFailure>());
      expect(state.email.error, isNull);
      expect(state.success, isFalse);
      expect(state.submitting, isFalse);
    },
  );
}

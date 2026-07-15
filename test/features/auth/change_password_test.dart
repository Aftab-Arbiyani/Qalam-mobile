import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/features/auth/presentation/controllers/change_password_controller.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/harness.dart';

Future<ProviderContainer> _container(FakeAuthRepository repo) async {
  final ProviderContainer c = await buildTestContainer(authRepository: repo);
  addTearDown(c.dispose);
  c.listen(changePasswordControllerProvider, (_, _) {});
  return c;
}

void main() {
  test('blocks submit on empty/short/mismatched input, no repo call', () async {
    final FakeAuthRepository repo = FakeAuthRepository();
    final ProviderContainer c = await _container(repo);
    final ChangePasswordController ctrl = c.read(
      changePasswordControllerProvider.notifier,
    );

    await ctrl.submit();
    ChangePasswordState state = c.read(changePasswordControllerProvider);
    expect(state.currentError, ChangePasswordFieldError.required);
    expect(state.newError, ChangePasswordFieldError.required);

    ctrl
      ..changeCurrent('oldpassword12')
      ..changeNew('short')
      ..changeConfirm('mismatch');
    await ctrl.submit();
    state = c.read(changePasswordControllerProvider);
    expect(state.newError, ChangePasswordFieldError.tooShort);
    expect(state.confirmError, ChangePasswordFieldError.mismatch);
    expect(repo.changePasswordCalls, 0);
  });

  test('valid submit calls the repo and flips success', () async {
    final FakeAuthRepository repo = FakeAuthRepository();
    final ProviderContainer c = await _container(repo);
    final ChangePasswordController ctrl = c.read(
      changePasswordControllerProvider.notifier,
    );
    ctrl
      ..changeCurrent('oldpassword12')
      ..changeNew('newpassword34')
      ..changeConfirm('newpassword34');
    await ctrl.submit();
    expect(repo.changePasswordCalls, 1);
    expect(c.read(changePasswordControllerProvider).success, isTrue);
  });

  test('wrong current password maps to the current-password field', () async {
    final FakeAuthRepository repo = FakeAuthRepository(
      failure: const Failure.validation(code: 'AUTH_CURRENT_PASSWORD_INVALID'),
    );
    final ProviderContainer c = await _container(repo);
    final ChangePasswordController ctrl = c.read(
      changePasswordControllerProvider.notifier,
    );
    ctrl
      ..changeCurrent('wrongpassword')
      ..changeNew('newpassword34')
      ..changeConfirm('newpassword34');
    await ctrl.submit();
    expect(
      c.read(changePasswordControllerProvider).currentError,
      ChangePasswordFieldError.currentInvalid,
    );
    expect(c.read(changePasswordControllerProvider).success, isFalse);
  });

  test('weak password maps to the new-password field', () async {
    final FakeAuthRepository repo = FakeAuthRepository(
      failure: const Failure.domainRule(code: 'AUTH_PASSWORD_WEAK'),
    );
    final ProviderContainer c = await _container(repo);
    final ChangePasswordController ctrl = c.read(
      changePasswordControllerProvider.notifier,
    );
    ctrl
      ..changeCurrent('oldpassword12')
      ..changeNew('newpassword34')
      ..changeConfirm('newpassword34');
    await ctrl.submit();
    expect(
      c.read(changePasswordControllerProvider).newError,
      ChangePasswordFieldError.weak,
    );
  });
}

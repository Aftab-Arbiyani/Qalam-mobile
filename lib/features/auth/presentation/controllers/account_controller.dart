/// Account controller (docs/40 §14.6). Owns the logout flow: best-effort server
/// revocation via the sign-out use case (this device, or everywhere), then the
/// local session teardown via the core session notifier. The local teardown runs
/// regardless of the network result, so logout works offline. After teardown the
/// session flips to anonymous and the router redirects away — no navigation here.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/session/session_controller.dart';
import '../providers/auth_providers.dart';

part 'account_controller.freezed.dart';
part 'account_controller.g.dart';

@freezed
abstract class AccountState with _$AccountState {
  const factory AccountState({@Default(false) bool signingOut}) = _AccountState;
}

@riverpod
class AccountController extends _$AccountController {
  @override
  AccountState build() => const AccountState();

  Future<void> signOut({bool everywhere = false}) async {
    if (state.signingOut) return;
    state = const AccountState(signingOut: true);
    // Best-effort server revocation — ignore the result so a network failure never
    // traps the user in a signed-in state.
    await ref.read(signOutUseCaseProvider).call(everywhere: everywhere);
    // Local teardown flips the session to anonymous; the router redirects and this
    // (autoDispose) controller is disposed — do not touch state afterwards.
    await ref.read(sessionControllerProvider.notifier).signOut();
  }
}

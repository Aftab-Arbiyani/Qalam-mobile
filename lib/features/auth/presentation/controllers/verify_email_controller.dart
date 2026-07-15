/// Verify-email controller (docs/40 §11.5, §14.1). Drives the two verify-email
/// modes: submitting a token (from a deep link) and resending the link (for a
/// freshly-registered, still-signed-in user). On a successful token verification it
/// marks the live session verified so the banner clears app-wide. Verification is a
/// state, not a wall — the screen always offers "continue" regardless.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../providers/auth_providers.dart';

part 'verify_email_controller.freezed.dart';
part 'verify_email_controller.g.dart';

enum VerifyEmailStatus { idle, verifying, verified, resending, resent }

@freezed
abstract class VerifyEmailState with _$VerifyEmailState {
  const factory VerifyEmailState({
    @Default(VerifyEmailStatus.idle) VerifyEmailStatus status,
    Failure? error,
  }) = _VerifyEmailState;

  const VerifyEmailState._();

  bool get isBusy =>
      status == VerifyEmailStatus.verifying ||
      status == VerifyEmailStatus.resending;
}

@riverpod
class VerifyEmailController extends _$VerifyEmailController {
  @override
  VerifyEmailState build() => const VerifyEmailState();

  /// Submit a verification token (deep-link entry). Public endpoint — works signed
  /// out too; when signed in it also clears the session's unverified state.
  Future<void> verify(String token) async {
    if (state.isBusy) return;
    state = state.copyWith(status: VerifyEmailStatus.verifying, error: null);
    final Result<Unit> result = await ref
        .read(verifyEmailUseCaseProvider)
        .call(token: token);
    switch (result) {
      case Ok<Unit>():
        ref.read(sessionControllerProvider.notifier).markEmailVerified();
        state = state.copyWith(status: VerifyEmailStatus.verified);
      case Err<Unit>(:final Failure failure):
        state = state.copyWith(status: VerifyEmailStatus.idle, error: failure);
    }
  }

  /// Resend the verification email to the current user (requires a session).
  Future<void> resend() async {
    if (state.isBusy) return;
    state = state.copyWith(status: VerifyEmailStatus.resending, error: null);
    final Result<Unit> result = await ref
        .read(resendVerificationUseCaseProvider)
        .call();
    switch (result) {
      case Ok<Unit>():
        state = state.copyWith(status: VerifyEmailStatus.resent);
      case Err<Unit>(:final Failure failure):
        state = state.copyWith(status: VerifyEmailStatus.idle, error: failure);
    }
  }
}

/// Social sign-in controller (docs/40 §14.4, §39.1). Orchestrates the full,
/// provider-agnostic flow: launch the native authorization seam → exchange the
/// one-time code for tokens → establish the session. The frozen Google exchange
/// returns an access token only (no user, no body refresh token), so the session
/// is access-token-only — a documented contract gap (§14.4). Apple is a declared
/// Phase-2 seam (`SocialProvider.apple.isAvailable == false`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/session/sign_in_method.dart';
import '../../../../core/utils/result.dart';
import '../../data/services/social_sign_in_service.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/social_provider.dart';
import '../providers/auth_providers.dart';

part 'social_auth_controller.freezed.dart';
part 'social_auth_controller.g.dart';

enum SocialAuthStatus {
  idle,
  inProgress,
  success,
  cancelled,
  unsupported,
  failure,
}

@freezed
abstract class SocialAuthState with _$SocialAuthState {
  const factory SocialAuthState({
    @Default(SocialAuthStatus.idle) SocialAuthStatus status,
    SocialProvider? provider,
    Failure? error,
  }) = _SocialAuthState;

  const SocialAuthState._();

  bool get isBusy => status == SocialAuthStatus.inProgress;
}

@riverpod
class SocialAuthController extends _$SocialAuthController {
  @override
  SocialAuthState build() => const SocialAuthState();

  Future<void> signIn(SocialProvider provider) async {
    if (state.isBusy) return;

    if (!provider.isAvailable) {
      state = SocialAuthState(
        status: SocialAuthStatus.unsupported,
        provider: provider,
      );
      return;
    }

    state = SocialAuthState(
      status: SocialAuthStatus.inProgress,
      provider: provider,
    );
    final SocialAuthorization authorization = await ref
        .read(socialSignInServiceProvider)
        .authorize(provider);

    switch (authorization) {
      case SocialAuthorizationCancelled():
        state = SocialAuthState(
          status: SocialAuthStatus.cancelled,
          provider: provider,
        );
      case SocialAuthorizationUnsupported():
        state = SocialAuthState(
          status: SocialAuthStatus.unsupported,
          provider: provider,
        );
      case SocialAuthorizationCode(:final String code):
        await _exchange(provider, code);
    }
  }

  /// Complete sign-in from a code already delivered out-of-band — the deep-link
  /// callback path (`/auth/callback?code=…`), where the browser round-trip already
  /// produced the authorization code.
  Future<void> completeWithCode({
    required SocialProvider provider,
    required String code,
  }) async {
    if (state.isBusy) return;
    state = SocialAuthState(
      status: SocialAuthStatus.inProgress,
      provider: provider,
    );
    await _exchange(provider, code);
  }

  Future<void> _exchange(SocialProvider provider, String code) async {
    final Result<AuthResult> result = await ref
        .read(exchangeSocialCodeUseCaseProvider)
        .call(provider: provider, code: code);
    switch (result) {
      case Ok(:final AuthResult value):
        await ref
            .read(sessionControllerProvider.notifier)
            .establish(
              user: value.user,
              accessToken: value.accessToken,
              refreshToken: value.refreshToken,
              rememberMe: false,
              signInMethod: SignInMethod.google,
            );
        state = SocialAuthState(
          status: SocialAuthStatus.success,
          provider: provider,
        );
      case Err(:final Failure failure):
        state = SocialAuthState(
          status: SocialAuthStatus.failure,
          provider: provider,
          error: failure,
        );
    }
  }
}

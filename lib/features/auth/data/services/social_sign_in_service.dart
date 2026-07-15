/// Social sign-in launcher seam (docs/40 §14.4, §39.2, §45).
///
/// This is the provider-agnostic boundary for the *native* half of social login:
/// launching the provider's authorization UI and returning the one-time code the
/// backend delivers to `/auth/callback`. The *server* half — trading that code for
/// tokens via `POST /auth/google/exchange` — is fully wired through the repository;
/// only this native launch is a seam, because it needs platform OAuth-client
/// configuration (universal-link interception of the web `APP_URL/auth/callback`,
/// an in-app browser tab) that cannot be provisioned or verified in this build.
///
/// The M2 default is [UnsupportedSocialSignInService] — mirroring the M1 inert
/// seams (Noop push / biometric / cert-pinning): the pipeline, callback route, and
/// exchange endpoint are real and testable; the launcher returns null so the UI
/// shows an honest "not available in this build yet" state rather than a fake flow.
/// A future epic swaps in a real launcher (flutter_web_auth / AppAuth) with ZERO
/// change to the repository, use case, controller, or UI.
library;

import '../../domain/entities/social_provider.dart';

/// The outcome of a native authorization launch.
sealed class SocialAuthorization {
  const SocialAuthorization();
}

/// The provider returned a one-time authorization [code] for exchange.
class SocialAuthorizationCode extends SocialAuthorization {
  const SocialAuthorizationCode(this.code);
  final String code;
}

/// The user dismissed the provider flow — not an error; show nothing.
class SocialAuthorizationCancelled extends SocialAuthorization {
  const SocialAuthorizationCancelled();
}

/// The provider is not wired in this build (the M2 seam default, or Apple).
class SocialAuthorizationUnsupported extends SocialAuthorization {
  const SocialAuthorizationUnsupported();
}

abstract interface class SocialSignInService {
  /// Whether the native flow for [provider] is available in this build.
  bool isSupported(SocialProvider provider);

  /// Launch [provider]'s authorization UI and resolve to the one-time code, a
  /// cancellation, or unsupported.
  Future<SocialAuthorization> authorize(SocialProvider provider);
}

/// The inert M2 default — every provider is unsupported until a real launcher is
/// wired in a later epic.
class UnsupportedSocialSignInService implements SocialSignInService {
  const UnsupportedSocialSignInService();

  @override
  bool isSupported(SocialProvider provider) => false;

  @override
  Future<SocialAuthorization> authorize(SocialProvider provider) async =>
      const SocialAuthorizationUnsupported();
}

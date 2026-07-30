/// Session controller (docs/40 §8.5, §14.3–§14.6, §15) — the session tri-state as
/// a keep-alive `AsyncNotifier`. It is the single source route guards read.
///
/// - `build` performs the silent boot restore (docs/40 §14.5): gated by
///   remember-me, it attempts ONE single-flight refresh; success → authenticated,
///   failure → anonymous with no error UI (an expired session is normal).
/// - `establish` transitions to authenticated after a login/register/social
///   sign-in: it persists tokens, sets remember-me + the current user, and
///   derives the role from the access JWT (a UX hint only — docs/40 §11.4).
/// - `signOut` is the secure local teardown: clears tokens, the current user, and
///   the read cache, then flips to anonymous. Device prefs (theme/reading) survive.
///
/// It wires the auth gateway's unauthorized callback so a terminal 401 (refresh
/// failure / revoked family) flips the session to anonymous, which the router
/// reacts to by routing to login (docs/40 §14.6, §15).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/domain/enums.dart';
import '../di/providers.dart';
import '../reading_history/reading_history_controller.dart';
import '../utils/jwt.dart';
import 'current_user.dart';
import 'current_user_controller.dart';
import 'session_state.dart';
import 'sign_in_method.dart';

part 'session_controller.g.dart';

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<SessionState> build() async {
    ref.watch(authGatewayProvider).onUnauthorized = _handleUnauthorized;

    final tokenStore = ref.watch(tokenStoreProvider);
    final prefs = ref.watch(preferencesStoreProvider);
    await tokenStore.restore();

    // Silent restore is gated by remember-me (docs/40 §14.5). The refresh fires
    // at most once here — a double refresh would rotate the token twice and trip
    // family-reuse detection.
    if (prefs.rememberMe && await tokenStore.hasRefreshToken()) {
      final bool refreshed = await ref.read(authGatewayProvider).refresh();
      if (refreshed) {
        final DecodedAccessToken? decoded = decodeAccessToken(
          tokenStore.accessToken,
        );
        if (decoded != null) {
          // Identity (username/email/verified) is not in the refresh response
          // nor the JWT; the current user stays null until M3 hydrates it from
          // `GET /me`. `isEmailVerified` is therefore unknown after restore.
          return SessionState.authenticated(role: decoded.role);
        }
      }
    }
    return const SessionState.anonymous();
  }

  /// Establish an authenticated session from a completed sign-in (docs/40 §14.3).
  /// Persists the freshly issued tokens, records remember-me, sets the current
  /// user, and derives the role from the access JWT. [user] is null for the Google
  /// exchange path, whose frozen response carries only an access token (§14.4).
  Future<void> establish({
    CurrentUser? user,
    required String accessToken,
    String? refreshToken,
    required bool rememberMe,
    SignInMethod? signInMethod,
  }) async {
    await ref
        .read(tokenStoreProvider)
        .save(access: accessToken, refresh: refreshToken);
    // Record how this session was authenticated for the account settings screen.
    // Null (e.g. a change-password token rotation) leaves the existing value.
    if (signInMethod != null) {
      await ref
          .read(preferencesStoreProvider)
          .setSignInMethod(signInMethod.wire);
    }
    // Silent restore needs a refresh token; without one (Google exchange) it can
    // never restore, so remember-me is forced off regardless of the checkbox.
    final bool canRestore = refreshToken != null && refreshToken.isNotEmpty;
    await ref
        .read(preferencesStoreProvider)
        .setRememberMe(rememberMe && canRestore);
    if (user != null) {
      ref.read(currentUserControllerProvider.notifier).set(user);
    }

    final DecodedAccessToken? decoded = decodeAccessToken(accessToken);
    state = AsyncData<SessionState>(
      SessionState.authenticated(
        role: decoded?.role ?? Role.user,
        isEmailVerified: user?.isEmailVerified,
      ),
    );
  }

  /// Reflect a completed email verification on the live session (docs/40 §11.5).
  void markEmailVerified() {
    final SessionState current = state.stateOrUnknown;
    if (current.isAuthenticated) {
      state = AsyncData<SessionState>(
        SessionState.authenticated(
          role: current.role ?? Role.user,
          isEmailVerified: true,
        ),
      );
    }
    ref.read(currentUserControllerProvider.notifier).markEmailVerified();
  }

  /// Secure logout (docs/40 §14.6): clear tokens, the current user, and the read
  /// cache locally, then flip to anonymous. The backend revocation call is made
  /// by the auth feature before this; this teardown always runs, even offline.
  Future<void> signOut() async {
    await ref.read(tokenStoreProvider).clear();
    ref.read(currentUserControllerProvider.notifier).clear();
    await ref.read(cacheStoreProvider).clear();
    // Reading history is device reading data — clear it too so a shared device
    // doesn't leak what the previous account read (docs/40 §23, §39.1).
    await ref.read(readingHistoryStoreProvider).clear();
    state = const AsyncData<SessionState>(SessionState.anonymous());
  }

  void _handleUnauthorized() {
    ref.read(currentUserControllerProvider.notifier).clear();
    state = const AsyncData<SessionState>(SessionState.anonymous());
  }
}

/// Convenience: the current session as a resolved [SessionState], mapping
/// loading → `unknown` so guards can pattern-match a single type (docs/40 §11.2).
extension SessionValue on AsyncValue<SessionState> {
  SessionState get stateOrUnknown => maybeWhen(
    data: (SessionState s) => s,
    orElse: () => const SessionState.unknown(),
  );
}

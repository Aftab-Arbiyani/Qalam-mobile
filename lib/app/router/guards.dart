/// Route guards (docs/40 §11) — a pure redirect function driven by the session
/// tri-state and the onboarding flag (via the shared launch-phase resolver). Kept
/// pure (no Riverpod, no BuildContext) so it is exhaustively unit-testable.
///
/// - `booting`         → hold the loading shell (splash); never flash a redirect
///   while the boot restore is in flight (prevents the false-bounce-on-cold-start).
/// - `onboarding`      → force the onboarding flow on first launch, EXCEPT the auth
///   corridor (so a fresh-install deep link / the onboarding hand-off still work).
/// - `unauthenticated` → protected route → login carrying `returnTo`; public + auth
///   corridor allowed.
/// - `authenticated`   → guest-only auth route → feed; everything else allowed.
library;

import '../../core/session/app_launch.dart';
import '../../core/session/session_state.dart';
import 'routes.dart';

/// Pure guard — takes the matched location string (not a `GoRouterState`) so it
/// is trivially unit-testable. The router passes `state.matchedLocation` and the
/// current onboarding flag. `isOnboardingComplete` defaults to `true` so tests and
/// callers concerned only with auth need not supply it.
String? guardRedirect({
  required SessionState session,
  required String location,
  bool isOnboardingComplete = true,
}) {
  final AppLaunchPhase phase = resolveLaunchPhase(
    session: session,
    isOnboardingComplete: isOnboardingComplete,
  );
  final bool onSplash = location == Routes.splash;
  final bool onOnboarding = location == Routes.onboarding;

  switch (phase) {
    case AppLaunchPhase.booting:
      return onSplash ? null : Routes.splash;

    case AppLaunchPhase.onboarding:
      if (onOnboarding || Routes.isAuthCorridor(location)) return null;
      return Routes.onboarding;

    case AppLaunchPhase.unauthenticated:
      if (onSplash || onOnboarding) return Routes.feed;
      if (Routes.isProtected(location)) {
        return Uri(
          path: Routes.login,
          queryParameters: <String, String>{'returnTo': location},
        ).toString();
      }
      return null;

    case AppLaunchPhase.authenticated:
      if (onSplash || onOnboarding) return Routes.feed;
      if (Routes.isGuestOnly(location)) return Routes.feed;
      return null;
  }
}

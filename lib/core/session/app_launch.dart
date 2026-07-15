/// App launch state (docs/40 §11.2, §14.5) — the single semantic phase the app
/// is in at any moment, derived purely from the session tri-state and the
/// onboarding-completed flag. The router guard and the splash both consume this
/// one resolution, so "where should the app be" is defined in exactly one place.
///
/// - `booting`         — silent token restore in flight; hold the loading shell,
///                       never redirect (prevents the false-bounce-on-cold-start).
/// - `onboarding`      — first launch, not signed in, onboarding not yet seen.
/// - `unauthenticated` — onboarding seen, no session; the auth corridor / public
///                       shell is reachable.
/// - `authenticated`   — a live session; the full app shell.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/preferences_store.dart';
import 'onboarding_controller.dart';
import 'session_controller.dart';
import 'session_state.dart';

part 'app_launch.g.dart';

enum AppLaunchPhase { booting, onboarding, unauthenticated, authenticated }

/// Pure resolver — no Riverpod, no I/O — so it is trivially unit-testable and is
/// the shared truth for both the guard and the launch provider.
AppLaunchPhase resolveLaunchPhase({
  required SessionState session,
  required bool isOnboardingComplete,
}) {
  if (session.isUnknown) return AppLaunchPhase.booting;
  if (session.isAuthenticated) return AppLaunchPhase.authenticated;
  return isOnboardingComplete
      ? AppLaunchPhase.unauthenticated
      : AppLaunchPhase.onboarding;
}

/// Reactive launch phase — recomputes when the session resolves or onboarding
/// completes. `keepAlive` because it mirrors the two keep-alive sources it reads.
@Riverpod(keepAlive: true)
AppLaunchPhase appLaunchPhase(Ref ref) {
  final SessionState session = ref
      .watch(sessionControllerProvider)
      .stateOrUnknown;
  final bool onboarded = ref.watch(onboardingControllerProvider);
  return resolveLaunchPhase(session: session, isOnboardingComplete: onboarded);
}

/// Convenience accessor for the persisted onboarding flag, read by bootstrap and
/// tests without reaching into the box directly.
bool readOnboardingComplete(PreferencesStore prefs) => prefs.onboardingComplete;

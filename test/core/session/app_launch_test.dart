import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/session/app_launch.dart';
import 'package:qalam_mobile/core/session/session_state.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  group('resolveLaunchPhase', () {
    test('unknown session → booting (regardless of onboarding)', () {
      expect(
        resolveLaunchPhase(
          session: const SessionState.unknown(),
          isOnboardingComplete: true,
        ),
        AppLaunchPhase.booting,
      );
      expect(
        resolveLaunchPhase(
          session: const SessionState.unknown(),
          isOnboardingComplete: false,
        ),
        AppLaunchPhase.booting,
      );
    });

    test('authenticated → authenticated (onboarding irrelevant)', () {
      expect(
        resolveLaunchPhase(
          session: const SessionState.authenticated(role: Role.user),
          isOnboardingComplete: false,
        ),
        AppLaunchPhase.authenticated,
      );
    });

    test('anonymous + not onboarded → onboarding', () {
      expect(
        resolveLaunchPhase(
          session: const SessionState.anonymous(),
          isOnboardingComplete: false,
        ),
        AppLaunchPhase.onboarding,
      );
    });

    test('anonymous + onboarded → unauthenticated', () {
      expect(
        resolveLaunchPhase(
          session: const SessionState.anonymous(),
          isOnboardingComplete: true,
        ),
        AppLaunchPhase.unauthenticated,
      );
    });
  });
}

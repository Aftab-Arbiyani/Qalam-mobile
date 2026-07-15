import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/app/router/guards.dart';
import 'package:qalam_mobile/app/router/routes.dart';
import 'package:qalam_mobile/core/session/session_state.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  group('guardRedirect', () {
    test('unknown session holds on splash, sends others to splash', () {
      expect(
        guardRedirect(
          session: const SessionState.unknown(),
          location: Routes.splash,
        ),
        isNull,
      );
      expect(
        guardRedirect(
          session: const SessionState.unknown(),
          location: Routes.feed,
        ),
        Routes.splash,
      );
    });

    test('resolved session leaves the splash for the feed', () {
      expect(
        guardRedirect(
          session: const SessionState.anonymous(),
          location: Routes.splash,
        ),
        Routes.feed,
      );
    });

    test('protected + anonymous → login carrying returnTo', () {
      final String? redirect = guardRedirect(
        session: const SessionState.anonymous(),
        location: Routes.settings,
      );
      expect(redirect, isNotNull);
      expect(redirect, startsWith(Routes.login));
      expect(Uri.parse(redirect!).queryParameters['returnTo'], Routes.settings);
    });

    test('protected + authenticated → allowed', () {
      expect(
        guardRedirect(
          session: const SessionState.authenticated(role: Role.user),
          location: Routes.settings,
        ),
        isNull,
      );
    });

    test('auth corridor + authenticated → feed', () {
      expect(
        guardRedirect(
          session: const SessionState.authenticated(role: Role.user),
          location: Routes.login,
        ),
        Routes.feed,
      );
    });

    test('public shell routes are always allowed', () {
      expect(
        guardRedirect(
          session: const SessionState.anonymous(),
          location: Routes.feed,
        ),
        isNull,
      );
    });
  });

  group('safeReturnTo', () {
    test('accepts same-origin relative paths', () {
      expect(Routes.safeReturnTo('/me/stats'), '/me/stats');
    });

    test('rejects absolute / off-site targets', () {
      expect(Routes.safeReturnTo('https://evil.example'), Routes.feed);
      expect(Routes.safeReturnTo(null), Routes.feed);
      expect(Routes.safeReturnTo('//evil.example'), Routes.feed);
      expect(Routes.safeReturnTo(Routes.login), Routes.feed);
    });
  });

  group('guardRedirect — onboarding gate (M2)', () {
    test('first launch (not onboarded, anonymous) forces onboarding', () {
      expect(
        guardRedirect(
          session: const SessionState.anonymous(),
          location: Routes.feed,
          isOnboardingComplete: false,
        ),
        Routes.onboarding,
      );
    });

    test('onboarding route itself is allowed while not onboarded', () {
      expect(
        guardRedirect(
          session: const SessionState.anonymous(),
          location: Routes.onboarding,
          isOnboardingComplete: false,
        ),
        isNull,
      );
    });

    test(
      'auth corridor is reachable even before onboarding (fresh-install deep link)',
      () {
        expect(
          guardRedirect(
            session: const SessionState.anonymous(),
            location: Routes.resetPassword,
            isOnboardingComplete: false,
          ),
          isNull,
        );
      },
    );

    test('onboarded anonymous leaves the onboarding route for the feed', () {
      expect(
        guardRedirect(
          session: const SessionState.anonymous(),
          location: Routes.onboarding,
        ),
        Routes.feed,
      );
    });
  });

  group('guardRedirect — protected routes (M2, docs/40 §10.2)', () {
    for (final String path in <String>[
      Routes.profile,
      Routes.write,
      Routes.notifications,
    ]) {
      test('$path + anonymous → login with returnTo', () {
        final String? redirect = guardRedirect(
          session: const SessionState.anonymous(),
          location: path,
        );
        expect(redirect, startsWith(Routes.login));
        expect(Uri.parse(redirect!).queryParameters['returnTo'], path);
      });

      test('$path + authenticated → allowed', () {
        expect(
          guardRedirect(
            session: const SessionState.authenticated(role: Role.user),
            location: path,
          ),
          isNull,
        );
      });
    }

    test('feed + anonymous stays public', () {
      expect(
        guardRedirect(
          session: const SessionState.anonymous(),
          location: Routes.feed,
        ),
        isNull,
      );
    });
  });

  group('guardRedirect — auth corridor (M2)', () {
    test('verify-email is NOT guest-only (reachable while authenticated)', () {
      expect(
        guardRedirect(
          session: const SessionState.authenticated(role: Role.user),
          location: Routes.verifyEmail,
        ),
        isNull,
      );
    });

    test('register + authenticated → feed (guest-only)', () {
      expect(
        guardRedirect(
          session: const SessionState.authenticated(role: Role.user),
          location: Routes.register,
        ),
        Routes.feed,
      );
    });
  });
}

/// How the current session was authenticated (docs/40 §14) — recorded at
/// `establish` time so the account settings screen can show a read-only "sign-in
/// method" line. The frozen `v1` exposes no connected-accounts endpoint, so this
/// device-local hint is the honest substitute (there is nothing to link/unlink).
library;

enum SignInMethod {
  password('password'),
  google('google'),
  unknown('unknown');

  const SignInMethod(this.wire);

  final String wire;

  static SignInMethod fromWire(
    String? value, {
    SignInMethod fallback = SignInMethod.unknown,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

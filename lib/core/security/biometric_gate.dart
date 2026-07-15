/// Biometric app-lock — architecture placeholder (docs/40 §39.2).
///
/// Optional hardening: gate app open / sensitive actions behind device biometrics
/// or passcode. The seam is defined so a future implementation (e.g.
/// `local_auth`) drops in behind this interface with no call-site change. The M1
/// implementation reports "unavailable" and authenticates trivially (bypass).
library;

abstract interface class BiometricGate {
  /// Whether the device can perform a biometric/passcode check.
  Future<bool> isAvailable();

  /// Prompt for authentication. Returns true when the user is authenticated.
  Future<bool> authenticate({required String reason});
}

class NoopBiometricGate implements BiometricGate {
  const NoopBiometricGate();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate({required String reason}) async => true;
}

/// Screenshot / screen-recording protection — architecture placeholder
/// (docs/40 §39.2; docs/52 P7.2).
///
/// Sensitive surfaces (auth, payment, private drafts) can suppress screenshots
/// and screen recording. The app talks to this interface, never to a platform
/// channel or a vendor package — so the concrete impl is a one-swap change,
/// exactly like the [CrashReporter], remote-config and certificate-pinning seams.
///
/// It is inert by default: the [NoopScreenshotProtectionService] does nothing, so
/// a build with no protection compiled in behaves identically (safe for tests +
/// the current release). When protection is activated, a real impl adds
/// `WindowManager.FLAG_SECURE` on Android and hides/blurs the view on iOS
/// (e.g. via a `screen_protector` package or a platform channel) — no call site
/// changes. Activation is a product decision (whole-app vs. per-screen), driven
/// through the `screenshotProtectionProvider` from the screens that need it.
library;

abstract interface class ScreenshotProtectionService {
  /// Suppress screenshots + screen recording for the current window. On Android
  /// this sets `FLAG_SECURE`; on iOS it hides/blurs the view when captured.
  Future<void> enable();

  /// Re-allow screenshots + screen recording (clears `FLAG_SECURE`).
  Future<void> disable();
}

/// The default, inert protection service used until a concrete impl is compiled
/// in. Both calls are no-ops, so screenshots stay allowed (M1/P7.2 posture).
class NoopScreenshotProtectionService implements ScreenshotProtectionService {
  const NoopScreenshotProtectionService();

  @override
  Future<void> enable() async {
    // Inert by design. A real impl sets FLAG_SECURE (Android) / hides the view
    // (iOS). Enabled in the security-hardening activation step (docs/52).
  }

  @override
  Future<void> disable() async {
    // Inert by design — nothing was enabled, so there is nothing to clear.
  }
}

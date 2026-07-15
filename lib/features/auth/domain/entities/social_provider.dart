/// Social identity providers (docs/40 §14.4, §39.1). Provider-agnostic by design
/// so a new provider slots in without touching the sign-in pipeline — the frozen
/// `auth_identities` seam is ready for Apple, which is Phase 2 (no backend
/// endpoints exist yet), so this M2 wires Google and leaves Apple as a declared,
/// disabled seam.
library;

enum SocialProvider {
  google('google', 'Google', isAvailable: true),
  apple('apple', 'Apple', isAvailable: false);

  const SocialProvider(this.wire, this.label, {required this.isAvailable});

  /// The provider key the backend uses (`auth_identities.provider`).
  final String wire;

  /// Human label for the "Continue with …" button.
  final String label;

  /// Whether the backend + native flow are live for this provider. Apple is a
  /// Phase-2 seam: present in the UI as a ready affordance, but not yet wired.
  final bool isAvailable;
}

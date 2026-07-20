/// Remote configuration seam (docs/40 §28, §31; docs/51 P7.1). The app reads
/// runtime-tunable values (kill switches, rollout percentages, tunables) through
/// this interface, never a vendor SDK — so the source is a one-swap change,
/// exactly like the [CrashReporter], FCM-push and certificate-pinning seams.
///
/// It is inert by default: the [NoopRemoteConfigService] returns the caller's
/// `fallback` for every lookup, so the effective configuration stays driven by
/// the compile-time [AppConfig] flags and the server-side feature toggles (the
/// runtime source of truth). When a backend is added (Firebase Remote Config is
/// the intended provider, docs/40 §31), drop in a `FirebaseRemoteConfigService`
/// that forwards these calls — no call site changes.
///
/// Contract for every `getX(key, fallback:)`: the value is returned only when the
/// remote source has a usable entry for `key`; otherwise `fallback` is returned.
/// Callers MUST pass a safe fallback so an un-activated (or unreachable) seam is
/// always well-defined. Keys are low-cardinality identifiers; never pass PII.
library;

abstract interface class RemoteConfigService {
  /// Perform any async SDK init (fetch + activate the first snapshot). A no-op
  /// for the Noop. Called once in `bootstrap`, awaited before `runApp`.
  Future<void> initialize();

  /// Re-fetch the latest values from the backend and activate them. A no-op for
  /// the Noop. Safe to call at runtime (e.g. on resume) once a real impl is in.
  Future<void> refresh();

  /// Read a boolean flag, or [fallback] when the source has no usable value.
  bool getBool(String key, {required bool fallback});

  /// Read a string value, or [fallback] when the source has no usable value.
  String getString(String key, {required String fallback});

  /// Read an integer value, or [fallback] when the source has no usable value.
  int getInt(String key, {required int fallback});

  /// Read a double value, or [fallback] when the source has no usable value.
  double getDouble(String key, {required double fallback});
}

/// The default, inert remote-config source used until a backend is compiled in.
/// Fetches nothing and every lookup returns the caller's `fallback`, so behaviour
/// is identical to a build with no remote config at all (safe for tests + prod).
class NoopRemoteConfigService implements RemoteConfigService {
  const NoopRemoteConfigService();

  @override
  Future<void> initialize() async {
    // Nothing to initialize — there is no remote source to fetch from.
  }

  @override
  Future<void> refresh() async {
    // Nothing to refresh — a real impl (e.g. Firebase) would fetch + activate.
  }

  @override
  bool getBool(String key, {required bool fallback}) => fallback;

  @override
  String getString(String key, {required String fallback}) => fallback;

  @override
  int getInt(String key, {required int fallback}) => fallback;

  @override
  double getDouble(String key, {required double fallback}) => fallback;
}

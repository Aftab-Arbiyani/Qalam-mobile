/// Remote feature-flag reconciliation (P7.4; docs/40 §31; docs/51 P7.1). The app
/// has THREE flag layers; this helper reconciles them into one `isEnabled` answer
/// so call sites don't re-implement the precedence:
///
///   1. Compile-time kill switch — `AppConfig.enable*` (from `--dart-define`). The
///      OUTER gate: when off, the capability is off regardless of anything remote.
///   2. Remote-tunable — [RemoteConfigService] (inert [NoopRemoteConfigService]
///      today; Firebase Remote Config once activated). The runtime dial.
///   3. Server-authoritative — per-feature flags fetched from the backend (e.g.
///      `GET /ai/features`), consumed by their own feature providers. Those remain
///      the source of truth for their domain; this helper does not override them.
///
/// Precedence: a compile-time kill switch that is OFF wins (returns false). When
/// the compile-time gate is on (or not applicable), the remote value decides,
/// falling back to the supplied default when the remote source has no entry.
///
/// Keys are the same dot-cased identifiers the backend uses (`feature.ai.enabled`
/// …); they are low-cardinality and never contain PII.
library;

import '../config/app_config.dart';
import '../config/remote_config.dart';

/// Reconciles the compile-time, remote, and (by reference) server flag layers.
class OperationsFeatureFlags {
  const OperationsFeatureFlags({
    required AppConfig config,
    required RemoteConfigService remoteConfig,
  }) : _config = config,
       _remoteConfig = remoteConfig;

  final AppConfig _config;
  final RemoteConfigService _remoteConfig;

  /// Compile-time kill switches by canonical flag key (the OUTER gate). A key
  /// absent here has no compile-time gate and is governed by remote + fallback.
  bool? _compileTimeGate(String key) {
    switch (key) {
      case 'feature.push.enabled':
        return _config.enablePush;
      case 'feature.ai.enabled':
        return _config.enableAi;
      case 'feature.monetization.enabled':
        return _config.enableMonetization;
      case 'feature.collaboration.enabled':
        return _config.enableCollaboration;
      default:
        return null;
    }
  }

  /// Whether [key] is enabled, reconciling the compile-time gate with the remote
  /// value. A compile-time gate that is OFF forces `false`; otherwise the remote
  /// value decides, defaulting to [fallback] when the remote source is silent.
  bool isEnabled(String key, {bool fallback = false}) {
    final bool? gate = _compileTimeGate(key);
    if (gate == false) {
      return false;
    }
    return _remoteConfig.getBool(key, fallback: gate ?? fallback);
  }

  /// A remote-tunable rollout percentage (0..100) for staged exposure, defaulting
  /// to [fallback] when the remote source has no entry.
  int rolloutPercentage(String key, {int fallback = 0}) =>
      _remoteConfig.getInt('$key.rollout', fallback: fallback);
}

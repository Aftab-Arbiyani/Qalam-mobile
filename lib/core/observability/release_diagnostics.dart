/// Release diagnostics seam (P7.4; docs/40 §28, §31). Exposes the resolved
/// [AppEnvironmentInfo] (version / buildNumber / platform / deviceModel) plus the
/// build channel (flavor), and produces a PII-free [diagnostics] map for a support
/// / about surface. It also attaches release + channel context to crash reports so
/// every report is grouped by the build it came from.
///
/// It is inert by default: the [NoopReleaseDiagnostics] uploads nothing but always
/// exposes the local facts (that is the whole point — a support screen works
/// offline). When a backend is added it can forward the same context; no call site
/// changes. All fields are id-only — NEVER PII.
library;

import '../config/app_environment_info.dart';
import 'crash_reporter.dart';

abstract interface class ReleaseDiagnostics {
  /// Whether diagnostics are actually uploaded to a backend. `false` for the Noop.
  bool get isEnabled;

  /// Perform any async SDK init. A no-op for the Noop.
  Future<void> initialize();

  /// The resolved runtime app + device facts (never PII).
  AppEnvironmentInfo get environment;

  /// The release identity — `version+buildNumber`.
  String get release;

  /// The build channel — the flavor wire value (`development` … `production`).
  String get channel;

  /// A flat, PII-free map for a support / about surface.
  Map<String, String> diagnostics();

  /// Attach release + channel context to [reporter] so crash reports are grouped
  /// by build. Id-only — never attaches PII.
  void attachTo(CrashReporter reporter);
}

/// The default, inert release diagnostics. Uploads nothing, but always exposes the
/// local release/channel facts and leaves a release breadcrumb on the crash
/// reporter so a local crash dump still shows which build produced it.
class NoopReleaseDiagnostics implements ReleaseDiagnostics {
  NoopReleaseDiagnostics({
    required AppEnvironmentInfo environment,
    required String channel,
  }) : _environment = environment,
       _channel = channel;

  final AppEnvironmentInfo _environment;
  final String _channel;

  @override
  bool get isEnabled => false;

  @override
  Future<void> initialize() async {
    // Nothing to initialize — the facts are resolved once at boot.
  }

  @override
  AppEnvironmentInfo get environment => _environment;

  @override
  String get release => _environment.fullVersion;

  @override
  String get channel => _channel;

  @override
  Map<String, String> diagnostics() => <String, String>{
    'app': _environment.appName,
    'release': release,
    'version': _environment.version,
    'buildNumber': _environment.buildNumber,
    'channel': _channel,
    'platform': _environment.platform,
    'deviceModel': _environment.deviceModel,
    'deviceType': _environment.deviceType,
  };

  @override
  void attachTo(CrashReporter reporter) {
    reporter.addBreadcrumb(
      'release $release · channel $_channel · ${_environment.platform}',
      category: 'release',
    );
  }
}

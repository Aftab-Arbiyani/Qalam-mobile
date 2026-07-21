/// Production telemetry umbrella (P7.4; docs/40 §29, §31). Composes the five
/// observability seams — [CrashReporter], [PerformanceMonitor],
/// [NetworkDiagnostics], [OperationalLogger] and [ReleaseDiagnostics] — behind a
/// single facade so `bootstrap` initializes them in one call and a debug/support
/// screen reads one [diagnostics] map. The app talks to THIS, never a vendor SDK,
/// so activating real telemetry is a one-swap change (exactly like the other
/// seams).
///
/// It is inert by default: the [NoopProductionTelemetry] uploads nothing (each
/// composed seam is itself inert), but it still wires the local behaviour — the
/// release context is attached to the crash reporter, breadcrumbs are kept, and
/// counters are available for a support surface. Everything is id-only — NEVER
/// PII (each seam enforces its own redaction).
library;

import 'crash_reporter.dart';
import 'network_diagnostics.dart';
import 'operational_logger.dart';
import 'performance_monitor.dart';
import 'release_diagnostics.dart';

abstract interface class ProductionTelemetry {
  /// Whether any composed seam ships to a backend. `false` when all are inert.
  bool get isEnabled;

  /// Initialize every composed seam and attach release context. Called once in
  /// `bootstrap`, awaited before `runApp`.
  Future<void> initialize();

  /// The composed seams (for feeding + a debug surface).
  CrashReporter get crashReporter;
  PerformanceMonitor get performance;
  NetworkDiagnostics get network;
  OperationalLogger get logger;
  ReleaseDiagnostics get release;

  /// A flat, PII-free diagnostics snapshot for a support / about surface.
  Map<String, Object?> diagnostics();
}

/// The default, inert production telemetry: composes the inert seams, attaches
/// release context to the crash reporter, and exposes local counters. Ships
/// nothing until each composed seam is swapped for a real implementation.
class NoopProductionTelemetry implements ProductionTelemetry {
  NoopProductionTelemetry({
    required this.crashReporter,
    required this.performance,
    required this.network,
    required this.logger,
    required this.release,
  });

  @override
  final CrashReporter crashReporter;
  @override
  final PerformanceMonitor performance;
  @override
  final NetworkDiagnostics network;
  @override
  final OperationalLogger logger;
  @override
  final ReleaseDiagnostics release;

  @override
  bool get isEnabled =>
      crashReporter.isEnabled ||
      performance.isEnabled ||
      network.isEnabled ||
      logger.isEnabled ||
      release.isEnabled;

  @override
  Future<void> initialize() async {
    await crashReporter.initialize();
    await performance.initialize();
    await network.initialize();
    await logger.initialize();
    await release.initialize();
    // Group every report by the build that produced it (id-only).
    release.attachTo(crashReporter);
  }

  @override
  Map<String, Object?> diagnostics() => <String, Object?>{
    'telemetryEnabled': isEnabled,
    ...release.diagnostics(),
  };
}

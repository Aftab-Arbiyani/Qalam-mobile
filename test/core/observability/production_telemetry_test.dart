import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_environment_info.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/observability/crash_reporter.dart';
import 'package:qalam_mobile/core/observability/network_diagnostics.dart';
import 'package:qalam_mobile/core/observability/operational_logger.dart';
import 'package:qalam_mobile/core/observability/performance_monitor.dart';
import 'package:qalam_mobile/core/observability/production_telemetry.dart';
import 'package:qalam_mobile/core/observability/release_diagnostics.dart';

void main() {
  NoopProductionTelemetry build() {
    final AppLogger logger = AppLogger(flavor: AppFlavor.development);
    final NoopCrashReporter reporter = NoopCrashReporter(logger: logger);
    return NoopProductionTelemetry(
      crashReporter: reporter,
      performance: NoopPerformanceMonitor(),
      network: NoopNetworkDiagnostics(),
      logger: NoopOperationalLogger(logger: logger, crashReporter: reporter),
      release: NoopReleaseDiagnostics(
        environment: AppEnvironmentInfo.unknown,
        channel: 'development',
      ),
    );
  }

  test('composes the inert seams and reports disabled', () async {
    final NoopProductionTelemetry telemetry = build();
    expect(telemetry.isEnabled, isFalse);
    await telemetry.initialize(); // must not throw; attaches release context
  });

  test('initialize attaches a release breadcrumb to the crash reporter', () async {
    final NoopProductionTelemetry telemetry = build();
    await telemetry.initialize();
    final CrashReporter reporter = telemetry.crashReporter;
    expect(reporter, isA<NoopCrashReporter>());
    expect((reporter as NoopCrashReporter).breadcrumbs, isNotEmpty);
  });

  test('diagnostics is a flat PII-free snapshot', () {
    final Map<String, Object?> d = build().diagnostics();
    expect(d['telemetryEnabled'], isFalse);
    expect(d.containsKey('release'), isTrue);
  });
}

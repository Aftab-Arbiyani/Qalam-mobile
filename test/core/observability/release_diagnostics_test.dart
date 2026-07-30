import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_environment_info.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/observability/crash_reporter.dart';
import 'package:qalam_mobile/core/observability/release_diagnostics.dart';

void main() {
  const AppEnvironmentInfo env = AppEnvironmentInfo(
    appName: 'Qalam',
    version: '1.2.0',
    buildNumber: '42',
    platform: 'android',
    deviceModel: 'Pixel',
    deviceType: 'mobile',
  );

  NoopReleaseDiagnostics build() =>
      NoopReleaseDiagnostics(environment: env, channel: AppFlavor.production.wire);

  test('is disabled and exposes local release facts', () async {
    final NoopReleaseDiagnostics rd = build();
    expect(rd.isEnabled, isFalse);
    await rd.initialize();
    expect(rd.release, '1.2.0+42');
    expect(rd.channel, 'production');
    expect(rd.environment.deviceModel, 'Pixel');
  });

  test('diagnostics map is flat, id-only, and complete', () {
    final Map<String, String> d = build().diagnostics();
    expect(d['release'], '1.2.0+42');
    expect(d['channel'], 'production');
    expect(d['platform'], 'android');
    expect(d.keys, containsAll(<String>['app', 'version', 'buildNumber', 'deviceType']));
  });

  test('attaches a release breadcrumb to the crash reporter', () {
    final NoopCrashReporter reporter =
        NoopCrashReporter(logger: AppLogger(flavor: AppFlavor.development));
    build().attachTo(reporter);
    expect(reporter.breadcrumbs.single.category, 'release');
    expect(reporter.breadcrumbs.single.message, contains('1.2.0+42'));
  });
}

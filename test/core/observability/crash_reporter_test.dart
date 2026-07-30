import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/observability/crash_reporter.dart';

void main() {
  final AppLogger logger = AppLogger(flavor: AppFlavor.development);

  test('NoopCrashReporter is disabled and uploads nothing', () async {
    final NoopCrashReporter reporter = NoopCrashReporter(logger: logger);
    expect(reporter.isEnabled, isFalse);
    await reporter.initialize();
    // Must not throw for a handled or fatal error.
    await reporter.recordError(StateError('x'), StackTrace.current);
    await reporter.recordError(StateError('y'), StackTrace.current, fatal: true);
    reporter.setUser('user-1');
    reporter.setUser(null);
  });

  test('breadcrumbs are retained in order and bounded to the cap', () {
    final NoopCrashReporter reporter = NoopCrashReporter(
      logger: logger,
      maxBreadcrumbs: 3,
    );
    reporter.addBreadcrumb('a', category: 'navigation');
    reporter.addBreadcrumb('b');
    reporter.addBreadcrumb('c');
    reporter.addBreadcrumb('d'); // evicts 'a'

    expect(
      reporter.breadcrumbs.map((Breadcrumb b) => b.message).toList(),
      <String>['b', 'c', 'd'],
    );
    expect(reporter.breadcrumbs.first.category, 'app');
  });

  test('carries release + environment metadata', () {
    final NoopCrashReporter reporter = NoopCrashReporter(
      logger: logger,
      release: '1.0.0+1',
      environment: 'production',
    );
    expect(reporter.release, '1.0.0+1');
    expect(reporter.environment, 'production');
  });
}

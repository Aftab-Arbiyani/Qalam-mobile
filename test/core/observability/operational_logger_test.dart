import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/observability/crash_reporter.dart';
import 'package:qalam_mobile/core/observability/operational_logger.dart';

void main() {
  final AppLogger logger = AppLogger(flavor: AppFlavor.development);

  test('formatOperationalLine tags the class and redacts context', () {
    final String line = formatOperationalLine(
      LogClass.access,
      'request',
      <String, Object?>{'path': '/pieces', 'token': 'secret-abc'},
    );
    expect(line, startsWith('[access] request'));
    expect(line, contains('/pieces'));
    expect(line, isNot(contains('secret-abc'))); // redacted
  });

  test('NoopOperationalLogger is disabled and logs without throwing', () async {
    final NoopOperationalLogger opLogger = NoopOperationalLogger(logger: logger);
    expect(opLogger.isEnabled, isFalse);
    await opLogger.initialize();
    opLogger.log(LogClass.application, 'boot complete');
    opLogger.log(LogClass.audit, 'admin action', context: <String, Object?>{'id': 'x'});
  });

  test('recordError forwards to the crash reporter', () async {
    final NoopCrashReporter reporter = NoopCrashReporter(logger: logger);
    final NoopOperationalLogger opLogger =
        NoopOperationalLogger(logger: logger, crashReporter: reporter);
    // Leave a breadcrumb so a fatal error has a trail to flush (no throw).
    reporter.addBreadcrumb('before');
    await opLogger.recordError(
      StateError('boom'),
      StackTrace.current,
      reason: 'test',
      fatal: true,
      context: <String, Object?>{'email': 'a@b.com'},
    );
  });
}

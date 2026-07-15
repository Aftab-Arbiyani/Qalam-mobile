/// Structured, leveled logging (docs/40 §29).
///
/// A thin wrapper over `package:logger` so the rest of the app depends on our
/// interface, not the library. Verbose logging is debug-only; release builds log
/// warnings and above. Redaction (log_redaction.dart) is applied by callers that
/// pass structured data (e.g. the logging interceptor).
library;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/app_flavor.dart';

class AppLogger {
  AppLogger({required AppFlavor flavor})
    : _logger = Logger(
        level: flavor.isProduction ? Level.warning : Level.debug,
        filter: ProductionFilter(),
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 6,
          lineLength: 100,
          colors: !flavor.isProduction,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      );

  final Logger _logger;

  void t(Object? message) => _logger.t(message);
  void d(Object? message) => _logger.d(message);
  void i(Object? message) => _logger.i(message);
  void w(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  void e(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// Record an uncaught/zone error. In release this is where a crash reporter
  /// (Sentry/Crashlytics) would also be notified — id-only, no PII (docs/40 §31).
  void recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) {
    _logger.e(reason ?? 'Uncaught error', error: error, stackTrace: stack);
    // Crash-reporter forwarding is wired in the reporting epic; kept id-only.
    if (kReleaseMode) {
      // No-op placeholder: reporting is gated on AppConfig.sentryDsn.
    }
  }

  void dispose() => _logger.close();
}

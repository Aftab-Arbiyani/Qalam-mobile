/// Structured, leveled logging (docs/40 §29).
///
/// A thin wrapper over `package:logger` so the rest of the app depends on our
/// interface, not the library. Verbose logging is debug-only; release builds log
/// warnings and above. Redaction (log_redaction.dart) is applied by callers that
/// pass structured data (e.g. the logging interceptor).
library;

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

  /// Trace — finest-grained, development-only diagnostics.
  void t(Object? message) => _logger.t(message);

  /// Debug — development diagnostics (stripped in production, level ≥ warning).
  void d(Object? message) => _logger.d(message);

  /// Info — notable lifecycle events (boot, sync drained).
  void i(Object? message) => _logger.i(message);

  /// Warning — recoverable/degraded conditions.
  void w(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  /// Error — an operation failed but the app continues.
  void e(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// Critical — a fatal/unrecoverable condition (uncaught error, corrupt state).
  /// Always emitted, even in production.
  void c(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);

  /// Record an uncaught/zone error to the console. Crash-reporter forwarding (to a
  /// DSN-gated [CrashReporter]) is done by the caller in `bootstrap`, so this stays
  /// vendor-agnostic — id-only, no PII (docs/40 §29, §31).
  void recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) {
    if (fatal) {
      _logger.f(reason ?? 'Fatal error', error: error, stackTrace: stack);
    } else {
      _logger.e(reason ?? 'Uncaught error', error: error, stackTrace: stack);
    }
  }

  void dispose() => _logger.close();
}

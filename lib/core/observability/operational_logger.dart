/// Operational logging seam (P7.4; docs/40 §29, §29.2). A thin classification
/// wrapper over [AppLogger] that tags every line with a log CLASS
/// (error / audit / access / application) and ALWAYS routes structured context
/// through [redactValue] before it reaches a log — so no call site has to
/// remember the redaction contract. Errors are additionally forwarded to the
/// [CrashReporter].
///
/// It is inert by default in the sense that the [NoopOperationalLogger] ships
/// nothing to a remote log aggregator; it still logs locally (via [AppLogger])
/// and forwards errors to the crash reporter, exactly like the [NoopCrashReporter]
/// keeps a local breadcrumb trail. When a log backend is added (e.g. Cloud
/// Logging / Datadog), drop in an impl that also uploads — no call site changes.
///
/// Message strings must be low-cardinality and PII-free (caller responsibility);
/// the structured [context] map is redacted here.
library;

import '../logging/app_logger.dart';
import '../logging/log_redaction.dart';
import 'crash_reporter.dart';

/// The operational class of a log line — mirrors the backend log taxonomy.
enum LogClass { error, audit, access, application }

/// Format a classified line with its structured [context] redacted. Exposed for
/// the Noop impl and for tests; the [message] must already be PII-free.
String formatOperationalLine(
  LogClass logClass,
  String message, [
  Map<String, Object?>? context,
]) {
  if (context == null || context.isEmpty) {
    return '[${logClass.name}] $message';
  }
  return '[${logClass.name}] $message ${redactValue(context)}';
}

abstract interface class OperationalLogger {
  /// Whether lines are actually shipped to a remote log backend. `false` for the
  /// Noop (which still logs locally + forwards errors to the crash reporter).
  bool get isEnabled;

  /// Perform any async SDK init. A no-op for the Noop.
  Future<void> initialize();

  /// Emit a classified log line. The [context] map is redacted before logging.
  void log(LogClass logClass, String message, {Map<String, Object?>? context});

  /// Record an error line and forward it to the crash reporter. `fatal` marks a
  /// crash vs. a soft error. The [context] map is redacted before logging.
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
    Map<String, Object?>? context,
  });
}

/// The default operational logger: classifies + redacts, delegates local output
/// to [AppLogger], and forwards errors to the [CrashReporter]. Ships nothing to a
/// remote log backend (that is the one-swap activation).
class NoopOperationalLogger implements OperationalLogger {
  NoopOperationalLogger({required AppLogger logger, CrashReporter? crashReporter})
    : _logger = logger,
      _crashReporter = crashReporter;

  final AppLogger _logger;
  final CrashReporter? _crashReporter;

  @override
  bool get isEnabled => false;

  @override
  Future<void> initialize() async {
    // Nothing to initialize — nothing is shipped to a remote backend.
  }

  @override
  void log(LogClass logClass, String message, {Map<String, Object?>? context}) {
    final String line = formatOperationalLine(logClass, message, context);
    switch (logClass) {
      case LogClass.error:
        _logger.e(line);
      case LogClass.audit:
      case LogClass.access:
        _logger.i(line);
      case LogClass.application:
        _logger.d(line);
    }
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
    Map<String, Object?>? context,
  }) async {
    if (context != null && context.isNotEmpty) {
      _logger.e(formatOperationalLine(LogClass.error, reason ?? 'error', context));
    }
    // Synchronous console record runs before the first await below.
    _logger.recordError(error, stack, reason: reason, fatal: fatal);
    await _crashReporter?.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }
}

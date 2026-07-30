/// Crash / error reporting seam (docs/40 §29, §31; M10 hardening). The app talks
/// to this interface, never to a vendor SDK — so the reporter is a one-swap change
/// (exactly like the FCM-push and certificate-pinning seams). It is DSN-gated: when
/// `AppConfig.sentryDsn` is empty the [NoopCrashReporter] is used (reporting off),
/// which still keeps a bounded, PII-free breadcrumb trail that a fatal error dumps
/// to the log for local diagnosis. When a DSN is configured, drop in a
/// `SentryCrashReporter` (add `sentry_flutter`, forward these calls) — no call site
/// changes.
///
/// Wiring lives in `bootstrap`: `FlutterError.onError`, `PlatformDispatcher.onError`
/// and the `runZonedGuarded` handler all forward here with release + environment
/// metadata attached. Reports and breadcrumbs are id-only — NEVER pass tokens,
/// emails, or request bodies (redaction is the caller's responsibility, mirroring
/// the log redaction list).
library;

import '../logging/app_logger.dart';

/// A single breadcrumb — a low-cardinality trace event leading up to a crash.
class Breadcrumb {
  const Breadcrumb({
    required this.message,
    required this.timestamp,
    this.category = 'app',
  });

  final String message;
  final String category;
  final DateTime timestamp;

  @override
  String toString() => '[$category] $message';
}

abstract interface class CrashReporter {
  /// Whether errors are actually uploaded to a backend. `false` for the Noop.
  bool get isEnabled;

  /// Perform any async SDK init. A no-op for the Noop.
  Future<void> initialize();

  /// Record an uncaught/handled error. `fatal` marks a crash vs. a soft error.
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  });

  /// Leave a breadcrumb (navigation, sync event, lifecycle change). Keep it
  /// low-cardinality and PII-free.
  void addBreadcrumb(String message, {String category = 'app'});

  /// Associate an opaque user id (never an email/name) for grouping, or clear it.
  void setUser(String? id);
}

/// The default, inert reporter used when no DSN is configured. It uploads nothing
/// but keeps a bounded in-memory breadcrumb trail; on a FATAL error it flushes the
/// trail to the logger so a local/staging crash is still diagnosable.
class NoopCrashReporter implements CrashReporter {
  NoopCrashReporter({
    required AppLogger logger,
    this.release = '',
    this.environment = '',
    this.maxBreadcrumbs = 50,
  }) : _logger = logger;

  final AppLogger _logger;
  final String release;
  final String environment;
  final int maxBreadcrumbs;

  final List<Breadcrumb> _breadcrumbs = <Breadcrumb>[];

  /// The retained trail (oldest first) — exposed for diagnostics + tests.
  List<Breadcrumb> get breadcrumbs => List<Breadcrumb>.unmodifiable(_breadcrumbs);

  @override
  bool get isEnabled => false;

  @override
  Future<void> initialize() async {
    // Nothing to initialize — reporting is disabled without a DSN.
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (fatal && _breadcrumbs.isNotEmpty) {
      _logger.w(
        'crash breadcrumbs (${_breadcrumbs.length}): '
        '${_breadcrumbs.map((Breadcrumb b) => b.toString()).join(' → ')}',
      );
    }
    // Upload is intentionally skipped — a SentryCrashReporter would send here.
  }

  @override
  void addBreadcrumb(String message, {String category = 'app'}) {
    _breadcrumbs.add(
      Breadcrumb(
        message: message,
        category: category,
        timestamp: DateTime.now(),
      ),
    );
    if (_breadcrumbs.length > maxBreadcrumbs) {
      _breadcrumbs.removeAt(0);
    }
  }

  @override
  void setUser(String? id) {
    // No-op: nothing is uploaded, so there is nothing to tag.
  }
}

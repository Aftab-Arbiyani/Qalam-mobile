/// Network diagnostics seam (P7.4; docs/40 §13.2, §29). Every request the app
/// makes is summarised here from the single Dio logging interceptor — the one
/// funnel for network telemetry. The app talks to this interface, never a vendor
/// SDK, so the backend is a one-swap change like the other observability seams.
///
/// Only the request SHAPE is recorded — method, `uri.path` (no query string),
/// status code, duration, the `x-request-id` correlation id, and an ok flag.
/// NEVER pass request/response bodies, headers, query strings, or any PII; the
/// caller strips those (mirrors the log-redaction contract).
///
/// It is inert by default: the [NoopNetworkDiagnostics] uploads nothing but keeps
/// a bounded in-memory ring plus running counters (request/error counts, a rough
/// error rate and a p95 latency) so a debug/support screen has local numbers.
library;

import 'package:flutter/foundation.dart';

/// A single request summary — id + shape only, never bodies/PII.
@immutable
class NetworkSample {
  const NetworkSample({
    required this.method,
    required this.path,
    required this.statusCode,
    required this.durationMs,
    required this.ok,
    required this.timestamp,
    this.requestId,
  });

  final String method;
  final String path;
  final int statusCode;
  final int durationMs;
  final bool ok;

  /// The `x-request-id` correlation id, when the response carried one.
  final String? requestId;
  final DateTime timestamp;

  @override
  String toString() => '$method $path → $statusCode (${durationMs}ms)';
}

abstract interface class NetworkDiagnostics {
  /// Whether summaries are actually uploaded to a backend. `false` for the Noop.
  bool get isEnabled;

  /// Perform any async SDK init. A no-op for the Noop.
  Future<void> initialize();

  /// Record one completed request. Callers MUST pass only [path] (`uri.path`,
  /// never the query string) and the correlation id — never bodies/headers/PII.
  void recordRequest({
    required String method,
    required String path,
    required int statusCode,
    required int durationMs,
    required bool ok,
    String? requestId,
  });
}

/// The default, inert diagnostics sink used until a backend is compiled in. It
/// uploads nothing but keeps a bounded ring + counters for local diagnosis.
class NoopNetworkDiagnostics implements NetworkDiagnostics {
  NoopNetworkDiagnostics({this.maxSamples = 100});

  final int maxSamples;
  final List<NetworkSample> _samples = <NetworkSample>[];
  int _requestCount = 0;
  int _errorCount = 0;

  /// The retained summaries (oldest first) — exposed for diagnostics + tests.
  List<NetworkSample> get samples => List<NetworkSample>.unmodifiable(_samples);

  /// Total requests recorded since boot (not bounded by the ring).
  int get requestCount => _requestCount;

  /// Total non-ok requests recorded since boot.
  int get errorCount => _errorCount;

  /// Error rate over all recorded requests, in `[0, 1]`.
  double get errorRate => _requestCount == 0 ? 0.0 : _errorCount / _requestCount;

  /// A rough p95 latency over the retained ring (0 when empty).
  int get p95DurationMs {
    if (_samples.isEmpty) {
      return 0;
    }
    final List<int> durations =
        _samples.map((NetworkSample s) => s.durationMs).toList()..sort();
    final int index = ((durations.length - 1) * 0.95).round();
    return durations[index];
  }

  @override
  bool get isEnabled => false;

  @override
  Future<void> initialize() async {
    // Nothing to initialize — nothing is uploaded without a backend.
  }

  @override
  void recordRequest({
    required String method,
    required String path,
    required int statusCode,
    required int durationMs,
    required bool ok,
    String? requestId,
  }) {
    _requestCount++;
    if (!ok) {
      _errorCount++;
    }
    _samples.add(
      NetworkSample(
        method: method,
        path: path,
        statusCode: statusCode,
        durationMs: durationMs,
        ok: ok,
        requestId: requestId,
        timestamp: DateTime.now(),
      ),
    );
    if (_samples.length > maxSamples) {
      _samples.removeAt(0);
    }
    // Upload is intentionally skipped — a real backend would send here.
  }
}

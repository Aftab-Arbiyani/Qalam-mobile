/// Performance monitoring seam (P7.4; docs/43 §10, docs/40 §36). The app records
/// cold-start, frame and network timings through this interface, never a vendor
/// SDK — so the backend is a one-swap change, exactly like the [CrashReporter],
/// remote-config and screenshot-protection seams.
///
/// It is inert by default: the [NoopPerformanceMonitor] uploads nothing but keeps
/// a small bounded in-memory ring of the most recent samples so a debug/support
/// screen can show timings locally. When an APM backend is added (Firebase
/// Performance is the intended provider), drop in a `FirebasePerformanceMonitor`
/// that forwards these calls — no call site changes.
///
/// Metric + trace names are low-cardinality identifiers; NEVER pass PII.
library;

import 'package:flutter/foundation.dart';

/// Canonical metric names so producers and a future dashboard agree on keys.
abstract final class PerfMetric {
  /// Cold-start (bootstrap) duration — the `flutter.startup.cold` budget.
  static const String coldStartMs = 'flutter.startup.cold';

  /// A single UI frame build+raster duration.
  static const String frameMs = 'flutter.frame';

  /// A single network request round-trip (fed from [NetworkDiagnostics] callers).
  static const String networkRequestMs = 'network.request';
}

/// A single recorded metric — a value with a unit and a timestamp.
@immutable
class PerfSample {
  const PerfSample({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  final String name;
  final num value;
  final String unit;
  final DateTime timestamp;

  @override
  String toString() => '$name=$value$unit';
}

/// A running trace started via [PerformanceMonitor.startTrace]. Call [stop] once
/// to record its elapsed wall-clock duration; stopping again is a no-op.
abstract interface class PerfTrace {
  /// The trace name (low-cardinality, PII-free).
  String get name;

  /// Stop the trace and record its elapsed duration as a metric.
  void stop();
}

abstract interface class PerformanceMonitor {
  /// Whether samples are actually uploaded to a backend. `false` for the Noop.
  bool get isEnabled;

  /// Perform any async SDK init. A no-op for the Noop.
  Future<void> initialize();

  /// Start a named trace; call [PerfTrace.stop] to record its duration.
  PerfTrace startTrace(String name);

  /// Record a single metric sample (a [value] with a [unit], default `ms`).
  void recordMetric(String name, num value, {String unit = 'ms'});
}

/// The default, inert monitor used until an APM backend is compiled in. It
/// uploads nothing but retains a bounded ring of recent samples for local
/// diagnosis (safe for tests + prod).
class NoopPerformanceMonitor implements PerformanceMonitor {
  NoopPerformanceMonitor({this.maxSamples = 100});

  final int maxSamples;
  final List<PerfSample> _samples = <PerfSample>[];

  /// The retained samples (oldest first) — exposed for diagnostics + tests.
  List<PerfSample> get samples => List<PerfSample>.unmodifiable(_samples);

  @override
  bool get isEnabled => false;

  @override
  Future<void> initialize() async {
    // Nothing to initialize — monitoring uploads nothing without a backend.
  }

  @override
  PerfTrace startTrace(String name) => _NoopPerfTrace(name, this);

  @override
  void recordMetric(String name, num value, {String unit = 'ms'}) {
    _samples.add(
      PerfSample(
        name: name,
        value: value,
        unit: unit,
        timestamp: DateTime.now(),
      ),
    );
    if (_samples.length > maxSamples) {
      _samples.removeAt(0);
    }
    // Upload is intentionally skipped — a real APM would send here.
  }
}

class _NoopPerfTrace implements PerfTrace {
  _NoopPerfTrace(this.name, this._monitor);

  @override
  final String name;

  final NoopPerformanceMonitor _monitor;
  final Stopwatch _watch = Stopwatch()..start();
  bool _stopped = false;

  @override
  void stop() {
    if (_stopped) {
      return;
    }
    _stopped = true;
    _watch.stop();
    _monitor.recordMetric(name, _watch.elapsedMilliseconds);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/observability/network_diagnostics.dart';

void main() {
  NoopNetworkDiagnostics build() => NoopNetworkDiagnostics(maxSamples: 3);

  void record(NoopNetworkDiagnostics d, {required bool ok, int durationMs = 100}) {
    d.recordRequest(
      method: 'GET',
      path: '/pieces',
      statusCode: ok ? 200 : 500,
      durationMs: durationMs,
      ok: ok,
      requestId: 'req-1',
    );
  }

  test('is disabled and initializes without throwing', () async {
    final NoopNetworkDiagnostics d = build();
    expect(d.isEnabled, isFalse);
    await d.initialize();
  });

  test('counts requests + errors and computes an error rate', () {
    final NoopNetworkDiagnostics d = build();
    record(d, ok: true);
    record(d, ok: false);
    expect(d.requestCount, 2);
    expect(d.errorCount, 1);
    expect(d.errorRate, 0.5);
  });

  test('retains a bounded ring but keeps lifetime counters', () {
    final NoopNetworkDiagnostics d = build();
    for (int i = 0; i < 5; i++) {
      record(d, ok: true);
    }
    expect(d.samples, hasLength(3)); // ring capped
    expect(d.requestCount, 5); // counter unbounded
  });

  test('computes a p95 latency over the ring', () {
    final NoopNetworkDiagnostics d = build();
    record(d, ok: true, durationMs: 10);
    record(d, ok: true, durationMs: 20);
    record(d, ok: true, durationMs: 30);
    expect(d.p95DurationMs, 30);
  });
}

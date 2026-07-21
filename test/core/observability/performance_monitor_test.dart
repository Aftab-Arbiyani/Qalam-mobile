import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/observability/performance_monitor.dart';

void main() {
  test('NoopPerformanceMonitor is disabled and initializes without throwing', () async {
    final NoopPerformanceMonitor monitor = NoopPerformanceMonitor();
    expect(monitor.isEnabled, isFalse);
    await monitor.initialize();
  });

  test('records metrics and retains a bounded ring', () {
    final NoopPerformanceMonitor monitor = NoopPerformanceMonitor(maxSamples: 2);
    monitor.recordMetric(PerfMetric.coldStartMs, 1200);
    monitor.recordMetric(PerfMetric.frameMs, 12);
    monitor.recordMetric(PerfMetric.networkRequestMs, 300); // evicts the first
    expect(monitor.samples, hasLength(2));
    expect(monitor.samples.first.name, PerfMetric.frameMs);
  });

  test('a trace records its elapsed duration on stop (idempotent)', () {
    final NoopPerformanceMonitor monitor = NoopPerformanceMonitor();
    final PerfTrace trace = monitor.startTrace('boot');
    trace.stop();
    trace.stop(); // no-op
    expect(monitor.samples.where((PerfSample s) => s.name == 'boot'), hasLength(1));
    expect(monitor.samples.single.unit, 'ms');
  });
}

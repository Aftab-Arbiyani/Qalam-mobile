/// Writer growth over time (docs/40 §30) — decoded from `GET /analytics/me/growth`
/// (`GrowthSeriesDto`). Each [GrowthPoint] is a CUMULATIVE snapshot of the writer's
/// running totals at a `periodStart`; per-period deltas are derived client-side by
/// diffing consecutive points. Snapshots are generated on-demand server-side (no
/// cron), so a creator's series is frequently EMPTY — an empty chart is the normal
/// zero-state, not an error. Metric keys mirror the snapshot writer exactly.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'growth_series.freezed.dart';
part 'growth_series.g.dart';

/// The metric keys present in a growth snapshot's `metrics` map (server-authored).
enum GrowthMetric {
  views('views', 'Views'),
  uniqueViews('uniqueViews', 'Unique views'),
  reads('reads', 'Reads'),
  completedReads('completedReads', 'Completed reads'),
  followersGained('followersGained', 'Followers'),
  piecesPublished('piecesPublished', 'Published');

  const GrowthMetric(this.key, this.label);
  final String key;
  final String label;
}

@freezed
abstract class GrowthPoint with _$GrowthPoint {
  const GrowthPoint._();

  const factory GrowthPoint({
    @Default('') String periodStart,
    @Default(<String, num>{}) Map<String, num> metrics,
  }) = _GrowthPoint;

  factory GrowthPoint.fromJson(Map<String, dynamic> json) =>
      _$GrowthPointFromJson(json);

  /// The snapshot date, or null if the wire value is unparseable.
  DateTime? get date => DateTime.tryParse(periodStart);

  /// The cumulative value of [metric] at this point (missing → 0).
  num valueOf(GrowthMetric metric) => metrics[metric.key] ?? 0;
}

@freezed
abstract class GrowthSeries with _$GrowthSeries {
  const GrowthSeries._();

  const factory GrowthSeries({
    @Default('daily') String period,
    @Default(<GrowthPoint>[]) List<GrowthPoint> points,
  }) = _GrowthSeries;

  factory GrowthSeries.fromJson(Map<String, dynamic> json) =>
      _$GrowthSeriesFromJson(json);

  static const GrowthSeries empty = GrowthSeries();

  bool get isEmpty => points.isEmpty;

  /// The cumulative series for one metric, oldest→newest, as chart y-values.
  List<double> cumulative(GrowthMetric metric) => <double>[
    for (final GrowthPoint p in points) p.valueOf(metric).toDouble(),
  ];

  /// Per-period deltas for one metric (diff of consecutive cumulative points).
  /// The first period keeps its cumulative value as the delta baseline.
  List<double> deltas(GrowthMetric metric) {
    final List<double> out = <double>[];
    double? prev;
    for (final GrowthPoint p in points) {
      final double v = p.valueOf(metric).toDouble();
      out.add(prev == null ? v : (v - prev).clamp(0, double.infinity));
      prev = v;
    }
    return out;
  }

  /// Total gain of [metric] across the whole series (last − first cumulative).
  double totalGain(GrowthMetric metric) {
    if (points.isEmpty) return 0;
    final double first = points.first.valueOf(metric).toDouble();
    final double last = points.last.valueOf(metric).toDouble();
    return (last - first).clamp(0, double.infinity);
  }
}

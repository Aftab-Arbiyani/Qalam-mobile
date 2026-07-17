/// The analytics date-range filter (docs/40 §30). The frozen `v1` self-scoped
/// creator endpoints (`/analytics/me`) are LIFETIME-only, so a range never filters
/// the headline totals — it selects the growth SERIES window by mapping each preset
/// onto the growth query's `period` + `points` (the only range knob `v1` exposes to
/// a creator). `points` is clamped to the server's 1..90 bound.
library;

import 'package:flutter/foundation.dart';

/// The supported presets (docs/40 §30 range list) plus a custom window.
enum AnalyticsRangePreset {
  today('Today', 'daily', 1),
  last7('Last 7 days', 'daily', 7),
  last30('Last 30 days', 'daily', 30),
  last90('Last 90 days', 'daily', 90),
  lastYear('Last year', 'monthly', 12),
  custom('Custom range', 'daily', 30);

  const AnalyticsRangePreset(this.label, this.period, this.points);

  /// Human label for the selector chip.
  final String label;

  /// The growth-query granularity this preset requests.
  final String period;

  /// The growth-query snapshot count this preset requests (custom overrides).
  final int points;
}

/// The maximum `points` the backend growth query accepts.
const int kMaxGrowthPoints = 90;

@immutable
class AnalyticsRange {
  const AnalyticsRange({required this.preset, this.from, this.to});

  /// The default landing range.
  const AnalyticsRange.last30() : preset = AnalyticsRangePreset.last30, from = null, to = null;

  final AnalyticsRangePreset preset;

  /// Custom-range bounds — only meaningful when [preset] is `custom`.
  final DateTime? from;
  final DateTime? to;

  String get label {
    if (preset == AnalyticsRangePreset.custom && from != null && to != null) {
      return '${_ymd(from!)} – ${_ymd(to!)}';
    }
    return preset.label;
  }

  /// The growth-series granularity to request.
  String get growthPeriod => preset.period;

  /// The number of snapshot points to request, clamped to the server bound. For a
  /// custom window it is the inclusive day span; otherwise the preset's default.
  int get growthPoints {
    if (preset == AnalyticsRangePreset.custom && from != null && to != null) {
      final int days = to!.difference(from!).inDays.abs() + 1;
      return days.clamp(1, kMaxGrowthPoints);
    }
    return preset.points.clamp(1, kMaxGrowthPoints);
  }

  AnalyticsRange copyWith({
    AnalyticsRangePreset? preset,
    DateTime? from,
    DateTime? to,
  }) => AnalyticsRange(
    preset: preset ?? this.preset,
    from: from ?? this.from,
    to: to ?? this.to,
  );

  @override
  bool operator ==(Object other) =>
      other is AnalyticsRange &&
      other.preset == preset &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(preset, from, to);

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

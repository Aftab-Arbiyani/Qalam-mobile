/// The selected analytics date range (docs/40 §30) — a tiny notifier the creator
/// dashboard's range selector drives. Changing it re-runs only the growth-series
/// provider (the lifetime cards are range-independent), so switching ranges never
/// refetches the headline totals.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/value_objects/analytics_range.dart';

part 'analytics_range_controller.g.dart';

@riverpod
class AnalyticsRangeController extends _$AnalyticsRangeController {
  @override
  AnalyticsRange build() => const AnalyticsRange.last30();

  /// Pick a preset (Today / Last 7 / 30 / 90 days / Last year).
  void select(AnalyticsRangePreset preset) =>
      state = AnalyticsRange(preset: preset);

  /// Pick a custom window (clamped to the growth query's 90-point bound).
  void selectCustom(DateTime from, DateTime to) {
    final bool ordered = !from.isAfter(to);
    state = AnalyticsRange(
      preset: AnalyticsRangePreset.custom,
      from: ordered ? from : to,
      to: ordered ? to : from,
    );
  }
}

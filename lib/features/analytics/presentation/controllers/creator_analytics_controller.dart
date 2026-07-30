/// Creator Analytics controllers (docs/40 §30). Two independent async providers so
/// the range selector only re-runs the growth series:
///
///  * [writerAnalytics] — the LIFETIME headline aggregate (`GET /analytics/me`),
///    range-independent;
///  * [writerGrowth] — the range-scoped growth SERIES (`GET /analytics/me/growth`),
///    re-fetched whenever the selected [AnalyticsRange] changes.
///
/// Both surface a thrown [Failure] as `AsyncError` so the screen renders the
/// standard loading / empty / error states (charts included).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/growth_series.dart';
import '../../domain/entities/piece_analytics.dart';
import '../../domain/entities/writer_analytics.dart';
import '../../domain/value_objects/analytics_range.dart';
import '../providers/analytics_providers.dart';
import 'analytics_range_controller.dart';

part 'creator_analytics_controller.g.dart';

@riverpod
Future<WriterAnalytics> writerAnalytics(Ref ref) async {
  final Result<WriterAnalytics> result = await ref
      .watch(analyticsRepositoryProvider)
      .writerAnalytics();
  return result.fold(
    (WriterAnalytics v) => v,
    (Failure f) => throw f,
  );
}

@riverpod
Future<GrowthSeries> writerGrowth(Ref ref) async {
  final AnalyticsRange range = ref.watch(analyticsRangeControllerProvider);
  final Result<GrowthSeries> result = await ref
      .watch(analyticsRepositoryProvider)
      .writerGrowth(period: range.growthPeriod, points: range.growthPoints);
  return result.fold(
    (GrowthSeries v) => v,
    (Failure f) => throw f,
  );
}

/// Owner-only per-piece analytics, keyed by piece id.
@riverpod
Future<PieceAnalytics> pieceAnalytics(Ref ref, String pieceId) async {
  final Result<PieceAnalytics> result = await ref
      .watch(analyticsRepositoryProvider)
      .pieceAnalytics(pieceId);
  return result.fold(
    (PieceAnalytics v) => v,
    (Failure f) => throw f,
  );
}

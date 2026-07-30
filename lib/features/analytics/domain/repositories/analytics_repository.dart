/// The analytics repository contract (docs/40 §17) — the boundary between the
/// analytics presentation layer and the wire. Returns domain [Result]s (never a
/// DTO or an HTTP status) and tolerates offline by serving the last cached
/// aggregate. Reuses the frozen `v1` self-scoped analytics endpoints only —
/// no invented contracts.
library;

import '../../../../core/utils/result.dart';
import '../entities/growth_series.dart';
import '../entities/piece_analytics.dart';
import '../entities/reader_analytics.dart';
import '../entities/writer_analytics.dart';

abstract interface class AnalyticsRepository {
  /// Lifetime creator aggregate — `GET /analytics/me`.
  Future<Result<WriterAnalytics>> writerAnalytics();

  /// Growth series — `GET /analytics/me/growth?period=&points=`.
  Future<Result<GrowthSeries>> writerGrowth({
    required String period,
    required int points,
  });

  /// Reader aggregate — `GET /analytics/readers/me`.
  Future<Result<ReaderAnalytics>> readerAnalytics();

  /// Owner-only per-piece analytics — `GET /analytics/pieces/:id`.
  Future<Result<PieceAnalytics>> pieceAnalytics(String pieceId);
}

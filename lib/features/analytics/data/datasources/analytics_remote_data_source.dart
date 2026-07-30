/// Analytics remote data source (docs/40 §17.1) — the only place the analytics
/// feature touches the wire. Every read is a single decoded object off the frozen
/// envelope; entities decode themselves (`Entity.fromJson`). Throws [ApiException]
/// for the repository to translate; knows nothing of caching or `Failure`.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../domain/entities/growth_series.dart';
import '../../domain/entities/piece_analytics.dart';
import '../../domain/entities/reader_analytics.dart';
import '../../domain/entities/writer_analytics.dart';

class AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<WriterAnalytics> writerAnalytics() => _api.get<WriterAnalytics>(
    ApiPaths.analyticsMe,
    decode: WriterAnalytics.fromJson,
  );

  Future<GrowthSeries> writerGrowth({
    required String period,
    required int points,
  }) => _api.get<GrowthSeries>(
    ApiPaths.analyticsMeGrowth,
    query: <String, dynamic>{'period': period, 'points': points},
    decode: GrowthSeries.fromJson,
  );

  Future<ReaderAnalytics> readerAnalytics() => _api.get<ReaderAnalytics>(
    ApiPaths.analyticsReadersMe,
    decode: ReaderAnalytics.fromJson,
  );

  Future<PieceAnalytics> pieceAnalytics(String pieceId) =>
      _api.get<PieceAnalytics>(
        ApiPaths.analyticsPiece(pieceId),
        decode: PieceAnalytics.fromJson,
      );
}

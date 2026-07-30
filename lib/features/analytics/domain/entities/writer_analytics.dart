/// Creator (writer) analytics (docs/40 §30) — the lifetime aggregate the frozen
/// `v1` `GET /analytics/me` returns. These are ALL-TIME figures: the endpoint has
/// no date-range filter (that model exists only on the admin analytics surface, a
/// permission a normal creator lacks), so the range selector on the dashboard
/// scopes the growth SERIES, not these headline totals. Decoded straight from the
/// envelope `data` — field names mirror `WriterAnalyticsDto` exactly.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'writer_analytics.freezed.dart';
part 'writer_analytics.g.dart';

@freezed
abstract class WriterAnalytics with _$WriterAnalytics {
  const factory WriterAnalytics({
    @Default(0) int totalViews,
    @Default(0) int uniqueViews,
    @Default(0) int reads,

    /// Completed reads ÷ views, 0.0–1.0.
    @Default(0) double completionRate,
    @Default(0) int totalReadSeconds,
    @Default(0) int averageReadTimeSeconds,
    @Default(0) int followersGained,
    @Default(0) int piecesPublished,
    @Default(0) int piecesArchived,
    @Default(0) int commentsReceived,
    @Default(0) int clapsReceived,
    @Default(0) int bookmarksReceived,
    @Default(0) int responsesReceived,
    MostPopularPiece? mostPopularPiece,
  }) = _WriterAnalytics;

  factory WriterAnalytics.fromJson(Map<String, dynamic> json) =>
      _$WriterAnalyticsFromJson(json);

  /// An empty instance — the graceful fallback when the endpoint is unreachable
  /// but the surface should still render its zero-state cards.
  static const WriterAnalytics empty = WriterAnalytics();
}

@freezed
abstract class MostPopularPiece with _$MostPopularPiece {
  const factory MostPopularPiece({
    required String pieceId,
    @Default('') String title,
    String? slug,
    @Default(0) int views,
  }) = _MostPopularPiece;

  factory MostPopularPiece.fromJson(Map<String, dynamic> json) =>
      _$MostPopularPieceFromJson(json);
}

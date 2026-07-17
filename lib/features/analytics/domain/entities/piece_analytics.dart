/// Per-piece analytics (docs/40 §30) — the owner-only `GET /analytics/pieces/:id`
/// (`PieceAnalyticsDto`). Powers the per-piece performance detail reachable from a
/// writer's own published pieces. Field names mirror the DTO exactly.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'piece_analytics.freezed.dart';
part 'piece_analytics.g.dart';

@freezed
abstract class PieceAnalytics with _$PieceAnalytics {
  const factory PieceAnalytics({
    @Default('') String pieceId,
    @Default(0) int views,
    @Default(0) int uniqueViews,
    @Default(0) int reads,

    /// Completed reads ÷ views, 0.0–1.0.
    @Default(0) double completionRate,
    @Default(0) int averageReadTimeSeconds,
    @Default(0) int claps,
    @Default(0) int comments,
    @Default(0) int responses,
    @Default(0) int bookmarks,
    @Default(0) int shares,
    @Default(ReadingSources()) ReadingSources readingSources,
    String? publishedAt,
  }) = _PieceAnalytics;

  factory PieceAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PieceAnalyticsFromJson(json);
}

@freezed
abstract class ReadingSources with _$ReadingSources {
  const factory ReadingSources({
    @Default(0) int internal,
    @Default(0) int external,
    @Default(0) int copyLink,
  }) = _ReadingSources;

  factory ReadingSources.fromJson(Map<String, dynamic> json) =>
      _$ReadingSourcesFromJson(json);
}

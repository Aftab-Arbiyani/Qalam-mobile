/// Reader analytics (docs/40 §30) — the authoritative, cross-device aggregate the
/// frozen `v1` `GET /analytics/readers/me` returns. The mobile Reading Analytics
/// surface COMBINES this with device-local reading history (Continue Reading +
/// Weekly Activity, which the backend does not expose) and the bookmarks count.
/// Field names mirror `ReaderAnalyticsDto` exactly.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ranked_item.dart';

part 'reader_analytics.freezed.dart';
part 'reader_analytics.g.dart';

@freezed
abstract class ReaderAnalytics with _$ReaderAnalytics {
  const factory ReaderAnalytics({
    @Default(0) int piecesRead,
    @Default(0) int readingTimeSeconds,
    @Default(0) int completedReads,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(<RankedItem>[]) List<RankedItem> favoriteGenres,
    @Default(<RankedItem>[]) List<RankedItem> favoriteLanguages,
  }) = _ReaderAnalytics;

  factory ReaderAnalytics.fromJson(Map<String, dynamic> json) =>
      _$ReaderAnalyticsFromJson(json);

  static const ReaderAnalytics empty = ReaderAnalytics();
}

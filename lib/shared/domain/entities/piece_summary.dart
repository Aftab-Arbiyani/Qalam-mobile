/// The feed/list unit — a piece card summary (docs/40 §6, §19.1). Mirrors the
/// backend `FeedItemDto` (feed + discover pieces share it). Not the full reading
/// aggregate (that is `PieceDetail` in the reading feature) — a card carries only
/// what the list needs. Persisted to the Hive cache as its own JSON shape.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';
import 'author.dart';
import 'taxonomy.dart';

part 'piece_summary.freezed.dart';
part 'piece_summary.g.dart';

/// The public engagement counts shown on a feed card (`FeedStatsDto`).
@freezed
abstract class PieceSummaryStats with _$PieceSummaryStats {
  const factory PieceSummaryStats({
    @Default(0) int likes,
    @Default(0) int claps,
    @Default(0) int comments,
    @Default(0) int responses,
  }) = _PieceSummaryStats;

  factory PieceSummaryStats.fromJson(Map<String, dynamic> json) =>
      _$PieceSummaryStatsFromJson(json);
}

@freezed
abstract class PieceSummary with _$PieceSummary {
  const PieceSummary._();

  const factory PieceSummary({
    required String id,
    required String title,
    required Author author,
    required LanguageRef language,
    String? slug,
    String? subtitle,
    String? featuredQuote,
    String? coverImageKey,
    GenreRef? genre,
    @Default(PieceSummaryStats()) PieceSummaryStats stats,
    @Default(Visibility.public) Visibility visibility,
    @Default(0) int wordCount,
    @Default(0) int readingTimeSeconds,
    DateTime? publishedAt,
  }) = _PieceSummary;

  factory PieceSummary.fromJson(Map<String, dynamic> json) =>
      _$PieceSummaryFromJson(json);

  /// The piece's text direction, from its language (drives per-content dir).
  TextDirectionKind get direction => language.direction;

  /// Reading time rounded up to whole minutes (min 1 for any non-empty piece).
  int get readingTimeMinutes => readingTimeSeconds <= 0
      ? 0
      : ((readingTimeSeconds + 59) ~/ 60).clamp(1, 1 << 30);
}

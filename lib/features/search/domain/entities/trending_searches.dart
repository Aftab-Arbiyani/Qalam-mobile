/// What people are searching and engaging with now (docs/40 E8) — mirrors the
/// backend `TrendingSearchesDto` from `GET /search/trending`: popular keywords
/// plus popular tags / genres / writers. Reuses the shared trend + writer read
/// models. Cached (Redis server-side, and in the Hive cache client-side) so the
/// search zero-state paints instantly and works offline.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';

part 'trending_searches.freezed.dart';
part 'trending_searches.g.dart';

@freezed
abstract class TrendingKeyword with _$TrendingKeyword {
  const factory TrendingKeyword({
    required String keyword,
    @Default(0) int searchCount,
  }) = _TrendingKeyword;

  factory TrendingKeyword.fromJson(Map<String, dynamic> json) =>
      _$TrendingKeywordFromJson(json);
}

@freezed
abstract class TrendingSearches with _$TrendingSearches {
  const TrendingSearches._();

  const factory TrendingSearches({
    @Default(<TrendingKeyword>[]) List<TrendingKeyword> keywords,
    @Default(<TrendingTag>[]) List<TrendingTag> tags,
    @Default(<TrendingGenre>[]) List<TrendingGenre> genres,
    @Default(<WriterSummary>[]) List<WriterSummary> writers,
  }) = _TrendingSearches;

  factory TrendingSearches.fromJson(Map<String, dynamic> json) =>
      _$TrendingSearchesFromJson(json);

  bool get isEmpty =>
      keywords.isEmpty && tags.isEmpty && genres.isEmpty && writers.isEmpty;
}

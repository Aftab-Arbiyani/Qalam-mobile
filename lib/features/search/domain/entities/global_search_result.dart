/// The grouped global-search preview (docs/40 §13.7, E8) — mirrors the backend
/// `GlobalSearchResultDto` from `GET /search`. A small relevance-ranked top-N per
/// group; the per-type endpoints own deep pagination. Reuses the shared read
/// models so a piece/writer/tag renders identically here, on the feed, and on the
/// discovery shelves (docs/40 §7.3). Every group is always present (empty when a
/// group has no matches). Persisted to the Hive cache for an offline replay of the
/// last query.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';

part 'global_search_result.freezed.dart';
part 'global_search_result.g.dart';

@freezed
abstract class GlobalSearchResult with _$GlobalSearchResult {
  const GlobalSearchResult._();

  const factory GlobalSearchResult({
    @Default(<WriterSummary>[]) List<WriterSummary> writers,
    @Default(<PieceSummary>[]) List<PieceSummary> pieces,
    @Default(<TrendingTag>[]) List<TrendingTag> tags,
    @Default(<TrendingGenre>[]) List<TrendingGenre> genres,
    @Default(<TrendingLanguage>[]) List<TrendingLanguage> languages,
  }) = _GlobalSearchResult;

  factory GlobalSearchResult.fromJson(Map<String, dynamic> json) =>
      _$GlobalSearchResultFromJson(json);

  /// True when every group is empty — the query matched nothing.
  bool get isEmpty =>
      writers.isEmpty &&
      pieces.isEmpty &&
      tags.isEmpty &&
      genres.isEmpty &&
      languages.isEmpty;
}

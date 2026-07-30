/// A writer card (docs/40 §6). Mirrors the backend `WriterCardDto`
/// (`GET /discover/writers`) and also the `SearchWriterDto` (`GET /search/writers`
/// & the grouped `/search`) — search adds [isPrivate], which is `false` for every
/// discovery writer (discovery is public-only). Reused by feed discovery shelves,
/// search writer results, and trending writers so there is one writer read model
/// (docs/40 §7.3). Persisted to the Hive cache.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'writer_summary.freezed.dart';
part 'writer_summary.g.dart';

@freezed
abstract class WriterSummary with _$WriterSummary {
  const WriterSummary._();

  const factory WriterSummary({
    required String username,
    String? penName,
    String? avatarKey,
    String? bio,
    @Default(0) int followersCount,
    @Default(0) int piecesCount,
    /// True for a private account surfaced by search — findable (name only) but
    /// rendered as a locked teaser: no bio, no piece browsing (docs/13 §4.2).
    @Default(false) bool isPrivate,
  }) = _WriterSummary;

  factory WriterSummary.fromJson(Map<String, dynamic> json) =>
      _$WriterSummaryFromJson(json);

  String get displayName => (penName != null && penName!.trim().isNotEmpty)
      ? penName!.trim()
      : '@$username';

  String get handle => '@$username';
}

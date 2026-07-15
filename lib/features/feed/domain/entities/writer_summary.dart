/// A writer card for discovery shelves (docs/40 §6) — mirrors the backend
/// `WriterCardDto` from `GET /discover/writers`. Persisted to the Hive cache.
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
  }) = _WriterSummary;

  factory WriterSummary.fromJson(Map<String, dynamic> json) =>
      _$WriterSummaryFromJson(json);

  String get displayName => (penName != null && penName!.trim().isNotEmpty)
      ? penName!.trim()
      : '@$username';

  String get handle => '@$username';
}

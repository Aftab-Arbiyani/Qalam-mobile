/// Profile aggregate counts (docs/40 §19.1) — mirrors the backend
/// `ProfileCountsDto`. `followers`/`following`/`piecesPublished` are live from the
/// denormalized profile row; the remaining engagement metrics are `0` on the
/// frozen `v1` until their source tables ship (a documented backend gap, docs/40
/// §45) — surfaced as returned so the shape stays stable when they light up.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_counts.freezed.dart';
part 'profile_counts.g.dart';

@freezed
abstract class ProfileCounts with _$ProfileCounts {
  const factory ProfileCounts({
    @Default(0) int followers,
    @Default(0) int following,
    @Default(0) int piecesPublished,
    @Default(0) int totalReads,
    @Default(0) int totalLikes,
    @Default(0) int totalClaps,
    @Default(0) int bookmarksReceived,
    @Default(0) int responseCount,
  }) = _ProfileCounts;

  factory ProfileCounts.fromJson(Map<String, dynamic> json) =>
      _$ProfileCountsFromJson(json);
}

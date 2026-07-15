/// Engagement counts + the viewer's own reaction state for a piece (docs/40 §21.4)
/// — mirrors the backend `PieceEngagementDto` from `GET /pieces/:id/engagement`,
/// flattened for the reader's optimistic social bar. The piece detail response
/// carries NO counts, so the reader fetches this separately.
///
/// For an anonymous viewer every viewer flag is false/0. Optimistic like/bookmark
/// toggles mutate a copy of this and reconcile with the server (docs/40 §21.4).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'piece_engagement.freezed.dart';
part 'piece_engagement.g.dart';

@freezed
abstract class PieceEngagement with _$PieceEngagement {
  const factory PieceEngagement({
    @Default(0) int likes,
    @Default(0) int claps,
    @Default(0) int bookmarks,
    @Default(0) int comments,
    @Default(0) int responses,
    @Default(0) int shares,
    @Default(false) bool hasLiked,
    @Default(false) bool hasBookmarked,
    @Default(0) int clapCount,
  }) = _PieceEngagement;

  factory PieceEngagement.fromJson(Map<String, dynamic> json) =>
      _$PieceEngagementFromJson(json);

  static const PieceEngagement empty = PieceEngagement();
}

/// A published-piece row for the signed-in user's own profile grid (docs/40 §19).
/// Mirrors the backend `PieceListItemDto` from `GET /me/pieces?status=published`.
/// Lightweight (no `content`) — a grid row only renders the title, cover, and
/// reading time, and taps through to the reader at `/p/:id`. JSON round-trippable
/// so the first page caches for offline viewing.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_piece.freezed.dart';
part 'profile_piece.g.dart';

@freezed
abstract class ProfilePiece with _$ProfilePiece {
  const factory ProfilePiece({
    required String id,
    @Default('') String title,
    String? slug,
    String? coverImageKey,
    @Default(0) int wordCount,
    @Default(0) int readingTimeSeconds,
    DateTime? publishedAt,
  }) = _ProfilePiece;

  factory ProfilePiece.fromJson(Map<String, dynamic> json) =>
      _$ProfilePieceFromJson(json);
}

/// The full reading aggregate (docs/40 §19.1) — mirrors the backend
/// `PieceResponseDto` from `GET /pieces/:id`. Holds the RAW TipTap content map so
/// the entity round-trips cleanly to/from the Hive cache; the reading renderer
/// parses it into the typed [PieceContent] tree at render time (off the UI thread
/// for large docs, docs/40 §36) via `data/mappers/content_mapper.dart`.
///
/// The wire's piece author carries only `{ username, penName }` — no avatar, no
/// id. The rich author card (avatar, bio, follower count, follow state, and the
/// user id needed to follow) is a separate [WriterProfile] fetched by username.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/entities/author.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';

part 'piece_detail.freezed.dart';
part 'piece_detail.g.dart';

@freezed
abstract class PieceDetail with _$PieceDetail {
  const PieceDetail._();

  const factory PieceDetail({
    required String id,
    required String title,
    required Author author,
    @Default(<String, dynamic>{}) Map<String, dynamic> content,
    String? subtitle,
    String? slug,
    String? featuredQuote,
    String? coverImageKey,
    LanguageRef? language,
    GenreRef? genre,
    @Default(<TagRef>[]) List<TagRef> tags,
    @Default(PieceStatus.published) PieceStatus status,
    @Default(Visibility.public) Visibility visibility,
    @Default(0) int wordCount,
    @Default(0) int readingTimeSeconds,
    DateTime? publishedAt,
  }) = _PieceDetail;

  factory PieceDetail.fromJson(Map<String, dynamic> json) =>
      _$PieceDetailFromJson(json);

  /// The piece's text direction, from its language (LTR fallback for a null
  /// language, e.g. a draft) — drives reading font + directionality (docs/41 §4).
  TextDirectionKind get direction =>
      language?.direction ?? TextDirectionKind.ltr;

  /// Reading time rounded up to whole minutes.
  int get readingTimeMinutes => readingTimeSeconds <= 0
      ? 0
      : ((readingTimeSeconds + 59) ~/ 60).clamp(1, 1 << 30);

  bool get hasCover => coverImageKey != null && coverImageKey!.isNotEmpty;

  bool get hasFeaturedQuote =>
      featuredQuote != null && featuredQuote!.trim().isNotEmpty;
}

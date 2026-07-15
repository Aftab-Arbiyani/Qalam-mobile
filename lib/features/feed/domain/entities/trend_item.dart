/// Discovery trend items (docs/40 §6) — mirror the backend `TrendingTagDto`,
/// `TrendingGenreDto`, `TrendingLanguageDto` from `GET /discover/{tags,genres,
/// languages}`. Persisted to the Hive cache (taxonomy tier).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/enums.dart';

part 'trend_item.freezed.dart';
part 'trend_item.g.dart';

@freezed
abstract class TrendingTag with _$TrendingTag {
  const factory TrendingTag({
    required String slug,
    @Default('') String name,
    @Default(0) int pieceCount,
  }) = _TrendingTag;

  factory TrendingTag.fromJson(Map<String, dynamic> json) =>
      _$TrendingTagFromJson(json);
}

@freezed
abstract class TrendingGenre with _$TrendingGenre {
  const factory TrendingGenre({
    required String slug,
    @Default('') String name,
    @Default(0) int pieceCount,
  }) = _TrendingGenre;

  factory TrendingGenre.fromJson(Map<String, dynamic> json) =>
      _$TrendingGenreFromJson(json);
}

@freezed
abstract class TrendingLanguage with _$TrendingLanguage {
  const factory TrendingLanguage({
    required String code,
    @Default('') String nativeName,
    @Default(TextDirectionKind.ltr) TextDirectionKind direction,
    @Default(0) int pieceCount,
  }) = _TrendingLanguage;

  factory TrendingLanguage.fromJson(Map<String, dynamic> json) =>
      _$TrendingLanguageFromJson(json);
}

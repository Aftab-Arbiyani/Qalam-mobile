/// Cross-cutting taxonomy value objects (docs/40 §19.1) — the language, genre,
/// and tag references embedded in feed cards, piece detail, and discovery shelves.
///
/// Languages and genres are DB-seeded taxonomy (not enums) — the wire sends
/// objects (`{ code, direction, nativeName }`, `{ slug, name }`). Direction drives
/// per-content directionality + reading font (docs/41 §4). Kept in `shared/domain`
/// because feed and reading both consume them (features never import features).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'taxonomy.freezed.dart';
part 'taxonomy.g.dart';

/// A content language reference. [direction] is authoritative for the piece's
/// text direction (`ur` → rtl / Nastaliq).
@freezed
abstract class LanguageRef with _$LanguageRef {
  const factory LanguageRef({
    required String code,
    @Default('') String nativeName,
    @Default(TextDirectionKind.ltr) TextDirectionKind direction,
  }) = _LanguageRef;

  factory LanguageRef.fromJson(Map<String, dynamic> json) =>
      _$LanguageRefFromJson(json);
}

/// A genre reference (`{ slug, name }`).
@freezed
abstract class GenreRef with _$GenreRef {
  const factory GenreRef({required String slug, @Default('') String name}) =
      _GenreRef;

  factory GenreRef.fromJson(Map<String, dynamic> json) =>
      _$GenreRefFromJson(json);
}

/// A tag reference (`#hashtag`, `{ slug, name }`).
@freezed
abstract class TagRef with _$TagRef {
  const factory TagRef({required String slug, @Default('') String name}) =
      _TagRef;

  factory TagRef.fromJson(Map<String, dynamic> json) => _$TagRefFromJson(json);
}

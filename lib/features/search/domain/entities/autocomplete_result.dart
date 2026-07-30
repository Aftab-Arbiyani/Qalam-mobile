/// Prefix-first search suggestions (docs/40 §13.7, E8) — mirrors the backend
/// `AutocompleteResultDto` from `GET /search/autocomplete`. Each group is capped
/// at ≤ 10; a group the `type` filter excluded comes back empty. Suggestions are
/// name-safe (no bio, no counts) — they exist only to complete the query. Never
/// cached (ephemeral, per-keystroke).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'autocomplete_result.freezed.dart';
part 'autocomplete_result.g.dart';

@freezed
abstract class WriterSuggestion with _$WriterSuggestion {
  const WriterSuggestion._();

  const factory WriterSuggestion({
    required String username,
    String? penName,
    String? avatarKey,
  }) = _WriterSuggestion;

  factory WriterSuggestion.fromJson(Map<String, dynamic> json) =>
      _$WriterSuggestionFromJson(json);

  String get label => (penName != null && penName!.trim().isNotEmpty)
      ? penName!.trim()
      : '@$username';
}

@freezed
abstract class TagSuggestion with _$TagSuggestion {
  const factory TagSuggestion({required String slug, @Default('') String name}) =
      _TagSuggestion;

  factory TagSuggestion.fromJson(Map<String, dynamic> json) =>
      _$TagSuggestionFromJson(json);
}

@freezed
abstract class GenreSuggestion with _$GenreSuggestion {
  const factory GenreSuggestion({
    required String slug,
    @Default('') String name,
  }) = _GenreSuggestion;

  factory GenreSuggestion.fromJson(Map<String, dynamic> json) =>
      _$GenreSuggestionFromJson(json);
}

@freezed
abstract class PieceSuggestion with _$PieceSuggestion {
  const factory PieceSuggestion({String? slug, @Default('') String title}) =
      _PieceSuggestion;

  factory PieceSuggestion.fromJson(Map<String, dynamic> json) =>
      _$PieceSuggestionFromJson(json);
}

@freezed
abstract class AutocompleteResult with _$AutocompleteResult {
  const AutocompleteResult._();

  const factory AutocompleteResult({
    @Default(<WriterSuggestion>[]) List<WriterSuggestion> writers,
    @Default(<TagSuggestion>[]) List<TagSuggestion> tags,
    @Default(<GenreSuggestion>[]) List<GenreSuggestion> genres,
    @Default(<PieceSuggestion>[]) List<PieceSuggestion> pieces,
  }) = _AutocompleteResult;

  factory AutocompleteResult.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteResultFromJson(json);

  bool get isEmpty =>
      writers.isEmpty && tags.isEmpty && genres.isEmpty && pieces.isEmpty;

  int get length => writers.length + tags.length + genres.length + pieces.length;
}

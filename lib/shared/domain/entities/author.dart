/// A writer summary embedded in bylines and cards (docs/40 §19.1 "Author").
///
/// Genuinely cross-cutting: the feed byline, the reading author card, and
/// discovery all reference it, so it lives in `shared/domain` rather than any one
/// feature (features never import features — docs/40 §7.3). Image keys stay keys;
/// the CDN URL is resolved at render time via `core/media` (docs/40 §18.2, §35).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'author.freezed.dart';
part 'author.g.dart';

@freezed
abstract class Author with _$Author {
  const Author._();

  const factory Author({
    required String username,
    String? penName,
    String? avatarKey,
  }) = _Author;

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  /// The name to show — the pen name when set, else the handle.
  String get displayName => (penName != null && penName!.trim().isNotEmpty)
      ? penName!.trim()
      : '@$username';

  /// The `@handle`, always LTR / bidi-isolated at render (docs/41 §11.19).
  String get handle => '@$username';
}

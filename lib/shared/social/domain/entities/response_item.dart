/// A response to a piece (docs/40 E7) — mirrors the backend `ResponseItemDto`. A
/// response IS a piece, so this is a lightweight summary plus the link timestamp.
/// Tapping a response opens the reader for [pieceId]. Cached to Hive.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_item.freezed.dart';
part 'response_item.g.dart';

@freezed
abstract class ResponseAuthor with _$ResponseAuthor {
  const ResponseAuthor._();

  const factory ResponseAuthor({required String username, String? penName}) =
      _ResponseAuthor;

  factory ResponseAuthor.fromJson(Map<String, dynamic> json) =>
      _$ResponseAuthorFromJson(json);

  String get displayName => (penName != null && penName!.trim().isNotEmpty)
      ? penName!.trim()
      : '@$username';

  String get handle => '@$username';
}

@freezed
abstract class ResponseItem with _$ResponseItem {
  const factory ResponseItem({
    required String pieceId,
    String? slug,
    @Default('') String title,
    String? subtitle,
    required ResponseAuthor author,
    DateTime? publishedAt,
    DateTime? respondedAt,
  }) = _ResponseItem;

  factory ResponseItem.fromJson(Map<String, dynamic> json) =>
      _$ResponseItemFromJson(json);
}

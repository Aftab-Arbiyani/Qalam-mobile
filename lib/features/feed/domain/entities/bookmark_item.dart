/// A bookmark list entry (docs/40 §6) — mirrors the backend `BookmarkItemDto`
/// from `GET /me/bookmarks`. Deliberately lightweight (the private bookmark feed
/// carries no author/cover/excerpt); the card shows the title + when it was saved
/// and opens the reader by [pieceId]. Persisted to the Hive cache.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_item.freezed.dart';
part 'bookmark_item.g.dart';

@freezed
abstract class BookmarkItem with _$BookmarkItem {
  const factory BookmarkItem({
    required String pieceId,
    required String title,
    String? slug,
    required DateTime bookmarkedAt,
  }) = _BookmarkItem;

  factory BookmarkItem.fromJson(Map<String, dynamic> json) =>
      _$BookmarkItemFromJson(json);
}

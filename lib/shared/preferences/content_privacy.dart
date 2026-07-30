/// The owner's local content-display privacy (docs/40 §19.3, §45) — whether the
/// reading-history and bookmarks stat tiles appear on their OWN profile. These are
/// display gates only: the frozen `v1` never exposes another user's reading
/// history or bookmarks to anyone, so there is no cross-user leak to enforce
/// server-side — the toggles honestly control only what this device shows.
library;

import 'package:flutter/foundation.dart';

@immutable
class ContentPrivacy {
  const ContentPrivacy({
    this.showReadingHistory = true,
    this.showBookmarks = true,
  });

  final bool showReadingHistory;
  final bool showBookmarks;

  ContentPrivacy copyWith({bool? showReadingHistory, bool? showBookmarks}) =>
      ContentPrivacy(
        showReadingHistory: showReadingHistory ?? this.showReadingHistory,
        showBookmarks: showBookmarks ?? this.showBookmarks,
      );

  @override
  bool operator ==(Object other) =>
      other is ContentPrivacy &&
      other.showReadingHistory == showReadingHistory &&
      other.showBookmarks == showBookmarks;

  @override
  int get hashCode => Object.hash(showReadingHistory, showBookmarks);
}

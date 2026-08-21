/// Product limits — a Dart mirror of `@qalam/shared` `limits.ts` and `regex.ts`.
///
/// These are the SAME numbers the backend enforces. The client applies them for
/// UX (instant validation feedback) only; the server is authoritative
/// (docs/40 §19.3). Never inline a duplicate literal — reference these.
library;

abstract final class Limits {
  /// Medium-style claps: up to 50 per user per piece.
  static const int maxClapsPerUserPerPiece = 50;

  // Comments — the PUBLIC conversation on a piece (`limits.ts`, `modules/engagement`).
  static const int commentMinLength = 1;
  static const int commentMaxLength = 2000;
  static const int maxCommentDepth = 3;

  /// A collaboration comment on a story — AF6's private review, a different
  /// endpoint and a different (larger) cap: `MAX_COMMENT_BODY_LENGTH` in
  /// `@qalam/shared` `collaboration.ts`, not the 2,000 above.
  ///
  /// Enforced by `@MaxLength` on the **raw** body, where an @mention is the
  /// mentioned person's 36-character id rather than their handle — which is why the
  /// composer counts against this through `rawCommentBodyLength` (P-2).
  static const int storyCommentBodyMax = 5000;

  /// A proposed edit's original/suggested text — `MAX_SUGGESTION_LENGTH` in
  /// `@qalam/shared` `collaboration.ts`, enforced via `@MaxLength` on both fields.
  static const int storySuggestionMax = 10000;

  // Collections.
  static const int collectionNameMin = 1;
  static const int collectionNameMax = 150;
  static const int collectionDescriptionMax = 500;
  static const String defaultCollectionTitle = 'Favorites';
  static const String defaultCollectionSlug = 'favorites';

  // Identity.
  static const int usernameMin = 3;
  static const int usernameMax = 30;
  static const int penNameMin = 1;
  static const int penNameMax = 50;

  // Password (NIST 800-63B — length over composition).
  static const int passwordMin = 10;
  static const int passwordMax = 128;

  // Piece / profile text bounds.
  static const int titleMax = 200;
  static const int subtitleMax = 300;
  static const int featuredQuoteMax = 280;
  static const int tagsMaxPerPiece = 5;
  static const int bioMax = 500;
  static const int locationMax = 100;
  static const int websiteUrlMax = 255;
  static const int maxSocialLinks = 8;
  static const int maxGenresPerProfile = 5;

  // Media caps.
  static const int avatarImageMaxMb = 5;
  static const int coverImageMaxMb = 10;
  static const List<String> acceptedImageTypes = <String>[
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  // Pagination guard rails (cursor and offset alike).
  static const int pageSizeDefault = 20;
  static const int pageSizeMax = 50;

  // Search.
  static const int searchQueryMin = 2;
  static const int searchQueryMax = 256;
  static const int autocompleteLimitDefault = 10;

  // Notifications.
  static const int notificationUnreadDisplayCap = 99;
}

/// Shared validation regexes (mirror `@qalam/shared` `regex.ts`).
abstract final class Patterns {
  /// Usernames: permanent, URL-safe, ASCII-only, 3–30 chars.
  static final RegExp username = RegExp(r'^[a-z0-9_]{3,30}$');
}

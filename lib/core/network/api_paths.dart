/// Endpoint path constants for the frozen `v1` API (docs/40 §9, §14.1).
///
/// These are PATHS ONLY — never DTOs or request/response bodies (those are
/// generated from `openapi.json`, docs/40 §18). Paths are relative to
/// `AppConfig.apiBaseUrl` (`{apiUrl}/api/v1`). M1 uses only the auth-refresh and
/// health paths; the rest are declared so M2–M10 reference constants, not
/// stringly-typed literals.
library;

abstract final class ApiPaths {
  // Auth.
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authLogoutAll = '/auth/logout-all';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResendVerification = '/auth/resend-verification';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authChangePassword = '/auth/change-password';
  static const String authGoogle = '/auth/google';
  static const String authGoogleExchange = '/auth/google/exchange';

  // Identity / profiles.
  static const String me = '/me';
  static String userByUsername(String username) => '/users/$username';

  // Profile media uploads (M5, docs/40 §34.3). Dedicated multipart endpoints on
  // the profiles controller — distinct from the piece-cover upload; the server
  // re-encodes (avatar → 512² WebP, cover → 1500×500 WebP) and returns `{ key }`.
  static const String profileAvatar = '/profile/avatar';
  static const String profileCover = '/profile/cover';

  // Pieces.
  static const String pieces = '/pieces';
  static String pieceById(String id) => '/pieces/$id';

  // Authoring / drafts (M4, docs/40 §47 M6). Lifecycle is driven by dedicated
  // action endpoints — `status`/`slug`/`scheduledAt` are never writable fields.
  static const String meDrafts = '/me/drafts';
  static const String mePieces = '/me/pieces';
  static String piecePublish(String id) => '/pieces/$id/publish';
  static String pieceSchedule(String id) => '/pieces/$id/schedule';
  static String pieceCover(String id) => '/pieces/$id/cover';

  // Reading engagement (docs/40 §21.4). Counts + viewer flags, like/bookmark,
  // share, responses.
  static String pieceEngagement(String id) => '/pieces/$id/engagement';
  static String pieceLikes(String id) => '/pieces/$id/likes';
  static String pieceBookmarks(String id) => '/pieces/$id/bookmarks';
  static String pieceShares(String id) => '/pieces/$id/shares';
  static String pieceResponses(String id) => '/pieces/$id/responses';
  static const String meBookmarks = '/me/bookmarks';

  // Comments & replies (E7). Top-level comments live under a piece; replies and
  // edit/delete key on the comment id.
  static String pieceComments(String id) => '/pieces/$id/comments';
  static String commentReplies(String id) => '/comments/$id/replies';
  static String comment(String id) => '/comments/$id';

  // Collections & reading lists (E7). Owner-only in Phase 1.
  static const String collections = '/collections';
  static String collection(String id) => '/collections/$id';
  static String collectionPieces(String id) => '/collections/$id/pieces';
  static String collectionPiece(String id, String pieceId) =>
      '/collections/$id/pieces/$pieceId';

  // Follow graph (follow/unfollow key on the target USER UUID; lists key on the
  // username; requests key on the follow-edge id, docs §follows).
  static String userFollow(String userId) => '/users/$userId/follow';
  static String userFollowers(String username) => '/users/$username/followers';
  static String userFollowing(String username) => '/users/$username/following';
  static const String meFollowRequests = '/me/follow-requests';
  static String followRequestAccept(String id) =>
      '/follow-requests/$id/accept';
  static String followRequestReject(String id) =>
      '/follow-requests/$id/reject';

  // Moderation.
  static const String reports = '/reports';

  // Reading analytics beacons (fire-and-forget, docs/40 §30.1).
  static String analyticsView(String id) => '/analytics/pieces/$id/view';
  static String analyticsRead(String id) => '/analytics/pieces/$id/read';

  // Feed / discover. Feeds are route-per-tab: /feed/{following,latest,trending,
  // discover}. `following` requires JWT; the rest are public.
  static String feed(String tab) => '/feed/$tab';
  static const String discoverPieces = '/discover/pieces';
  static const String discoverWriters = '/discover/writers';
  static const String discoverTags = '/discover/tags';
  static const String discoverGenres = '/discover/genres';
  static const String discoverLanguages = '/discover/languages';

  // Search (E8). Grouped preview, per-type paginated searches, autocomplete,
  // trending, and recent-search management.
  static const String search = '/search';
  static const String searchPieces = '/search/pieces';
  static const String searchWriters = '/search/writers';
  static const String searchTags = '/search/tags';
  static const String searchGenres = '/search/genres';
  static const String searchLanguages = '/search/languages';
  static const String searchAutocomplete = '/search/autocomplete';
  static const String searchTrending = '/search/trending';
  static const String searchRecent = '/search/recent';
  static String searchRecentById(String id) => '/search/recent/$id';

  // Notifications.
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';

  // Analytics.
  static const String analyticsDashboard = '/analytics/dashboard';

  /// Auth-corridor prefix — requests under it are exempt from the 401→refresh
  /// interceptor (a failed login/refresh is the caller's to handle, docs/40 §15).
  static const String authPrefix = '/auth/';
}

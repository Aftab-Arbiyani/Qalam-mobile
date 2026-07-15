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
  // share, responses (response creation is nav-only in M3).
  static String pieceEngagement(String id) => '/pieces/$id/engagement';
  static String pieceLikes(String id) => '/pieces/$id/likes';
  static String pieceBookmarks(String id) => '/pieces/$id/bookmarks';
  static String pieceShares(String id) => '/pieces/$id/shares';
  static String pieceResponses(String id) => '/pieces/$id/responses';
  static const String meBookmarks = '/me/bookmarks';

  // Follow graph (follow/unfollow key on the target USER UUID, docs §follows).
  static String userFollow(String userId) => '/users/$userId/follow';

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

  // Search.
  static const String search = '/search';
  static String searchType(String type) => '/search/$type';

  // Notifications.
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';

  // Analytics.
  static const String analyticsDashboard = '/analytics/dashboard';

  /// Auth-corridor prefix — requests under it are exempt from the 401→refresh
  /// interceptor (a failed login/refresh is the caller's to handle, docs/40 §15).
  static const String authPrefix = '/auth/';
}

/// Route paths + names (docs/40 §10.2). The single source of truth for
/// navigation targets — never stringly-typed paths scattered across the app. The
/// vocabulary mirrors the web `lib/routes.ts` so shared/deep links resolve the
/// same on web and mobile.
///
/// M2 adds the full auth corridor, the first-launch onboarding route, and the
/// dedicated error surfaces. Feature epics (M3–M10) add their own paths here.
library;

abstract final class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Bottom-nav shell branches.
  static const String feed = '/feed';
  static const String search = '/search';
  static const String write = '/write';
  static const String notifications = '/notifications';
  static const String profile = '/me';

  // Profile (M5). Editing my own profile is full-screen (outside the shell, like
  // the editor); a public profile is viewed by permanent username at `/u/:username`.
  static const String profileEdit = '/me/edit';
  static const String userProfile = '/u';
  static String userProfilePath(String username) => '/u/$username';

  // Writing / editor (M4). The Write tab is the drafts home; the editor + preview
  // are full-screen (no bottom nav). `:id` accepts a local draft id or a piece id.
  static String writeDraftPath(String id) => '/write/$id';
  static String piecePreviewPath(String id) => '/write/$id/preview';

  // Discovery surface (public, top-level as on web — docs/40 §10.2).
  static const String discover = '/discover';

  // Reading view (public). Slug-preferred links resolve by id in M3; the card
  // navigation always holds the piece id (docs/40 §12.3).
  static const String piece = '/p';
  static String piecePath(String id) => '/p/$id';

  // Social (M7). Comments + responses are public reading sub-surfaces; the
  // follow lists are public/auth-aware; requests + collections are gated by the
  // `/me` prefix.
  static String pieceCommentsPath(String id) => '/p/$id/comments';
  static String pieceResponsesPath(String id) => '/p/$id/responses';
  static String followersPath(String username) => '/u/$username/followers';
  static String followingPath(String username) => '/u/$username/following';
  static const String followRequests = '/me/follow-requests';
  static const String collections = '/me/collections';
  static String collectionDetailPath(String id) => '/me/collections/$id';

  // Settings (M5). A hub at `/settings` with per-area sub-routes; all full-screen
  // outside the shell. All are covered by `isProtected('/settings')`'s prefix match.
  static const String settings = '/settings';
  static const String settingsAccount = '/settings/account';
  static const String settingsAccountPassword = '/settings/account/password';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsPrivacy = '/settings/privacy';

  // Auth corridor (docs/40 §10.2). No bottom nav; own minimal chrome.
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String googleCallback = '/auth/callback';

  // Debug design-system gallery (exercises the component catalog).
  static const String gallery = '/gallery';

  // Error surfaces (docs/40 §10.2).
  static const String unauthorized = '/401';
  static const String forbidden = '/403';
  static const String notFound = '/404';
  static const String offline = '/offline';

  /// Locations that require an authenticated session (docs/40 §10.2, §11). Feed
  /// and search stay public/auth-aware; the writer/identity surfaces are gated.
  static bool isProtected(String location) =>
      _matches(location, settings) ||
      _matches(location, profile) ||
      _matches(location, write) ||
      _matches(location, notifications);

  /// The auth corridor — any `/auth/*`. Exempt from the network auth-refresh
  /// interceptor (a failed login/refresh is the caller's to handle, docs/40 §15).
  static bool isAuthCorridor(String location) => location.startsWith('/auth');

  /// Guest-only auth routes: a signed-in user is bounced away from these. The
  /// verify-email corridor is deliberately NOT guest-only — a freshly-registered,
  /// still-signed-in user must reach it (docs/40 §10.2, §11.5), and it is a state,
  /// not a wall.
  static bool isGuestOnly(String location) =>
      _matches(location, login) ||
      _matches(location, register) ||
      _matches(location, forgotPassword) ||
      _matches(location, resetPassword) ||
      _matches(location, googleCallback);

  /// Prefix match on a path segment boundary — `/me` matches `/me` and `/me/…`
  /// but not `/menu`.
  static bool _matches(String location, String route) =>
      location == route || location.startsWith('$route/');

  /// Validate + unwrap a `returnTo` value (docs/40 §11.3): only same-origin
  /// relative paths beginning with a single `/` are honored; protocol-relative
  /// (`//host`), the auth corridor, and the splash fall back to the feed so login
  /// never loops back into itself (open-redirect defense).
  static String safeReturnTo(String? returnTo) {
    if (returnTo == null) return feed;
    if (!returnTo.startsWith('/') || returnTo.startsWith('//')) return feed;
    if (isAuthCorridor(returnTo) || returnTo == splash) return feed;
    return returnTo;
  }
}

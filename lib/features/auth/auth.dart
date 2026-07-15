/// Auth feature barrel (docs/40 §4, §6) — the feature's public surface: the route
/// screens the router mounts, and the one cross-surface widget other features may
/// legitimately place (the email-verification banner). Feature-private controllers,
/// data sources, and widgets are NOT exported.
///
/// Architecture notes for reviewers (docs/40 §16, §20):
/// - Every auth flow goes controller → use case → repository → remote data source.
///   The use cases are the mandated domain seam; the form controllers own form
///   state + validation and, on success, call the core `SessionController` to
///   establish/clear the session (session state is single-sourced in core, never
///   duplicated in the feature).
/// - The Google OAuth exchange endpoint and `/auth/callback` handling are fully
///   wired; the native authorization launch is a documented seam
///   (`SocialSignInService`, inert by default) — see §14.4 / §39.2 / §45. Apple is
///   a Phase-2 seam (`SocialProvider.apple.isAvailable == false`).
/// - This repo has no generated `qalam_api` client (an M1 decision), so the data
///   layer maps the raw envelope `data` straight to entities — consistent with how
///   `core/network` decodes every payload; no hand-duplicated DTO classes.
library;

export 'presentation/screens/account_screen.dart';
export 'presentation/screens/forgot_password_screen.dart';
export 'presentation/screens/google_callback_screen.dart';
export 'presentation/screens/login_screen.dart';
export 'presentation/screens/register_screen.dart';
export 'presentation/screens/reset_password_screen.dart';
export 'presentation/screens/verify_email_screen.dart';
export 'presentation/widgets/email_verification_banner.dart';

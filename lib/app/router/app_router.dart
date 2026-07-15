/// GoRouter configuration (docs/40 §10–§12). Declarative routes, a
/// `StatefulShellRoute` for the bottom-nav (each tab keeps its own stack),
/// redirect-based guards driven by the session tri-state + onboarding flag,
/// deep-link-native paths, fade page transitions, and dedicated error surfaces.
///
/// M2 mounts the full auth corridor (all top-level, outside the shell — no bottom
/// nav) and the first-launch onboarding route, and hosts the account surface on the
/// `/me` tab. Redirects re-run whenever the session OR the onboarding flag changes.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../../core/error/failure.dart';
import '../../core/session/onboarding_controller.dart';
import '../../core/session/session_controller.dart';
import '../../features/auth/auth.dart';
import '../../features/feed/presentation/screens/discover_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/reading/presentation/screens/reading_screen.dart';
import '../../features/shell/presentation/pages/app_error_page.dart';
import '../../features/shell/presentation/pages/notifications_placeholder_page.dart';
import '../../features/shell/presentation/pages/search_placeholder_page.dart';
import '../../features/shell/presentation/pages/settings_placeholder_page.dart';
import '../../features/shell/presentation/widgets/unknown_route_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/writing/writing.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/domain/error_codes.dart';
import '../../shared/theme/tokens/motion_tokens.dart';
import '../../shared/widgets/navigation/q_nav_destination.dart';
import '../../shared/widgets/navigation/q_nav_scaffold.dart';
import '../observers/app_navigator_observer.dart';
import 'guards.dart';
import 'routes.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  // Re-run redirects when the session tri-state OR the onboarding flag changes
  // (docs/40 §11.2, §11.5).
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  ref
    ..listen(sessionControllerProvider, (_, _) => refresh.value++)
    ..listen(onboardingControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    observers: <NavigatorObserver>[
      AppNavigatorObserver(ref.watch(appLoggerProvider)),
    ],
    redirect: (BuildContext context, GoRouterState state) => guardRedirect(
      session: ref.read(sessionControllerProvider).stateOrUnknown,
      location: state.matchedLocation,
      isOnboardingComplete: ref.read(onboardingControllerProvider),
    ),
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const UnknownRoutePage(),
    routes: <RouteBase>[
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const SplashPage()),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'onboarding',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const OnboardingScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell shell,
            ) {
              final AppLocalizations l10n = AppLocalizations.of(context);
              return QNavScaffold(
                navigationShell: shell,
                destinations: <QNavDestination>[
                  QNavDestination(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: l10n.navFeed,
                  ),
                  QNavDestination(
                    icon: Icons.search_outlined,
                    selectedIcon: Icons.search,
                    label: l10n.navSearch,
                  ),
                  QNavDestination(
                    icon: Icons.edit_outlined,
                    selectedIcon: Icons.edit,
                    label: l10n.navWrite,
                    accented: true,
                  ),
                  QNavDestination(
                    icon: Icons.notifications_outlined,
                    selectedIcon: Icons.notifications,
                    label: l10n.navNotifications,
                  ),
                  QNavDestination(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: l10n.navProfile,
                  ),
                ],
              );
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.feed,
                name: 'feed',
                builder: (_, _) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.search,
                name: 'search',
                builder: (_, _) => const SearchPlaceholderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.write,
                name: 'write',
                builder: (_, _) => const DraftsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.notifications,
                name: 'notifications',
                builder: (_, _) => const NotificationsPlaceholderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.profile,
                name: 'profile',
                builder: (_, _) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const SettingsPlaceholderPage()),
      ),

      // Discovery + reading — public, full-screen (no bottom nav) — docs/40 §10.2.
      GoRoute(
        path: Routes.discover,
        name: 'discover',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const DiscoverScreen()),
      ),
      GoRoute(
        path: '${Routes.piece}/:id',
        name: 'piece',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id'] ?? '';
          return _fade(state, ReadingScreen(pieceId: id));
        },
      ),

      // Editor + preview — full-screen, outside the shell (no bottom nav),
      // auth-guarded via Routes.isProtected('/write/…') — docs/40 §10.1.
      GoRoute(
        path: '${Routes.write}/:id',
        name: 'editor',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          EditorScreen(draftId: state.pathParameters['id'] ?? ''),
        ),
        routes: <RouteBase>[
          GoRoute(
            path: 'preview',
            name: 'editorPreview',
            parentNavigatorKey: _rootKey,
            pageBuilder: (BuildContext context, GoRouterState state) => _fade(
              state,
              PreviewScreen(draftId: state.pathParameters['id'] ?? ''),
            ),
          ),
        ],
      ),

      // ── Auth corridor (top-level, no bottom nav) ────────────────────────────
      GoRoute(
        path: Routes.login,
        name: 'login',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          LoginScreen(returnTo: state.uri.queryParameters['returnTo']),
        ),
      ),
      GoRoute(
        path: Routes.register,
        name: 'register',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const RegisterScreen()),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        name: 'forgotPassword',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: Routes.resetPassword,
        name: 'resetPassword',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          ResetPasswordScreen(token: state.uri.queryParameters['token']),
        ),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        name: 'verifyEmail',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          VerifyEmailScreen(token: state.uri.queryParameters['token']),
        ),
      ),
      GoRoute(
        path: Routes.googleCallback,
        name: 'googleCallback',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          GoogleCallbackScreen(
            code: state.uri.queryParameters['code'],
            returnTo: state.uri.queryParameters['returnTo'],
          ),
        ),
      ),

      // ── Utility + error surfaces ────────────────────────────────────────────
      GoRoute(
        path: Routes.gallery,
        name: 'gallery',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const GalleryPage()),
      ),
      GoRoute(
        path: Routes.unauthorized,
        name: 'unauthorized',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          const AppErrorPage(
            failure: Failure.auth(code: ErrorCodes.unauthorized),
            actionPath: Routes.login,
          ),
        ),
      ),
      GoRoute(
        path: Routes.forbidden,
        name: 'forbidden',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          const AppErrorPage(
            failure: Failure.permission(code: ErrorCodes.forbidden),
            actionPath: Routes.feed,
          ),
        ),
      ),
      GoRoute(
        path: Routes.offline,
        name: 'offline',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          const AppErrorPage(
            failure: Failure.network(
              code: ErrorCodes.apiOffline,
              isOffline: true,
            ),
            actionPath: Routes.feed,
          ),
        ),
      ),
      GoRoute(
        path: Routes.notFound,
        name: 'notFound',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const UnknownRoutePage()),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
}

/// Fade page transition — "a book doesn't slide" (docs/41 §14).
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: QDurations.base,
    reverseTransitionDuration: QDurations.fast,
    transitionsBuilder: (_, Animation<double> animation, _, Widget child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

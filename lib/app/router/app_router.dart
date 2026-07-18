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
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show Consumer, WidgetRef;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../../core/error/failure.dart';
import '../../core/session/onboarding_controller.dart';
import '../../core/session/session_controller.dart';
import '../../features/ai/presentation/screens/ai_conversation_screen.dart';
import '../../features/ai/presentation/screens/ai_conversations_screen.dart';
import '../../features/ai/presentation/screens/ai_discovery_screen.dart';
import '../../features/ai/presentation/screens/ai_usage_screen.dart';
import '../../features/ai/presentation/screens/ask_book_screen.dart';
import '../../features/ai/presentation/screens/prompt_library_screen.dart';
import '../../features/ai/presentation/screens/semantic_search_screen.dart';
import '../../features/ai/presentation/screens/story_explorer_screen.dart';
import '../../features/analytics/presentation/screens/creator_analytics_screen.dart';
import '../../features/analytics/presentation/screens/piece_analytics_screen.dart';
import '../../features/analytics/presentation/screens/reading_analytics_screen.dart';
import '../../features/auth/auth.dart';
import '../../features/feed/presentation/screens/discover_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/notifications/notifications.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/profile.dart';
import '../../features/reading/presentation/screens/appearance_settings_screen.dart';
import '../../features/reading/presentation/screens/reading_screen.dart';
import '../../features/search/search.dart';
import '../../features/settings/presentation/screens/settings_hub_screen.dart';
import '../../features/shell/presentation/pages/app_error_page.dart';
import '../../features/shell/presentation/widgets/unknown_route_page.dart';
import '../../features/social/social.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/storage/presentation/screens/storage_screen.dart';
import '../../features/writing/writing.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/domain/error_codes.dart';
import '../../shared/theme/tokens/motion_tokens.dart';
import '../../shared/widgets/cards/q_badge.dart';
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
      AppNavigatorObserver(
        ref.watch(appLoggerProvider),
        ref.watch(crashReporterProvider),
      ),
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
              // The unread badge watches the polled count provider without
              // coupling the shell to the notifications data layer (docs/40 §32.1).
              return Consumer(
                builder: (BuildContext context, WidgetRef ref, _) {
                  final int unread =
                      ref
                          .watch(unreadCountControllerProvider)
                          .asData
                          ?.value
                          .count ??
                      0;
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
                        badge: unread > 0
                            ? QBadge.count(
                                count: unread,
                                semanticLabel: l10n.notificationsUnreadBadge(
                                  unread,
                                ),
                              )
                            : null,
                      ),
                      QNavDestination(
                        icon: Icons.person_outline,
                        selectedIcon: Icons.person,
                        label: l10n.navProfile,
                      ),
                    ],
                  );
                },
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
                builder: (_, _) => const SearchScreen(),
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
                builder: (_, _) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.profile,
                name: 'profile',
                builder: (_, _) => const MyProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Edit profile — full-screen, outside the shell, auth-gated via
      // Routes.isProtected('/me/…').
      GoRoute(
        path: Routes.profileEdit,
        name: 'profileEdit',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const ProfileEditScreen()),
      ),

      // Public profile by permanent username — public, full-screen (deep-linkable).
      GoRoute(
        path: '${Routes.userProfile}/:username',
        name: 'userProfile',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          PublicProfileScreen(username: state.pathParameters['username'] ?? ''),
        ),
        routes: <RouteBase>[
          GoRoute(
            path: 'followers',
            name: 'followers',
            parentNavigatorKey: _rootKey,
            pageBuilder: (BuildContext context, GoRouterState state) => _fade(
              state,
              FollowersScreen(username: state.pathParameters['username'] ?? ''),
            ),
          ),
          GoRoute(
            path: 'following',
            name: 'following',
            parentNavigatorKey: _rootKey,
            pageBuilder: (BuildContext context, GoRouterState state) => _fade(
              state,
              FollowingScreen(username: state.pathParameters['username'] ?? ''),
            ),
          ),
        ],
      ),

      // Follow requests + collections — full-screen, gated by the `/me` prefix.
      GoRoute(
        path: Routes.followRequests,
        name: 'followRequests',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const FollowRequestsScreen()),
      ),
      GoRoute(
        path: Routes.collections,
        name: 'collections',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const CollectionsScreen()),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            name: 'collectionDetail',
            parentNavigatorKey: _rootKey,
            pageBuilder: (BuildContext context, GoRouterState state) => _fade(
              state,
              CollectionDetailScreen(
                collectionId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ],
      ),

      // Settings hub + per-area screens — full-screen, outside the shell,
      // auth-gated via Routes.isProtected('/settings').
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const SettingsHubScreen()),
      ),
      GoRoute(
        path: Routes.settingsAccount,
        name: 'settingsAccount',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const AccountSettingsScreen()),
      ),
      GoRoute(
        path: Routes.settingsAccountPassword,
        name: 'settingsAccountPassword',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const ChangePasswordScreen()),
      ),
      GoRoute(
        path: Routes.settingsAppearance,
        name: 'settingsAppearance',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const AppearanceSettingsScreen()),
      ),
      GoRoute(
        path: Routes.settingsPrivacy,
        name: 'settingsPrivacy',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const PrivacySettingsScreen()),
      ),
      GoRoute(
        path: Routes.settingsNotifications,
        name: 'settingsNotifications',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const NotificationPreferencesScreen()),
      ),
      GoRoute(
        path: Routes.settingsStorage,
        name: 'settingsStorage',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const StorageScreen()),
      ),

      // Analytics & insights (M9) — full-screen, session-gated. Reading + per-piece
      // declared before the bare dashboard so their fuller paths match first.
      GoRoute(
        path: Routes.readingAnalytics,
        name: 'readingAnalytics',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const ReadingAnalyticsScreen()),
      ),
      GoRoute(
        path: '${Routes.pieceAnalytics}/:id',
        name: 'pieceAnalytics',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          PieceAnalyticsScreen(pieceId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: Routes.creatorAnalytics,
        name: 'creatorAnalytics',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const CreatorAnalyticsScreen()),
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
        routes: <RouteBase>[
          GoRoute(
            path: 'comments',
            name: 'pieceComments',
            parentNavigatorKey: _rootKey,
            pageBuilder: (BuildContext context, GoRouterState state) => _fade(
              state,
              CommentsScreen(pieceId: state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: 'responses',
            name: 'pieceResponses',
            parentNavigatorKey: _rootKey,
            pageBuilder: (BuildContext context, GoRouterState state) => _fade(
              state,
              ResponsesScreen(
                pieceId: state.pathParameters['id'] ?? '',
                languageCode: state.uri.queryParameters['lang'] ?? 'ur',
              ),
            ),
          ),
        ],
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

      // AI management surfaces (AF2) — full-screen, session-gated (`/ai` prefix).
      // The in-editor assistant + coach are bottom sheets, not routes.
      GoRoute(
        path: Routes.aiConversations,
        name: 'aiConversations',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const AiConversationsScreen()),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            name: 'aiConversation',
            parentNavigatorKey: _rootKey,
            pageBuilder: (BuildContext context, GoRouterState state) => _fade(
              state,
              AiConversationScreen(
                conversationId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.promptLibrary,
        name: 'promptLibrary',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const PromptLibraryScreen()),
      ),
      GoRoute(
        path: Routes.aiUsage,
        name: 'aiUsage',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const AiUsageScreen()),
      ),

      // AI Discovery / Search / Ask / Explorer (AF4) — full-screen, session-gated.
      GoRoute(
        path: Routes.aiDiscovery,
        name: 'aiDiscovery',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const AiDiscoveryScreen()),
      ),
      GoRoute(
        path: Routes.aiSearch,
        name: 'aiSearch',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const SemanticSearchScreen()),
      ),
      GoRoute(
        path: '${Routes.aiExplorer}/:storyId',
        name: 'aiExplorer',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          StoryExplorerScreen(storyId: state.pathParameters['storyId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '${Routes.aiAsk}/:storyId',
        name: 'aiAsk',
        parentNavigatorKey: _rootKey,
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          state,
          AskBookScreen(storyId: state.pathParameters['storyId'] ?? ''),
        ),
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

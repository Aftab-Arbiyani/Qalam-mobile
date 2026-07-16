/// The root application widget (docs/40 §1.2). `MaterialApp.router` wired to the
/// GoRouter, the persisted theme mode, and localization. Dynamic color is plumbed
/// via `DynamicColorBuilder` but OFF by default — the brand palette wins
/// (docs/41 §6).
library;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/notifications/presentation/providers/notification_providers.dart';
import '../l10n/generated/app_localizations.dart';
import '../shared/social/social_providers.dart';
import '../shared/theme/app_theme.dart';
import '../shared/theme/theme_mode_controller.dart';
import 'router/app_router.dart';

class QalamApp extends ConsumerWidget {
  const QalamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(goRouterProvider);
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);
    // Eagerly start the offline social-action queue so queued likes/bookmarks/
    // follows flush on reconnect even if no social screen was opened (docs/40 §23).
    ref.watch(socialSyncEngineProvider);
    // Same for queued notification actions (read/archive/delete), and the push ↔
    // app bridge so local/push notification taps deep-link from a cold start
    // (docs/40 §23, §32).
    ref.watch(notificationSyncEngineProvider);
    ref.watch(pushNotificationCoordinatorProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          themeMode: themeMode,
          theme: buildQalamTheme(
            brightness: Brightness.light,
            dynamicScheme: lightDynamic,
          ),
          darkTheme: buildQalamTheme(
            brightness: Brightness.dark,
            dynamicScheme: darkDynamic,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}

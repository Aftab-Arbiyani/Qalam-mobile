/// Application bootstrap (docs/40 §9.2, §28) — the composition root. Performs
/// async init (config validation, Hive, environment info, connectivity), installs
/// global error handlers (crash-safe), and provides the bootstrapped singletons
/// into the root `ProviderScope` as overrides. This is the ONLY place concrete
/// infrastructure is chosen.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/observers/app_provider_observer.dart';
import 'core/config/app_config.dart';
import 'core/config/app_environment_info.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/di/providers.dart';
import 'core/logging/app_logger.dart';
import 'core/notifications/flutter_local_notification_service.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/storage/hive_boxes.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast on misconfiguration (docs/40 §28).
  final AppConfig config = AppConfig.fromEnvironment()..validate();
  final AppLogger logger = AppLogger(flavor: config.flavor);

  // Global error handlers — crash-safe, PII-redacted (docs/40 §29, §21).
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      reason: details.context?.toString(),
      fatal: true,
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logger.recordError(error, stack);
    return true;
  };

  final ({
    Box<dynamic> cache,
    Box<dynamic> prefs,
    Box<dynamic> reading,
    Box<dynamic> drafts,
  })
  hive = await const HiveInitializer().initialize();
  final AppEnvironmentInfo env = await resolveAppEnvironmentInfo();
  final ConnectivityService connectivity = ConnectivityService();
  await connectivity.initialize();

  // Concrete on-device notifications (docs/40 §33). Initialization (channels +
  // tap handler) is driven by the push coordinator once the app is up; the FCM
  // push service stays inert (Phase-2 seam gated by AppConfig.enablePush).
  final LocalNotificationService localNotifications =
      FlutterLocalNotificationService(logger);

  logger.i(
    'Qalam ${env.fullVersion} · ${config.flavor.name} · ${env.platform}',
  );

  runApp(
    ProviderScope(
      observers: <ProviderObserver>[AppProviderObserver(logger)],
      overrides: [
        appConfigProvider.overrideWithValue(config),
        appLoggerProvider.overrideWithValue(logger),
        appEnvironmentInfoProvider.overrideWithValue(env),
        cacheBoxProvider.overrideWithValue(hive.cache),
        prefsBoxProvider.overrideWithValue(hive.prefs),
        readingBoxProvider.overrideWithValue(hive.reading),
        draftsBoxProvider.overrideWithValue(hive.drafts),
        connectivityServiceProvider.overrideWith((Ref ref) {
          ref.onDispose(connectivity.dispose);
          return connectivity;
        }),
        localNotificationServiceProvider.overrideWithValue(localNotifications),
      ],
      child: const QalamApp(),
    ),
  );
}

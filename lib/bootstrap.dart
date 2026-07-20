/// Application bootstrap (docs/40 §9.2, §28) — the composition root. Performs
/// async init (config validation, Hive, environment info, connectivity), installs
/// global error handlers (crash-safe), and provides the bootstrapped singletons
/// into the root `ProviderScope` as overrides. This is the ONLY place concrete
/// infrastructure is chosen.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/observers/app_provider_observer.dart';
import 'core/config/app_config.dart';
import 'core/config/app_environment_info.dart';
import 'core/config/remote_config.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/di/providers.dart';
import 'core/logging/app_logger.dart';
import 'core/notifications/flutter_local_notification_service.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/observability/crash_reporter.dart';
import 'core/storage/hive_boxes.dart';

Future<void> bootstrap() async {
  // Run the whole app inside a guarded zone so async errors with no other handler
  // are captured too (docs/40 §29). `ensureInitialized` must run in the SAME zone
  // as `runApp`, so it lives inside the guarded body.
  await runZonedGuarded<Future<void>>(_start, (Object error, StackTrace stack) {
    _reporter?.recordError(error, stack, reason: 'zone', fatal: true);
    _logger?.recordError(error, stack, reason: 'Uncaught (zone)');
  });
}

// Held so the top-level zone handler can forward to them after startup.
AppLogger? _logger;
CrashReporter? _reporter;

Future<void> _start() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast on misconfiguration (docs/40 §28).
  final AppConfig config = AppConfig.fromEnvironment()..validate();
  final AppLogger logger = AppLogger(flavor: config.flavor);
  _logger = logger;

  final AppEnvironmentInfo env = await resolveAppEnvironmentInfo();

  // DSN-gated crash reporter (docs/40 §31) — inert without a DSN, but keeps a
  // PII-free breadcrumb trail. Release + environment metadata are attached here.
  final CrashReporter crashReporter = createCrashReporter(
    config: config,
    env: env,
    logger: logger,
  );
  _reporter = crashReporter;
  await crashReporter.initialize();

  // Remote configuration (docs/40 §31; docs/51) — inert until a backend impl is
  // compiled in, so every lookup returns the caller's fallback and behaviour is
  // driven by AppConfig + server-side flags. Activated by swapping the factory.
  final RemoteConfigService remoteConfig = createRemoteConfig(
    config: config,
    logger: logger,
  );
  await remoteConfig.initialize();

  // Global error handlers — crash-safe, PII-redacted (docs/40 §29, §21). Each
  // forwards to BOTH the console logger and the crash reporter.
  FlutterError.onError = (FlutterErrorDetails details) {
    final StackTrace stack = details.stack ?? StackTrace.current;
    logger.recordError(
      details.exception,
      stack,
      reason: details.context?.toString(),
      fatal: true,
    );
    unawaited(
      crashReporter.recordError(
        details.exception,
        stack,
        reason: details.context?.toString(),
        fatal: true,
      ),
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logger.recordError(error, stack, reason: 'Uncaught (platform)');
    unawaited(crashReporter.recordError(error, stack, fatal: true));
    return true;
  };

  final ({
    Box<dynamic> cache,
    Box<dynamic> prefs,
    Box<dynamic> reading,
    Box<dynamic> drafts,
  })
  hive = await const HiveInitializer().initialize();
  final ConnectivityService connectivity = ConnectivityService();
  await connectivity.initialize();

  // Concrete on-device notifications (docs/40 §33). Initialization (channels +
  // tap handler) is driven by the push coordinator once the app is up; the FCM
  // push service stays inert (Phase-2 seam gated by AppConfig.enablePush).
  final LocalNotificationService localNotifications =
      FlutterLocalNotificationService(logger);

  logger.i(
    'Qalam ${env.fullVersion} · ${config.flavor.name} · ${env.platform}'
    ' · crash-reporting=${crashReporter.isEnabled}',
  );

  runApp(
    ProviderScope(
      observers: <ProviderObserver>[AppProviderObserver(logger)],
      overrides: [
        appConfigProvider.overrideWithValue(config),
        appLoggerProvider.overrideWithValue(logger),
        appEnvironmentInfoProvider.overrideWithValue(env),
        crashReporterProvider.overrideWithValue(crashReporter),
        remoteConfigProvider.overrideWithValue(remoteConfig),
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

/// Select the crash reporter for this build (docs/40 §31). Today this is always
/// the inert [NoopCrashReporter]; when a DSN is configured AND `sentry_flutter` is
/// added, return a `SentryCrashReporter` here — the only line that changes. If a
/// DSN is set today, we log once so the missing SDK is obvious in staging.
CrashReporter createCrashReporter({
  required AppConfig config,
  required AppEnvironmentInfo env,
  required AppLogger logger,
}) {
  if (config.isCrashReportingEnabled) {
    logger.w(
      'A crash-reporting DSN is set but no reporter SDK is compiled in; '
      'add sentry_flutter + a SentryCrashReporter to activate (docs/40 §31).',
    );
  }
  return NoopCrashReporter(
    logger: logger,
    release: env.fullVersion,
    environment: config.flavor.wire,
  );
}

/// Select the remote-config source for this build (docs/40 §31; docs/51). Today
/// this is always the inert [NoopRemoteConfigService] — every lookup returns the
/// caller's fallback, so runtime behaviour stays driven by [AppConfig] + the
/// server-side feature flags. When Firebase Remote Config is added, return a
/// `FirebaseRemoteConfigService` here (the only line that changes) and gate it on
/// `config`/flavor; `logger` is threaded in so activation can be traced.
RemoteConfigService createRemoteConfig({
  required AppConfig config,
  required AppLogger logger,
}) {
  // `config` (flavor/gating) and `logger` (activation tracing) are threaded in so
  // the signature is stable when a real impl is swapped in; the Noop needs neither.
  logger.d('Remote config: inert (Noop) for ${config.flavor.wire} build.');
  return const NoopRemoteConfigService();
}

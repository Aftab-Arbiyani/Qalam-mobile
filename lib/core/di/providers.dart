/// Dependency injection (docs/40 §9). DI is Riverpod — there is NO service
/// locator. Every dependency is an overridable provider.
///
/// The `*_bootstrap` providers throw until overridden in the composition root
/// (`bootstrap.dart`) with values that require async init (config, Hive boxes,
/// connectivity, environment info). Everything else derives from them, so tests
/// override only what they need.
library;

import 'package:dio/dio.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/data/cache_list_data_source.dart';
import '../config/app_config.dart';
import '../config/app_environment_info.dart';
import '../config/remote_config.dart';
import '../connectivity/connectivity_service.dart';
import '../logging/app_logger.dart';
import '../media/cover_image_picker.dart';
import '../media/media_url_builder.dart';
import '../network/api_client.dart';
import '../network/auth_gateway.dart';
import '../network/dio_client.dart';
import '../notifications/local_notification_service.dart';
import '../notifications/push_messaging_service.dart';
import '../observability/crash_reporter.dart';
import '../observability/network_diagnostics.dart';
import '../observability/operational_logger.dart';
import '../observability/operations_feature_flags.dart';
import '../observability/performance_monitor.dart';
import '../observability/production_telemetry.dart';
import '../observability/release_diagnostics.dart';
import '../security/biometric_gate.dart';
import '../security/certificate_pinning.dart';
import '../security/device_integrity.dart';
import '../security/screenshot_protection.dart';
import '../security/token_store.dart';
import '../storage/cache_store.dart';
import '../storage/preferences_store.dart';
import '../storage/secure_storage.dart';

part 'providers.g.dart';

// ── Bootstrapped singletons (overridden in the composition root) ──────────────

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => throw UnimplementedError(
  'appConfigProvider must be overridden in bootstrap',
);

@Riverpod(keepAlive: true)
AppEnvironmentInfo appEnvironmentInfo(Ref ref) => throw UnimplementedError(
  'appEnvironmentInfoProvider must be overridden in bootstrap',
);

@Riverpod(keepAlive: true)
Box<dynamic> cacheBox(Ref ref) => throw UnimplementedError(
  'cacheBoxProvider must be overridden in bootstrap',
);

@Riverpod(keepAlive: true)
Box<dynamic> prefsBox(Ref ref) => throw UnimplementedError(
  'prefsBoxProvider must be overridden in bootstrap',
);

@Riverpod(keepAlive: true)
Box<dynamic> readingBox(Ref ref) => throw UnimplementedError(
  'readingBoxProvider must be overridden in bootstrap',
);

@Riverpod(keepAlive: true)
Box<dynamic> draftsBox(Ref ref) => throw UnimplementedError(
  'draftsBoxProvider must be overridden in bootstrap',
);

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => throw UnimplementedError(
  'connectivityServiceProvider must be overridden in bootstrap',
);

/// Remote configuration source (docs/40 §31; docs/51). Overridden in `bootstrap`
/// with the build's concrete instance (the inert [NoopRemoteConfigService] today;
/// a Firebase-backed impl once activated) via [createRemoteConfig], so the app
/// reads runtime-tunable values through one seam. Throws until overridden — tests
/// override it with a Noop (mirrors `appConfigProvider`).
@Riverpod(keepAlive: true)
RemoteConfigService remoteConfig(Ref ref) => throw UnimplementedError(
  'remoteConfigProvider must be overridden in bootstrap',
);

/// The crash/error reporter (docs/40 §31). Overridden in `bootstrap` with the
/// DSN-gated concrete instance so error handlers and features can leave
/// breadcrumbs. Defaults to an inert reporter in tests (no DSN, no uploads).
@Riverpod(keepAlive: true)
CrashReporter crashReporter(Ref ref) =>
    NoopCrashReporter(logger: ref.watch(appLoggerProvider));

// ── Derived singletons ────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) {
  final AppLogger logger = AppLogger(
    flavor: ref.watch(appConfigProvider).flavor,
  );
  ref.onDispose(logger.dispose);
  return logger;
}

@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) => SecureStorage();

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore(ref.watch(secureStorageProvider));

@Riverpod(keepAlive: true)
CacheStore cacheStore(Ref ref) => HiveCacheStore(ref.watch(cacheBoxProvider));

@Riverpod(keepAlive: true)
CacheListDataSource cacheListDataSource(Ref ref) =>
    CacheListDataSource(ref.watch(cacheStoreProvider));

@Riverpod(keepAlive: true)
PreferencesStore preferencesStore(Ref ref) =>
    PreferencesStore(ref.watch(prefsBoxProvider));

@Riverpod(keepAlive: true)
MediaUrlBuilder mediaUrlBuilder(Ref ref) =>
    MediaUrlBuilder(ref.watch(appConfigProvider));

@Riverpod(keepAlive: true)
CoverImagePicker coverImagePicker(Ref ref) => PlatformCoverImagePicker();

@Riverpod(keepAlive: true)
AuthGateway authGateway(Ref ref) => AuthGateway(
  tokenStore: ref.watch(tokenStoreProvider),
  config: ref.watch(appConfigProvider),
  logger: ref.watch(appLoggerProvider),
);

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final Dio client = buildDioClient(
    config: ref.watch(appConfigProvider),
    gateway: ref.watch(authGatewayProvider),
    logger: ref.watch(appLoggerProvider),
    pinning: ref.watch(certificatePinningProvider),
  );
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient(
  dio: ref.watch(dioProvider),
  connectivity: ref.watch(connectivityServiceProvider),
);

// ── Placeholder services (inert in M1, swapped in their epics) ─────────────────

@Riverpod(keepAlive: true)
PushMessagingService pushMessagingService(Ref ref) =>
    const NoopPushMessagingService();

@Riverpod(keepAlive: true)
LocalNotificationService localNotificationService(Ref ref) =>
    const NoopLocalNotificationService();

@Riverpod(keepAlive: true)
BiometricGate biometricGate(Ref ref) => const NoopBiometricGate();

@Riverpod(keepAlive: true)
CertificatePinning certificatePinning(Ref ref) =>
    const NoopCertificatePinning();

@Riverpod(keepAlive: true)
DeviceIntegrityService deviceIntegrityService(Ref ref) =>
    const NoopDeviceIntegrityService();

/// On-screen content protection (docs/52 P7.2). Overridden in `bootstrap` with
/// the build's concrete instance (the inert [NoopScreenshotProtectionService]
/// today; a FLAG_SECURE / iOS view-hiding impl once activated) via
/// [createScreenshotProtection], so sensitive screens toggle protection through
/// one seam. Defaults to the Noop so tests need no override (mirrors
/// `crashReporterProvider`).
@Riverpod(keepAlive: true)
ScreenshotProtectionService screenshotProtection(Ref ref) =>
    const NoopScreenshotProtectionService();

// ── Operations Platform seams (P7.4 — inert until a backend is wired) ──────────

/// Performance monitoring (P7.4; docs/54). Inert [NoopPerformanceMonitor] by
/// default — keeps a bounded local ring; swap for an APM impl to upload.
@Riverpod(keepAlive: true)
PerformanceMonitor performanceMonitor(Ref ref) => NoopPerformanceMonitor();

/// Network diagnostics (P7.4; docs/54). Inert [NoopNetworkDiagnostics] by
/// default — id + path only, bounded local ring + counters.
@Riverpod(keepAlive: true)
NetworkDiagnostics networkDiagnostics(Ref ref) => NoopNetworkDiagnostics();

/// Operational logging (P7.4; docs/54). Classifies + redacts over [AppLogger] and
/// forwards errors to the crash reporter. Ships nothing remotely by default.
@Riverpod(keepAlive: true)
OperationalLogger operationalLogger(Ref ref) => NoopOperationalLogger(
  logger: ref.watch(appLoggerProvider),
  crashReporter: ref.watch(crashReporterProvider),
);

/// Release diagnostics (P7.4; docs/54). Exposes the resolved [AppEnvironmentInfo]
/// + build channel; attaches release context to crash reports.
@Riverpod(keepAlive: true)
ReleaseDiagnostics releaseDiagnostics(Ref ref) => NoopReleaseDiagnostics(
  environment: ref.watch(appEnvironmentInfoProvider),
  channel: ref.watch(appConfigProvider).flavor.wire,
);

/// Production telemetry umbrella (P7.4; docs/54). Composes the observability
/// seams behind one facade. Inert by default (all composed seams are inert).
@Riverpod(keepAlive: true)
ProductionTelemetry productionTelemetry(Ref ref) => NoopProductionTelemetry(
  crashReporter: ref.watch(crashReporterProvider),
  performance: ref.watch(performanceMonitorProvider),
  network: ref.watch(networkDiagnosticsProvider),
  logger: ref.watch(operationalLoggerProvider),
  release: ref.watch(releaseDiagnosticsProvider),
);

/// Remote feature-flag reconciliation (P7.4; docs/54). Reconciles the compile-time
/// kill switches with the remote-config dial (server flags stay authoritative in
/// their own providers).
@Riverpod(keepAlive: true)
OperationsFeatureFlags operationsFeatureFlags(Ref ref) => OperationsFeatureFlags(
  config: ref.watch(appConfigProvider),
  remoteConfig: ref.watch(remoteConfigProvider),
);

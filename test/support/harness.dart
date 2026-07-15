/// Test harness (docs/40 §38). Builds a `ProviderScope`-wrapped app with every
/// platform-channel / bootstrapped dependency replaced by a fake, so widget and
/// provider tests run on the Dart VM without a device. Everything is mocked at
/// its own boundary (mocktail).
library;

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/app/app.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_environment_info.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/connectivity/connectivity_service.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/media/cover_image_picker.dart';
import 'package:qalam_mobile/core/network/auth_gateway.dart';
import 'package:qalam_mobile/core/storage/secure_storage.dart';
import 'package:qalam_mobile/features/auth/data/services/social_sign_in_service.dart';
import 'package:qalam_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:qalam_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:qalam_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:qalam_mobile/features/feed/presentation/providers/feed_providers.dart';
import 'package:qalam_mobile/features/reading/domain/repositories/engagement_repository.dart';
import 'package:qalam_mobile/features/reading/domain/repositories/reading_repository.dart';
import 'package:qalam_mobile/features/reading/presentation/providers/reading_providers.dart';
import 'package:qalam_mobile/features/writing/domain/repositories/editor_taxonomy_repository.dart';
import 'package:qalam_mobile/features/writing/domain/repositories/piece_editor_repository.dart';
import 'package:qalam_mobile/features/writing/presentation/providers/writing_providers.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockConnectivity extends Mock implements Connectivity {}

const AppConfig testConfig = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
);

/// An in-memory [SecureStorage] backed by a mocked plugin.
SecureStorage buildFakeSecureStorage([Map<String, String>? seed]) {
  final MockFlutterSecureStorage fss = MockFlutterSecureStorage();
  final Map<String, String> store = <String, String>{...?seed};

  when(
    () => fss.read(key: any(named: 'key')),
  ).thenAnswer((Invocation i) async => store[i.namedArguments[#key] as String]);
  when(
    () => fss.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((Invocation i) async {
    store[i.namedArguments[#key] as String] =
        i.namedArguments[#value] as String;
  });
  when(() => fss.delete(key: any(named: 'key'))).thenAnswer((
    Invocation i,
  ) async {
    store.remove(i.namedArguments[#key] as String);
  });
  when(fss.deleteAll).thenAnswer((_) async {
    store.clear();
  });

  return SecureStorage(fss);
}

/// A [ConnectivityService] whose plugin is mocked to a fixed status.
Future<ConnectivityService> buildFakeConnectivity({
  required bool online,
}) async {
  final MockConnectivity conn = MockConnectivity();
  final List<ConnectivityResult> result = online
      ? <ConnectivityResult>[ConnectivityResult.wifi]
      : <ConnectivityResult>[ConnectivityResult.none];
  when(conn.checkConnectivity).thenAnswer((_) async => result);
  when(
    () => conn.onConnectivityChanged,
  ).thenAnswer((_) => Stream<List<ConnectivityResult>>.value(result));
  final ConnectivityService service = ConnectivityService(conn);
  await service.initialize();
  return service;
}

/// A `ProviderScope`-wrapped [QalamApp] (or [child]) with all bootstrapped
/// dependencies overridden by fakes. Opens throwaway Hive boxes in a temp dir.
Future<Widget> buildTestApp({
  bool online = true,
  Map<String, String>? tokens,
  Widget? child,
  bool onboardingComplete = true,
  bool rememberMe = false,
  AuthRepository? authRepository,
  SocialSignInService? socialSignInService,
  FeedRepository? feedRepository,
  ReadingRepository? readingRepository,
  EngagementRepository? engagementRepository,
  PieceEditorRepository? pieceEditorRepository,
  EditorTaxonomyRepository? editorTaxonomyRepository,
  CoverImagePicker? coverImagePicker,
}) async {
  final Directory dir = await Directory.systemTemp.createTemp('qalam_test');
  Hive.init(dir.path);
  final String suffix = dir.path.hashCode.toRadixString(16);
  final Box<dynamic> cache = await Hive.openBox<dynamic>('cache_$suffix');
  final Box<dynamic> prefs = await Hive.openBox<dynamic>('prefs_$suffix');
  final Box<dynamic> reading = await Hive.openBox<dynamic>('reading_$suffix');
  final Box<dynamic> drafts = await Hive.openBox<dynamic>('drafts_$suffix');
  // Seed device prefs before the scope reads them (onboarding gate + remember-me
  // gate for silent restore).
  await prefs.put('onboarding_complete', onboardingComplete);
  await prefs.put('remember_me', rememberMe);
  final ConnectivityService connectivity = await buildFakeConnectivity(
    online: online,
  );

  return ProviderScope(
    // The list is intentionally untyped so the element types (Override) are
    // inferred — the concrete Override type is not exported for direct annotation.
    overrides: [
      appConfigProvider.overrideWithValue(testConfig),
      appLoggerProvider.overrideWithValue(
        AppLogger(flavor: AppFlavor.development),
      ),
      appEnvironmentInfoProvider.overrideWithValue(AppEnvironmentInfo.unknown),
      cacheBoxProvider.overrideWithValue(cache),
      prefsBoxProvider.overrideWithValue(prefs),
      readingBoxProvider.overrideWithValue(reading),
      draftsBoxProvider.overrideWithValue(drafts),
      secureStorageProvider.overrideWithValue(buildFakeSecureStorage(tokens)),
      connectivityServiceProvider.overrideWithValue(connectivity),
      if (authRepository != null)
        authRepositoryProvider.overrideWithValue(authRepository),
      if (socialSignInService != null)
        socialSignInServiceProvider.overrideWithValue(socialSignInService),
      if (feedRepository != null)
        feedRepositoryProvider.overrideWithValue(feedRepository),
      if (readingRepository != null)
        readingRepositoryProvider.overrideWithValue(readingRepository),
      if (engagementRepository != null)
        engagementRepositoryProvider.overrideWithValue(engagementRepository),
      if (pieceEditorRepository != null)
        pieceEditorRepositoryProvider.overrideWithValue(pieceEditorRepository),
      if (editorTaxonomyRepository != null)
        editorTaxonomyRepositoryProvider.overrideWithValue(
          editorTaxonomyRepository,
        ),
      if (coverImagePicker != null)
        coverImagePickerProvider.overrideWithValue(coverImagePicker),
    ],
    child: child ?? const QalamApp(),
  );
}

/// Pump the app for a widget test. The infra setup ([buildTestApp]) does REAL
/// async I/O (Hive `openBox`, connectivity init) that would deadlock under the
/// fake-async zone of `testWidgets`, so it runs inside [WidgetTester.runAsync];
/// the frames are then driven with bounded `pump`s (the splash spinner would make
/// `pumpAndSettle` never settle).
Future<void> pumpTestApp(
  WidgetTester tester, {
  bool online = true,
  Map<String, String>? tokens,
  bool onboardingComplete = true,
  bool rememberMe = false,
  AuthRepository? authRepository,
  SocialSignInService? socialSignInService,
  FeedRepository? feedRepository,
}) async {
  late final Widget app;
  await tester.runAsync(() async {
    app = await buildTestApp(
      online: online,
      tokens: tokens,
      onboardingComplete: onboardingComplete,
      rememberMe: rememberMe,
      authRepository: authRepository,
      socialSignInService: socialSignInService,
      feedRepository: feedRepository,
    );
  });
  await tester.pumpWidget(app);
  await settleFrames(tester);
}

/// Bounded frame pumps — the splash's infinite `CircularProgressIndicator` makes
/// `pumpAndSettle` unusable.
Future<void> settleFrames(WidgetTester tester, {int frames = 12}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Tap a target whose handler performs REAL async work (secure-storage / Hive
/// writes in session establish/teardown or onboarding completion), then let that
/// work drain on the real event loop before pumping the resulting navigation. The
/// plain fake-async `pump` cannot advance those futures, so we [runAsync] a short
/// real delay first.
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.runAsync(() async {
    await tester.tap(finder);
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await settleFrames(tester);
}

/// A `ProviderContainer` with the bootstrapped infra faked — for provider/notifier
/// unit tests that don't pump a widget tree. Dispose with `addTearDown`.
Future<ProviderContainer> buildTestContainer({
  bool online = true,
  Map<String, String>? tokens,
  bool onboardingComplete = true,
  bool rememberMe = false,
  AuthRepository? authRepository,
  FeedRepository? feedRepository,
  ReadingRepository? readingRepository,
  EngagementRepository? engagementRepository,
  PieceEditorRepository? pieceEditorRepository,
  EditorTaxonomyRepository? editorTaxonomyRepository,
  CoverImagePicker? coverImagePicker,
  Dio? refreshClient,
}) async {
  final Directory dir = await Directory.systemTemp.createTemp('qalam_test_c');
  Hive.init(dir.path);
  final String suffix = dir.path.hashCode.toRadixString(16);
  final Box<dynamic> cache = await Hive.openBox<dynamic>('cache_$suffix');
  final Box<dynamic> prefs = await Hive.openBox<dynamic>('prefs_$suffix');
  final Box<dynamic> reading = await Hive.openBox<dynamic>('reading_$suffix');
  final Box<dynamic> drafts = await Hive.openBox<dynamic>('drafts_$suffix');
  await prefs.put('onboarding_complete', onboardingComplete);
  await prefs.put('remember_me', rememberMe);
  final ConnectivityService connectivity = await buildFakeConnectivity(
    online: online,
  );

  return ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(testConfig),
      appLoggerProvider.overrideWithValue(
        AppLogger(flavor: AppFlavor.development),
      ),
      appEnvironmentInfoProvider.overrideWithValue(AppEnvironmentInfo.unknown),
      cacheBoxProvider.overrideWithValue(cache),
      prefsBoxProvider.overrideWithValue(prefs),
      readingBoxProvider.overrideWithValue(reading),
      draftsBoxProvider.overrideWithValue(drafts),
      secureStorageProvider.overrideWithValue(buildFakeSecureStorage(tokens)),
      connectivityServiceProvider.overrideWithValue(connectivity),
      if (authRepository != null)
        authRepositoryProvider.overrideWithValue(authRepository),
      if (feedRepository != null)
        feedRepositoryProvider.overrideWithValue(feedRepository),
      if (readingRepository != null)
        readingRepositoryProvider.overrideWithValue(readingRepository),
      if (engagementRepository != null)
        engagementRepositoryProvider.overrideWithValue(engagementRepository),
      if (pieceEditorRepository != null)
        pieceEditorRepositoryProvider.overrideWithValue(pieceEditorRepository),
      if (editorTaxonomyRepository != null)
        editorTaxonomyRepositoryProvider.overrideWithValue(
          editorTaxonomyRepository,
        ),
      if (coverImagePicker != null)
        coverImagePickerProvider.overrideWithValue(coverImagePicker),
      // Inject a mocked refresh transport so silent-restore success is testable
      // without a live server (the gateway's refresh Dio is otherwise real).
      if (refreshClient != null)
        authGatewayProvider.overrideWith(
          (Ref ref) => AuthGateway(
            tokenStore: ref.watch(tokenStoreProvider),
            config: ref.watch(appConfigProvider),
            logger: ref.watch(appLoggerProvider),
            refreshClient: refreshClient,
          ),
        ),
    ],
  );
}

/// A syntactically-valid, unsigned JWT whose payload decodes to the given claims —
/// enough for the client-side `decodeAccessToken` UX hint (the signature is never
/// verified client-side, docs/40 §11.4).
String fakeJwt({
  String sub = 'user-1',
  String role = 'user',
  Duration ttl = const Duration(minutes: 15),
}) {
  String seg(Map<String, Object?> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final int exp = DateTime.now().add(ttl).millisecondsSinceEpoch ~/ 1000;
  final String header = seg(<String, Object?>{'alg': 'HS256', 'typ': 'JWT'});
  final String payload = seg(<String, Object?>{
    'sub': sub,
    'role': role,
    'exp': exp,
  });
  return '$header.$payload.sig';
}

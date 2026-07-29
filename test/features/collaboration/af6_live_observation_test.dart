/// Stage-1 live observation for defect **C-1** (`docs/56` §2.1) — tagged `live`, so
/// it is skipped by `flutter test` and run deliberately against a real backend:
///
///   (platfrom) pnpm e2e:up
///   (mobile)   flutter test --run-skipped --tags live
///
/// (`--run-skipped` is needed as well as `--tags`: the tag is marked `skip` in
/// `dart_test.yaml` so a default `flutter test` never attempts the network.)
///
/// This is the check that was missing. Every other AF6 test mocks the data source, so
/// the capability payload was never decoded from a real response and C-1 — an empty map
/// that hid every affordance on every story — was invisible to a green suite.
///
/// Nothing is mocked in the read path: real `Dio` → real `ApiClient` (real envelope
/// unwrap) → real `CollaborationRemoteDataSource` → real repository → real
/// `storyCapabilitiesProvider`. The only stand-ins are the auth token (fetched over
/// HTTP first) and connectivity. Widget-level assertions are excluded on purpose —
/// see the note at the bottom of the file.
@Tags(<String>['live'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/connectivity/connectivity_service.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/network/api_client.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/collaboration_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/publishing_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/trust_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/policy_capability.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/review_session.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/trust_summary.dart';
import 'package:qalam_mobile/features/collaboration/presentation/providers/collaboration_providers.dart';

const String _origin = 'http://localhost:4000';
const String _apiBase = '$_origin/api/v1';
const String _email = 'writer@qalam.local';
const String _password = 'ChangeMe!Writer1';

const AppConfig _collabConfig = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: _origin,
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: false,
  enableMonetization: false,
  enableCollaboration: true,
);

void main() {
  late Dio dio;
  late ApiClient api;
  late String storyId;

  setUpAll(() async {
    // Widget tests install an HttpOverrides that fails every request; clear it so
    // the observation actually reaches the backend.
    HttpOverrides.global = null;

    final Dio auth = Dio(BaseOptions(baseUrl: _apiBase));
    final Response<dynamic> login = await auth.post<dynamic>(
      '/auth/login',
      data: <String, Object?>{'email': _email, 'password': _password},
    );
    final Map<String, dynamic> loginData =
        (login.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final String token = loginData['accessToken'] as String;

    dio = Dio(
      BaseOptions(
        baseUrl: _apiBase,
        headers: <String, Object?>{'Authorization': 'Bearer $token'},
      ),
    );
    api = ApiClient(dio: dio, connectivity: ConnectivityService());

    // Any piece the writer owns is a "story" (`storyId === pieceId`).
    final Response<dynamic> pieces = await dio.get<dynamic>(
      '/me/pieces',
      queryParameters: <String, Object?>{'limit': 1},
    );
    final List<dynamic> rows =
        (pieces.data as Map<String, dynamic>)['data'] as List<dynamic>;
    expect(
      rows,
      isNotEmpty,
      reason: 'seed a piece first (pnpm --filter backend seed:e2e)',
    );
    storyId = (rows.first as Map<String, dynamic>)['id'] as String;
  });

  // Untyped list: the concrete `Override` type is not exported for annotation
  // (same reason as `test/support/harness.dart`).
  ProviderContainer container() => ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(_collabConfig),
      collaborationRemoteDataSourceProvider.overrideWithValue(
        CollaborationRemoteDataSource(api),
      ),
      publishingRemoteDataSourceProvider.overrideWithValue(
        PublishingRemoteDataSource(api),
      ),
      trustRemoteDataSourceProvider.overrideWithValue(
        TrustRemoteDataSource(api),
      ),
    ],
  );

  test('the real capability payload decodes to a populated map', () async {
    final ProviderContainer c = container();
    addTearDown(c.dispose);

    final StoryCapabilities caps = await c.read(
      storyCapabilitiesProvider(storyId).future,
    );

    // Pre-fix this was empty on a 200 response.
    expect(caps.capabilities, isNotEmpty);
    expect(caps.storyId, storyId);
    for (final String action in PolicyAction.serverExplained) {
      expect(
        caps.capabilities.containsKey(action),
        isTrue,
        reason: '$action missing — COLLABORATION_CAPABILITY_ACTIONS moved',
      );
    }
  });

  test(
    'an owner is allowed the actions the collaboration screens gate on',
    () async {
      final ProviderContainer c = container();
      addTearDown(c.dispose);

      final StoryCapabilities caps = await c.read(
        storyCapabilitiesProvider(storyId).future,
      );

      expect(caps.allows(PolicyAction.storyComment), isTrue);
      expect(caps.allows(PolicyAction.storySuggest), isTrue);
      expect(caps.allows(PolicyAction.suggestionResolve), isTrue);
      expect(caps.allows(PolicyAction.commentResolve), isTrue);
      expect(caps.allows(PolicyAction.storyInvite), isTrue);
      expect(caps.allows(PolicyAction.storyManageMembers), isTrue);
    },
  );

  test(
    'C-2 is closed on a live server — the publishing gates get a verdict',
    () async {
      final ProviderContainer c = container();
      addTearDown(c.dispose);

      final StoryCapabilities caps = await c.read(
        storyCapabilitiesProvider(storyId).future,
      );

      // The owner used to be denied these purely because the server did not explain
      // them, so all five publishing gates rendered nothing (docs/56 §2.1 C-2).
      expect(caps.capabilities, hasLength(PolicyAction.serverExplained.length));
      for (final String action in <String>[
        PolicyAction.storyEdit,
        PolicyAction.publicationPublish,
        PolicyAction.reviewApprove,
      ]) {
        expect(
          caps.capabilities.containsKey(action),
          isTrue,
          reason: '$action missing — COLLABORATION_CAPABILITY_ACTIONS moved',
        );
        expect(caps.allows(action), isTrue, reason: 'the owner may $action');
      }
    },
  );

  test('the members roster loads the owner from the live server', () async {
    final ProviderContainer c = container();
    addTearDown(c.dispose);
    final List<StoryMember> members = await c.read(
      storyMembersProvider(storyId).future,
    );

    // `listMembers` synthesises the owner row (joinedAt null, role owner).
    expect(members, isNotEmpty);
    expect(members.first.isOwner, isTrue);
    expect(members.first.role, StoryRole.owner);
  });

  test('a story with no review session yields null, not an error (P-4)', () async {
    final ProviderContainer c = container();
    addTearDown(c.dispose);

    // The endpoint answers `200 {"success":true,"data":null}`. Verified by hand
    // against the local backend; pinned here so the null path stays exercised.
    final ReviewSession? review = await c.read(
      storyReviewProvider(storyId).future,
    );

    expect(review, isNull);
  });

  test(
    'the live trust summary decodes (T-4) and drives no false restriction',
    () async {
      final ProviderContainer c = container();
      addTearDown(c.dispose);

      final TrustSummary trust = await c.read(trustSummaryProvider.future);

      expect(trust.level, isNotEmpty);
      expect(trust.status, isNotEmpty);
      // A seeded writer is in good standing, so the RestrictedBanner must stay hidden.
      expect(trust.isRestricted, isFalse);
    },
  );

  // Deliberately NOT a `testWidgets` here: real HTTP inside `pumpAndSettle` does
  // not resolve against the widget tester's clock and hangs the run. The rendering
  // half of C-1 is covered by `collaboration_widgets_test.dart` (mocked repo) and
  // the decode half by `capability_contract_test.dart` — this file's job is to
  // prove the real wire shape reaches a populated map.
}

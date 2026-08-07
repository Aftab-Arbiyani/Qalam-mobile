/// The W5-2 upgrade to "More like this" (docs/48 §3.9) — the AF4 recommender for
/// a signed-in reader on an AI-on build, with a tag-search fallback. Complements
/// `related_pieces_test.dart`, which covers the pre-existing tag-search-only
/// behaviour (still exercised by default here, since `enableAi` defaults false).
///
/// `RelatedPieces` is pumped directly (not through the whole `ReadingScreen`) with
/// a minimal `ProviderContainer`, mirroring `follow_button_test.dart`'s pattern for
/// controlling `sessionControllerProvider` without simulating real token restore.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/session/session_controller.dart';
import 'package:qalam_mobile/core/session/session_state.dart';
import 'package:qalam_mobile/features/ai/ai.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_detail.dart';
import 'package:qalam_mobile/features/reading/presentation/providers/reading_providers.dart';
import 'package:qalam_mobile/features/reading/presentation/widgets/related_pieces.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/fake_reading_repository.dart';

const AppConfig _aiOn = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: true,
  enableMonetization: false,
  enableCollaboration: false,
);

const AppConfig _aiOff = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: false,
  enableMonetization: false,
  enableCollaboration: false,
);

class _AuthedSession extends SessionController {
  @override
  Future<SessionState> build() async =>
      const SessionState.authenticated(role: Role.user);
}

class _AnonSession extends SessionController {
  @override
  Future<SessionState> build() async => const SessionState.anonymous();
}

AiFeatures _features({bool recommendationsOn = true}) => AiFeatures(
  aiEnabled: true,
  features: <AiFeatureFlag>[
    AiFeatureFlag(
      feature: AiFeatureIds.recommendations,
      flagKey: 'feature.ai.recommendations.enabled',
      enabled: recommendationsOn,
    ),
  ],
);

RecommendationItem _pieceRecommendation({
  String id = 'p2',
  String reason = 'Shares tags with "A Ghazal for the Evening": ghazal',
}) => RecommendationItem(
  id: id,
  kind: 'related_stories',
  targetType: 'piece',
  title: 'Second Evening',
  summary: '',
  object: <String, dynamic>{
    'id': id,
    'title': 'Second Evening',
    'subtitle': 'a companion piece',
    'readingTimeSeconds': 180,
    'author': <String, dynamic>{'username': 'noor', 'penName': 'Noor'},
    'language': <String, dynamic>{'direction': 'ltr'},
  },
  score: 0.9,
  confidence: 0.9,
  reason: reason,
  influencedBy: const <RelatedEntity>[],
  evidence: const <RetrievalEvidence>[],
  navigation: NavigationTarget(kind: 'piece', ref: id),
);

PieceDetail _piece({List<TagRef> tags = const <TagRef>[]}) => PieceDetail(
  id: 'p1',
  title: 'A Ghazal for the Evening',
  author: const Author(username: 'farheen', penName: 'Farheen'),
  language: const LanguageRef(code: 'en'),
  tags: tags,
  content: const <String, dynamic>{
    'type': 'doc',
    'content': <dynamic>[
      <String, dynamic>{
        'type': 'paragraph',
        'content': <dynamic>[
          <String, dynamic>{'type': 'text', 'text': 'The evening settled.'},
        ],
      },
    ],
  },
);

PieceSummary _summary(String id, String title) => PieceSummary(
  id: id,
  title: title,
  author: const Author(username: 'noor', penName: 'Noor'),
  language: const LanguageRef(code: 'en'),
  readingTimeSeconds: 240,
);

ProviderContainer _container({
  required AppConfig config,
  required bool authed,
  FakeAiRepository? aiRepository,
  FakeReadingRepository? readingRepository,
}) => ProviderContainer(
  // Riverpod's default retry policy re-attempts a thrown `Failure` (it isn't a
  // Dart `Error`, the one type the policy exempts) up to 10 times with
  // exponential backoff — a real `Timer` the fake repos below never need and
  // fake-async's pump budget can't outrun. Disabled so an injected failure
  // settles to `AsyncError` on the first attempt, with no pending Timer left
  // over for `flutter_test`'s teardown assertion to trip on.
  retry: (int retryCount, Object error) => null,
  overrides: [
    appConfigProvider.overrideWithValue(config),
    sessionControllerProvider.overrideWith(
      authed ? _AuthedSession.new : _AnonSession.new,
    ),
    aiRepositoryProvider.overrideWithValue(aiRepository ?? FakeAiRepository()),
    readingRepositoryProvider.overrideWithValue(
      readingRepository ?? FakeReadingRepository(),
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester,
  ProviderContainer container,
  PieceDetail piece,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: Scaffold(body: RelatedPieces(piece: piece)),
      ),
    ),
  );
  // Bounded pumps for the async provider chain (config → session → aiFeatures →
  // recommendations, or the tag-search fallback) to settle — no infinite
  // animation here, so a handful of frames is enough.
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets(
    'a signed-in reader on an AI-on build sees the recommender, with its reason',
    (WidgetTester tester) async {
      final FakeReadingRepository reading = FakeReadingRepository();
      final ProviderContainer c = _container(
        config: _aiOn,
        authed: true,
        aiRepository: FakeAiRepository(
          features: _features(),
          recommendations: RecommendationResponse(
            kind: 'related_stories',
            items: <RecommendationItem>[_pieceRecommendation()],
            meta: const RetrievalResponseMeta(
              sources: <String>['search'],
              totalCandidates: 1,
              returned: 1,
              confidence: 0.9,
              degraded: false,
            ),
          ),
        ),
        readingRepository: reading,
      );
      addTearDown(c.dispose);

      await _pump(
        tester,
        c,
        _piece(
          tags: const <TagRef>[TagRef(slug: 'ghazal', name: 'ghazal')],
        ),
      );

      expect(find.text('More like this'), findsOneWidget);
      expect(find.text('Second Evening'), findsOneWidget);
      expect(
        find.text('Shares tags with "A Ghazal for the Evening": ghazal'),
        findsOneWidget,
      );
      // Never in parallel: the recommender answered, so the tag search never ran.
      expect(reading.lastRelatedTag, isNull);
    },
  );

  testWidgets(
    'an empty recommender result falls back to the tag search (no reason shown)',
    (WidgetTester tester) async {
      final FakeReadingRepository reading = FakeReadingRepository(
        related: <PieceSummary>[_summary('p2', 'Second Evening')],
      );
      final ProviderContainer c = _container(
        config: _aiOn,
        authed: true,
        aiRepository: FakeAiRepository(
          features: _features(),
          recommendations: const RecommendationResponse(
            kind: 'related_stories',
            items: <RecommendationItem>[],
            meta: RetrievalResponseMeta(
              sources: <String>[],
              totalCandidates: 0,
              returned: 0,
              confidence: 0,
              degraded: false,
            ),
          ),
        ),
        readingRepository: reading,
      );
      addTearDown(c.dispose);

      await _pump(
        tester,
        c,
        _piece(
          tags: const <TagRef>[TagRef(slug: 'ghazal', name: 'ghazal')],
        ),
      );

      expect(find.text('More like this'), findsOneWidget);
      expect(find.text('Second Evening'), findsOneWidget);
      expect(reading.lastRelatedTag?.slug, 'ghazal');
      // The fallback has nothing to explain itself with.
      expect(find.textContaining('Shares tags with'), findsNothing);
    },
  );

  testWidgets(
    'a recommender error falls back to the tag search rather than surfacing it',
    (WidgetTester tester) async {
      final FakeReadingRepository reading = FakeReadingRepository(
        related: <PieceSummary>[_summary('p2', 'Second Evening')],
      );
      final ProviderContainer c = _container(
        config: _aiOn,
        authed: true,
        // `features()` succeeds — only the recommendation fetch itself fails,
        // isolating this from the feature-flag check.
        aiRepository: FakeAiRepository(
          features: _features(),
          recommendationsFailure: const NetworkFailure(
            code: 'API_NETWORK_ERROR',
          ),
        ),
        readingRepository: reading,
      );
      addTearDown(c.dispose);

      await _pump(
        tester,
        c,
        _piece(
          tags: const <TagRef>[TagRef(slug: 'ghazal', name: 'ghazal')],
        ),
      );

      expect(find.text('More like this'), findsOneWidget);
      expect(find.text('Second Evening'), findsOneWidget);
      expect(reading.lastRelatedTag?.slug, 'ghazal');
      expect(find.textContaining('went wrong'), findsNothing);
    },
  );

  testWidgets(
    'no tag and an AI-off build renders nothing and queries neither source',
    (WidgetTester tester) async {
      final FakeReadingRepository reading = FakeReadingRepository(
        related: <PieceSummary>[_summary('p2', 'Second Evening')],
      );
      final ProviderContainer c = _container(
        config: _aiOff,
        authed: true,
        readingRepository: reading,
      );
      addTearDown(c.dispose);

      await _pump(tester, c, _piece());

      expect(find.text('More like this'), findsNothing);
      expect(reading.lastRelatedTag, isNull);
    },
  );

  testWidgets(
    'a signed-out reader gets the tag search only, matching the public page',
    (WidgetTester tester) async {
      final FakeReadingRepository reading = FakeReadingRepository(
        related: <PieceSummary>[_summary('p2', 'Second Evening')],
      );
      final FakeAiRepository ai = FakeAiRepository(features: _features());
      final ProviderContainer c = _container(
        config: _aiOn,
        authed: false,
        aiRepository: ai,
        readingRepository: reading,
      );
      addTearDown(c.dispose);

      await _pump(
        tester,
        c,
        _piece(
          tags: const <TagRef>[TagRef(slug: 'ghazal', name: 'ghazal')],
        ),
      );

      expect(find.text('More like this'), findsOneWidget);
      expect(find.text('Second Evening'), findsOneWidget);
      expect(reading.lastRelatedTag?.slug, 'ghazal');
      // Signed out never even asks the recommender.
      expect(ai.lastRecommendationQuery, isNull);
      expect(find.textContaining('Shares tags with'), findsNothing);
    },
  );
}

/// The recommendation shelves on `/discover` (**D5**, M2).
///
/// D5 deleted the "Discover with AI" hub and moved its shelves here. The hub was the
/// mistake, not the shelves: it put personalised recommendations behind a door named
/// after the technology, so a reader had to already want "AI" to find writing chosen
/// for them.
///
/// The move is only safe because of the condition these tests pin. Recommendations are
/// authenticated and `/discover` is public, so mounting a shelf for an anonymous reader
/// would fire a 401 — terminal to `ApiClient` outside `/auth/*`, ending the session of
/// someone who was only browsing. **So the signed-out assertion is about the REQUEST,
/// not the rendering**: both are absent, but only one of those is observable from
/// outside, and the other is the one that breaks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/core/session/session_controller.dart';
import 'package:umberleaf_mobile/core/session/session_state.dart';
import 'package:umberleaf_mobile/features/feed/presentation/screens/discover_screen.dart';
import 'package:umberleaf_mobile/shared/domain/enums.dart';
import 'package:umberleaf_mobile/shared/retrieval/domain/retrieval.dart';
import 'package:umberleaf_mobile/shared/theme/app_theme.dart';

import '../../support/fake_retrieval_repository.dart';
import '../../support/harness.dart';

class _AuthedSession extends SessionController {
  @override
  Future<SessionState> build() async =>
      const SessionState.authenticated(role: Role.user);
}

class _AnonSession extends SessionController {
  @override
  Future<SessionState> build() async => const SessionState.anonymous();
}

RecommendationResponse _shelf(String kind, String title) =>
    RecommendationResponse(
      kind: kind,
      items: <RecommendationItem>[
        RecommendationItem(
          id: 'p-$kind',
          kind: kind,
          targetType: 'piece',
          title: title,
          summary: '',
          object: const <String, dynamic>{},
          score: 0.9,
          confidence: 0.9,
          reason: 'Because you read Ghazals',
          influencedBy: const <RelatedEntity>[],
          evidence: const <RetrievalEvidence>[],
          navigation: const NavigationTarget(kind: 'piece', ref: 'p1'),
        ),
      ],
      meta: const RetrievalResponseMeta(
        sources: <String>[],
        totalCandidates: 1,
        returned: 1,
        confidence: 0.9,
        degraded: false,
      ),
    );

Future<FakeRetrievalRepository> _pumpDiscover(
  WidgetTester tester, {
  required bool authed,
  RecommendationResponse? recommendations,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final FakeRetrievalRepository retrieval = FakeRetrievalRepository(
    recommendations: recommendations,
  );
  late final Widget app;
  await tester.runAsync(() async {
    app = await buildTestApp(
      retrievalRepository: retrieval,
      sessionOverride: authed ? _AuthedSession.new : _AnonSession.new,
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const DiscoverScreen(),
      ),
    );
  });
  await tester.pumpWidget(app);
  await settleFrames(tester);
  return retrieval;
}

void main() {
  testWidgets('a signed-in reader gets both shelves, de-branded', (
    WidgetTester tester,
  ) async {
    final FakeRetrievalRepository retrieval = await _pumpDiscover(
      tester,
      authed: true,
      recommendations: _shelf('feed', 'A Ghazal for the Evening'),
    );

    // D5's copy: "For you" became "Recommended for you", and `continue_reading`
    // became "Pick up next" — the feed already uses "Continue reading" for the
    // reader's own unfinished pieces, which is a different thing entirely.
    expect(find.text('Recommended for you'), findsOneWidget);
    expect(find.text('Pick up next'), findsOneWidget);
    expect(retrieval.recommendationCalls, 2);

    // The shelf carries the ranker's reason. Nothing on it says "AI".
    expect(find.textContaining('Because you read'), findsWidgets);
  });

  testWidgets('an anonymous reader sees no shelf AND triggers no request', (
    WidgetTester tester,
  ) async {
    final FakeRetrievalRepository retrieval = await _pumpDiscover(
      tester,
      authed: false,
      recommendations: _shelf('feed', 'A Ghazal for the Evening'),
    );

    expect(find.text('Recommended for you'), findsNothing);
    expect(find.text('Pick up next'), findsNothing);
    // The assertion that matters — a rendered nothing would look identical either way.
    expect(retrieval.recommendationCalls, 0);
    // And the rest of the page is untouched: this is a shelf that hides, not a wall.
    expect(find.byType(DiscoverScreen), findsOneWidget);
  });

  testWidgets('an empty recommender hides the shelf rather than announcing it', (
    WidgetTester tester,
  ) async {
    // `/discover` has real content above and below; a shelf reporting its own emptiness
    // to a reader who never asked for it is noise.
    await _pumpDiscover(tester, authed: true);

    expect(find.text('Recommended for you'), findsNothing);
    expect(find.text('Pick up next'), findsNothing);
    expect(find.byType(DiscoverScreen), findsOneWidget);
  });
}

/// **"Map this story"** — the trigger D5 added (AF3).
///
/// Story Map was hollow before this. `POST /story-intelligence/:storyId/analyze` had
/// shipped with the graph platform and **no client anywhere could reach it**
/// (`platfrom/docs/48` §3.22d), so every view of every story said "nothing here yet",
/// permanently. That is the state these tests exist to make impossible to return to.
///
/// Two properties carry the weight, and neither is about rendering:
///
/// 1. **The run sends the story's TEXT.** The endpoint takes content in the body rather
///    than reading the saved piece, so a writer can map an unsaved draft. A screen that
///    had only the `storyId` would offer a button whose request the DTO rejects.
/// 2. **A finished run refreshes the views.** The graph is server state that just
///    changed; without the refresh the writer maps their story and watches the same
///    empty screen — which is indistinguishable from the defect above.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/core/config/app_config.dart';
import 'package:umberleaf_mobile/core/config/app_flavor.dart';
import 'package:umberleaf_mobile/features/ai/domain/entities/story_graph.dart';
import 'package:umberleaf_mobile/features/ai/domain/entities/story_map_event.dart';
import 'package:umberleaf_mobile/features/ai/presentation/controllers/story_map_controller.dart';
import 'package:umberleaf_mobile/features/ai/presentation/screens/story_explorer_screen.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:umberleaf_mobile/l10n/generated/app_localizations.dart';
import 'package:umberleaf_mobile/shared/theme/app_theme.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/harness.dart';

const AppConfig _monetizationOn = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: true,
  enableMonetization: true,
  enableCollaboration: false,
);

const EntitlementSnapshot _pro = EntitlementSnapshot(
  tier: PlanTier.pro,
  status: EntitlementStatus.allow,
  features: <EntitlementDecision>[
    EntitlementDecision(
      feature: PremiumFeature.storyIntelligence,
      status: EntitlementStatus.allow,
      allowed: true,
      reason: EntitlementReason.planIncludes,
    ),
  ],
);

const ExplorerViewResult _empty = ExplorerViewResult(
  storyId: 'piece-1',
  view: 'characters',
  nodes: <StoryGraphNode>[],
  edges: <StoryGraphEdge>[],
  nodeCount: 0,
  edgeCount: 0,
);

const String _content = 'The cartographer folded the last map.';

Widget _wrap(Widget home) => MaterialApp(
  theme: buildUmberleafTheme(brightness: Brightness.light),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

Future<FakeAiRepository> _pump(
  WidgetTester tester, {
  String? content = _content,
  List<StoryMapEvent> events = const <StoryMapEvent>[],
  Future<void>? mapHold,
}) async {
  tester.view.physicalSize = const Size(800, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final FakeAiRepository fake = FakeAiRepository(
    explorer: _empty,
    mapEvents: events,
    mapHold: mapHold,
  );
  late final Widget app;
  await tester.runAsync(() async {
    app = await buildTestApp(
      config: _monetizationOn,
      entitlementSnapshot: _pro,
      aiRepository: fake,
      child: _wrap(
        StoryExplorerScreen(
          storyId: 'piece-1',
          content: content,
          storyTitle: 'The Cartographer',
        ),
      ),
    );
  });
  await tester.pumpWidget(app);
  await settleFrames(tester);
  return fake;
}

List<StoryMapEvent> _fullRun() => <StoryMapEvent>[
  for (int i = 1; i <= 5; i++)
    StoryMapEvent(
      type: StoryMapEventType.progress,
      step: i,
      total: 5,
      analysis: 'character',
    ),
  const StoryMapEvent(
    type: StoryMapEventType.done,
    completed: <String>['character', 'plot', 'world', 'style', 'timeline'],
  ),
];

void main() {
  group('the trigger', () {
    testWidgets('is offered when the editor handed the story’s text over', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      expect(find.text('Map this story'), findsOneWidget);
    });

    /// A deep link reaches this route with no `extra`, so there is no text to send.
    /// Greying the button out would read as "you are not allowed", which is false — the
    /// writer is allowed, they are just in the wrong place. Saying where to go is the
    /// only honest option.
    testWidgets('explains itself rather than failing when there is no text', (
      WidgetTester tester,
    ) async {
      await _pump(tester, content: null);

      expect(find.text('Map this story'), findsNothing);
      expect(
        find.text('Open this story in the editor to map it.'),
        findsOneWidget,
      );
    });

    testWidgets('sends the CONTENT, not just the story id', (
      WidgetTester tester,
    ) async {
      final FakeAiRepository fake = await _pump(tester, events: _fullRun());

      await tester.tap(find.text('Map this story'));
      await settleFrames(tester);

      expect(fake.lastMappedStoryId, 'piece-1');
      expect(fake.lastMappedContent, _content);
      expect(fake.lastMappedTitle, 'The Cartographer');
    });
  });

  group('the run', () {
    testWidgets('reports progress as a step counter', (
      WidgetTester tester,
    ) async {
      // A gate that holds the stream open after the progress frame, so the mid-run UI
      // can be observed. Without it the fake drains in microtasks, the run ends before
      // a frame is painted, and the test would pass while asserting nothing about
      // progress at all — a green test that is green because the feature never ran.
      final Completer<void> hold = Completer<void>();
      addTearDown(hold.complete);
      await _pump(
        tester,
        mapHold: hold.future,
        events: <StoryMapEvent>[
          const StoryMapEvent(
            type: StoryMapEventType.progress,
            step: 2,
            total: 5,
            analysis: 'plot',
          ),
        ],
      );

      await tester.tap(find.text('Map this story'));
      await tester.pump();

      expect(find.textContaining('step 2 of 5'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);
      // D5 decision 9 — the disclosure rides along, because this is the one action on
      // this screen that sends the writer's text to a model.
      expect(find.textContaining('language model'), findsOneWidget);
    });

    /// The property that separates a working feature from the hollow one it replaced.
    testWidgets('a finished run refetches the graph', (
      WidgetTester tester,
    ) async {
      final FakeAiRepository fake = await _pump(tester, events: _fullRun());
      // The screen loaded one view already.
      expect(fake.explorerCallCount, 1);

      await tester.tap(find.text('Map this story'));
      await settleFrames(tester);

      expect(
        fake.explorerCallCount,
        greaterThan(1),
        reason:
            'a mapped story that still renders the pre-map graph is the old defect',
      );
      // Back to the trigger, ready to re-run: re-mapping folds into the same graph.
      expect(find.text('Map this story'), findsOneWidget);
    });

    /// The server reserves all five analyses BEFORE the first call, so a writer short of
    /// allowance is refused up front instead of being left with a half-built graph. The
    /// copy has to say that, not "something went wrong".
    testWidgets('a quota refusal gets the allowance remedy', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        events: <StoryMapEvent>[
          const StoryMapEvent(
            type: StoryMapEventType.error,
            code: 'QUOTA_EXCEEDED',
            message: 'no allowance',
          ),
        ],
      );

      await tester.tap(find.text('Map this story'));
      await settleFrames(tester);

      expect(find.textContaining('allowance'), findsWidgets);
      expect(find.text('Back'), findsOneWidget);
    });

    /// A run that stops partway keeps what it folded in, and says so — the alternative
    /// is a writer who re-runs from scratch believing nothing landed.
    testWidgets('a mid-run failure names what survived', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        events: <StoryMapEvent>[
          const StoryMapEvent(
            type: StoryMapEventType.progress,
            step: 1,
            total: 5,
            analysis: 'character',
          ),
          const StoryMapEvent(
            type: StoryMapEventType.progress,
            step: 2,
            total: 5,
            analysis: 'plot',
          ),
          const StoryMapEvent(
            type: StoryMapEventType.error,
            code: 'STORY_MAP_FAILED',
          ),
        ],
      );

      await tester.tap(find.text('Map this story'));
      await settleFrames(tester);

      expect(find.textContaining('stayed in your map'), findsOneWidget);
    });
  });

  group('the controller', () {
    test('a stream that ends without `done` is a failure, not a success', () async {
      // The socket dropping mid-run leaves the graph half-built. Treating the closed
      // stream as completion would tell the writer their story is mapped when it is not.
      final ProviderContainer container = await buildTestContainer(
        aiRepository: FakeAiRepository(
          mapEvents: <StoryMapEvent>[
            const StoryMapEvent(
              type: StoryMapEventType.progress,
              step: 1,
              total: 5,
              analysis: 'character',
            ),
          ],
        ),
      );
      addTearDown(container.dispose);
      container.listen(storyMapControllerProvider, (_, _) {});

      await container
          .read(storyMapControllerProvider.notifier)
          .run('piece-1', content: _content);

      final StoryMapState state = container.read(storyMapControllerProvider);
      expect(state.phase, StoryMapPhase.error);
      expect(state.errorCode, 'STORY_MAP_FAILED');
    });
  });
}

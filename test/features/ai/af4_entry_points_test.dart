/// Regression guard for defect **W5-3** (`platfrom/docs/48` §3.9).
///
/// `app_router.dart` registered `/ai/explorer/:storyId` and `/ai/ask/:storyId`, and **no
/// `push`/`go` site for either existed anywhere in `lib/`**. `AskBookScreen` was pushed
/// from exactly one place — the Story Explorer's app bar — i.e. from a screen nobody
/// could open. Both surfaces compiled, had tests, and could not be reached by a user;
/// the AF4 readiness report's own manual-test steps say "deep-link `/ai/explorer/…`",
/// which is the tell.
///
/// Third instance of the class: **R-1** registered six AF6 routes nothing navigated to,
/// **M5-1** shipped `PremiumGate` with zero call sites, now this. So these tests assert
/// what those defects slipped past — that a **user action opens the screen**, not that a
/// route exists:
///
/// 1. **The entry point navigates and the real screen mounts.** Both routes are served by
///    the actual `StoryExplorerScreen` / `AskBookScreen`, not stub targets, so a tap has
///    to survive the whole push.
/// 2. **The Explorer → Ask hop still works**, since that chain was the only thing keeping
///    Ask alive and it must not regress into being the only thing again.
/// 3. **The gates match the routes they open.** `GET /ai/explorer/:storyId/:view` is
///    `ai.use` only; `POST /ai/ask` also needs `feature.ai.askBook`. Gating the explorer
///    on askBook would hide a surface the server would serve — the mirror-image mistake.
/// 4. **The app's own router serves both names**, closing the loop the other half opens.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qalam_mobile/app/router/app_router.dart';
import 'package:qalam_mobile/app/router/routes.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/ai/domain/entities/ai_feature_flag.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/ai_feature_ids.dart';
import 'package:qalam_mobile/features/ai/presentation/screens/ask_book_screen.dart';
import 'package:qalam_mobile/features/ai/presentation/screens/story_explorer_screen.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/presentation/controllers/current_draft_controller.dart';
import 'package:qalam_mobile/features/writing/presentation/providers/writing_providers.dart';
import 'package:qalam_mobile/features/writing/presentation/screens/editor_screen.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/fake_writing.dart';
import '../../support/harness.dart';

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

/// `storyId === pieceId` server-side, so the routes take the draft's **remoteId**. A draft
/// that has never synced has no story to explore, which is what hides the entries.
const String _remoteId = 'a1b2c3d4-0000-4000-8000-000000000001';
const String _localId = 'loc-1';

Draft _draft({String? remoteId = _remoteId}) => Draft(
  localId: _localId,
  remoteId: remoteId,
  title: 'The Cartographer',
  languageCode: 'en',
  wordCount: 4,
  content: const <String, dynamic>{
    'type': 'doc',
    'content': <dynamic>[
      <String, dynamic>{
        'type': 'paragraph',
        'content': <dynamic>[
          <String, dynamic>{'type': 'text', 'text': 'once upon a time'},
        ],
      },
    ],
  },
  createdAt: DateTime.utc(2026, 7),
  localUpdatedAt: DateTime.utc(2026, 7, 2),
);

AiFeatures _features({required bool askBook}) => AiFeatures(
  aiEnabled: true,
  features: <AiFeatureFlag>[
    // The editor's AI group is gated on these two; without one of them the overflow's
    // whole AI section is absent and the AF4 group would have nothing to sit under.
    const AiFeatureFlag(
      feature: AiFeatureIds.writingAssistant,
      flagKey: 'feature.ai.writingAssistant.enabled',
      enabled: true,
    ),
    AiFeatureFlag(
      feature: AiFeatureIds.askBook,
      flagKey: 'feature.ai.askBook.enabled',
      enabled: askBook,
    ),
  ],
);

/// The server's master switch down, with this feature's own flag irrelevant — the state
/// `assertEnabled` reports as `AI_DISABLED` rather than `AI_FEATURE_DISABLED`.
const AiFeatures _allAiOff = AiFeatures(
  aiEnabled: false,
  features: <AiFeatureFlag>[
    AiFeatureFlag(
      feature: AiFeatureIds.askBook,
      flagKey: 'feature.ai.askBook.enabled',
      enabled: true,
    ),
  ],
);

/// B5 — the account's OWN switch down, with every platform flag up. `aiEnabled` is the
/// server's AND of the two, so it arrives false while `userAiEnabled` names the cause.
const AiFeatures _userTurnedAiOff = AiFeatures(
  aiEnabled: false,
  userAiEnabled: false,
  features: <AiFeatureFlag>[
    AiFeatureFlag(
      feature: AiFeatureIds.writingAssistant,
      flagKey: 'feature.ai.writingAssistant.enabled',
      enabled: true,
    ),
    AiFeatureFlag(
      feature: AiFeatureIds.askBook,
      flagKey: 'feature.ai.askBook.enabled',
      enabled: true,
    ),
  ],
);

/// The editor mounted inside a router that serves the two **real** AF4 screens.
Future<void> _pumpEditor(
  WidgetTester tester, {
  AppConfig config = _aiOn,
  bool askBook = true,
  String? remoteId = _remoteId,
  AiFeatures? features,
}) async {
  tester.view.physicalSize = const Size(700, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  late final ProviderContainer container;
  await tester.runAsync(() async {
    container = await buildTestContainer(
      config: config,
      pieceEditorRepository: FakePieceEditorRepository(),
      taxonomyRepository: FakeTaxonomyRepository(),
      aiRepository: FakeAiRepository(
        features: features ?? _features(askBook: askBook),
      ),
    );
    // No debounced autosave timers bleeding across tests.
    await container.read(preferencesStoreProvider).setEditorAutosave(false);
    await container
        .read(draftLocalDataSourceProvider)
        .write(_draft(remoteId: remoteId));
    container.listen(currentDraftControllerProvider(_localId), (_, _) {});
    await container.read(currentDraftControllerProvider(_localId).future);
  });
  addTearDown(container.dispose);

  final GoRouter router = GoRouter(
    initialLocation: '${Routes.write}/$_localId',
    routes: <RouteBase>[
      GoRoute(
        path: '${Routes.write}/:id',
        builder: (_, GoRouterState s) =>
            EditorScreen(draftId: s.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '${Routes.aiExplorer}/:storyId',
        builder: (_, GoRouterState s) =>
            StoryExplorerScreen(storyId: s.pathParameters['storyId'] ?? ''),
      ),
      GoRoute(
        path: '${Routes.aiAsk}/:storyId',
        builder: (_, GoRouterState s) =>
            AskBookScreen(storyId: s.pathParameters['storyId'] ?? ''),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: buildQalamTheme(brightness: Brightness.light),
        routerConfig: router,
      ),
    ),
  );
  await settleFrames(tester);
}

Future<void> _openOverflow(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();
}

/// Open Story Explorer the way a **deep link** does — straight at the route. B5's gate
/// has to hold on the destination too, or hiding the overflow entry is theatre.
Future<void> _pushExplorer(WidgetTester tester) async {
  final BuildContext context = tester.element(find.byType(EditorScreen));
  unawaited(GoRouter.of(context).push(Routes.aiExplorerPath(_remoteId)));
  await tester.pumpAndSettle();
}

/// Open Ask My Book the way a **deep link** does — straight at the route, with no menu
/// and no explorer in between. The gate has to hold here or hiding the buttons is theatre
/// (defect **W9-2**).
Future<void> _pushAsk(WidgetTester tester) async {
  final BuildContext context = tester.element(find.byType(EditorScreen));
  // The push's future completes when the route is POPPED, which never happens here.
  unawaited(GoRouter.of(context).push(Routes.aiAskPath(_remoteId)));
  await tester.pumpAndSettle();
}

void main() {
  group('Story Explorer is reachable by a user (W5-3)', () {
    testWidgets('the editor overflow opens the real explorer for this story', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester);
      await _openOverflow(tester);

      expect(find.text('Story explorer'), findsOneWidget);
      await tester.tap(find.text('Story explorer'));
      await tester.pumpAndSettle();

      // The screen itself, not a stub target — a tap that 404s the route or throws on
      // build would fail here rather than pass as "navigated".
      final StoryExplorerScreen screen = tester.widget<StoryExplorerScreen>(
        find.byType(StoryExplorerScreen),
      );
      // The SERVER piece id. `widget.draftId` is the local route id and the endpoint's
      // `ParseUUIDPipe` would reject it — the same trap the AF6 group documents.
      expect(screen.storyId, _remoteId);
      expect(find.text('Story Explorer'), findsOneWidget);
    });
  });

  group('Ask My Book is reachable by a user (W5-3)', () {
    testWidgets('the editor overflow opens it directly', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester);
      await _openOverflow(tester);

      expect(find.text('Ask my book'), findsOneWidget);
      await tester.tap(find.text('Ask my book'));
      await tester.pumpAndSettle();

      final AskBookScreen screen = tester.widget<AskBookScreen>(
        find.byType(AskBookScreen),
      );
      expect(screen.storyId, _remoteId);
      expect(find.text('Ask My Book'), findsOneWidget);
    });

    testWidgets(
      'and the Explorer hop that used to be its only door still works',
      (WidgetTester tester) async {
        await _pumpEditor(tester);
        await _openOverflow(tester);
        await tester.tap(find.text('Story explorer'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Ask about this story'));
        await tester.pumpAndSettle();

        expect(find.byType(AskBookScreen), findsOneWidget);
        expect(
          tester.widget<AskBookScreen>(find.byType(AskBookScreen)).storyId,
          _remoteId,
        );
      },
    );
  });

  group('the entries respect the gates their routes carry (W5-3)', () {
    testWidgets('askBook down hides Ask and keeps the Explorer', (
      WidgetTester tester,
    ) async {
      // The asymmetry is the point: the explorer route is `ai.use` only and renders from
      // the graph with no LLM, so hiding it behind askBook would withhold a surface the
      // server would have served.
      await _pumpEditor(tester, askBook: false);
      await _openOverflow(tester);

      expect(find.text('Story explorer'), findsOneWidget);
      expect(find.text('Ask my book'), findsNothing);
    });

    testWidgets(
      'askBook down: the Explorer no longer offers a door to a walled screen (W9-2)',
      (WidgetTester tester) async {
        // The hole the editor's gate left. `story_explorer_screen.dart` pushed
        // `Routes.aiAskPath` with no flag check at all, so the surface the overflow
        // correctly hid was one tap away from the surface it did open.
        await _pumpEditor(tester, askBook: false);
        await _openOverflow(tester);
        await tester.tap(find.text('Story explorer'));
        await tester.pumpAndSettle();

        expect(find.byType(StoryExplorerScreen), findsOneWidget);
        expect(find.byTooltip('Ask about this story'), findsNothing);
      },
    );

    testWidgets(
      'and the screen itself refuses, so a deep link cannot walk around the gate (W9-2)',
      (WidgetTester tester) async {
        // Hiding the affordance is not the fix on its own: `/ai/ask/:storyId` is a
        // registered route, so a notification or a pasted link reaches it directly. The
        // screen resolves the gate, which is why this asserts the DESTINATION rather than
        // the button — and asserts the wall arrives BEFORE a question can be composed.
        await _pumpEditor(tester, askBook: false);
        await _pushAsk(tester);

        expect(find.byType(AskBookScreen), findsOneWidget);
        expect(find.text('Not available yet'), findsOneWidget);
        // The controls are absent, not merely disabled — nothing invites a request the
        // server has already said it will refuse.
        expect(find.text('Ask'), findsNothing);
        expect(find.text('Whole book'), findsNothing);
      },
    );

    testWidgets('askBook up: the same deep link gets the real surface (W9-2)', (
      WidgetTester tester,
    ) async {
      // The other half — the gate must not be a wall in front of everyone.
      await _pumpEditor(tester);
      await _pushAsk(tester);

      expect(find.text('Not available yet'), findsNothing);
      expect(find.text('Whole book'), findsOneWidget);
    });

    testWidgets(
      'the master switch reads as off, not as this feature being unavailable (W9-2)',
      (WidgetTester tester) async {
        // Ordered as the server checks: `assertEnabled` raises AI_DISABLED before
        // AI_FEATURE_DISABLED, so a stack with AI turned off must not tell the writer
        // that Ask specifically is not enabled for them.
        await _pumpEditor(tester, features: _allAiOff);
        await _pushAsk(tester);

        expect(find.text('AI is turned off'), findsOneWidget);
        expect(find.text('Not available yet'), findsNothing);
      },
    );

    testWidgets('a draft that never synced offers neither', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester, remoteId: null);
      await _openOverflow(tester);

      expect(find.text('Story explorer'), findsNothing);
      expect(find.text('Ask my book'), findsNothing);
    });

    testWidgets('a build with AI dark offers neither', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester, config: testConfig);
      await _openOverflow(tester);

      expect(find.text('Story explorer'), findsNothing);
      expect(find.text('Ask my book'), findsNothing);
      // And the AI management group is gone with it, so this is the kill switch working
      // rather than the new entries being special-cased.
      expect(find.text('AI conversations'), findsNothing);
    });

    /// **B5 (`platfrom/docs/45` §4.10)** — a writer who turned AI off must not be left
    /// with entry points into it.
    ///
    /// Story Explorer is the one that was actually broken: its route carries no feature
    /// flag, so the overflow gated it on the COMPILE-TIME switch and `isRemote` alone and
    /// never consulted the server at all. On a build with AI compiled in, an opted-out
    /// writer kept a live "Story explorer" entry whose first request 403s.
    testWidgets(
      'a writer who turned AI off keeps NO AI entry in the overflow',
      (WidgetTester tester) async {
        await _pumpEditor(tester, features: _userTurnedAiOff);
        await _openOverflow(tester);

        expect(find.text('Story explorer'), findsNothing);
        expect(find.text('Ask my book'), findsNothing);
        expect(find.text('AI conversations'), findsNothing);
        expect(find.text('Prompt library'), findsNothing);
        expect(find.text('AI usage'), findsNothing);
        // The non-AI entries are untouched — B5 turns AI off, not the editor.
        expect(find.text('Save draft'), findsOneWidget);
      },
    );

    testWidgets(
      'the Story Explorer screen itself refuses, naming the writer\u2019s own switch',
      (WidgetTester tester) async {
        // Deep links and stale menus both reach the screen directly, so the affordance
        // disappearing is not enough — the destination has to refuse too.
        await _pumpEditor(tester, features: _userTurnedAiOff);
        await _pushExplorer(tester);

        expect(find.text('You turned AI off'), findsOneWidget);
        // Never the platform copy: the remedy differs (docs/48 §3.6).
        expect(find.text('AI is turned off'), findsNothing);
      },
    );
  });

  group('the app router serves both paths (W5-3)', () {
    test('namedLocation resolves aiExplorer and aiAsk', () async {
      // The other half of the loop. `namedLocation` throws for an unregistered name, so
      // this fails loudly if a route is dropped while the menu entry survives.
      final ProviderContainer container = await buildTestContainer(
        config: _aiOn,
      );
      addTearDown(container.dispose);

      final GoRouter router = container.read(goRouterProvider);
      expect(
        router.namedLocation(
          'aiExplorer',
          pathParameters: <String, String>{'storyId': _remoteId},
        ),
        Routes.aiExplorerPath(_remoteId),
      );
      expect(
        router.namedLocation(
          'aiAsk',
          pathParameters: <String, String>{'storyId': _remoteId},
        ),
        Routes.aiAskPath(_remoteId),
      );
      // Both are session-gated, like every other `/ai` surface.
      expect(Routes.isProtected(Routes.aiExplorerPath(_remoteId)), isTrue);
      expect(Routes.isProtected(Routes.aiAskPath(_remoteId)), isTrue);
    });
  });
}

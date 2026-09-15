/// Regression guard for defect **W5-3** (`platfrom/docs/48` §3.9), narrowed by **D5**.
///
/// `app_router.dart` registered `/ai/explorer/:storyId` and `/ai/ask/:storyId`, and **no
/// `push`/`go` site for either existed anywhere in `lib/`**. `AskBookScreen` was pushed
/// from exactly one place — the Story Explorer's app bar — i.e. from a screen nobody
/// could open. Both surfaces compiled, had tests, and could not be reached by a user.
///
/// Third instance of the class: **R-1** registered six AF6 routes nothing navigated to,
/// **M5-1** shipped `PremiumGate` with zero call sites, then this. So these tests assert
/// what those defects slipped past — that a **user action opens the screen**, not that a
/// route exists.
///
/// **D5 deleted Ask My Book**, so half of what this file guarded is gone: the Ask tests,
/// the askBook flag asymmetry, and the Explorer→Ask hop that used to be Ask's only door.
/// What remains is Story Map, and it gained an obligation the Explorer never had. The
/// screen can now WRITE — "Map this story" is the trigger that fills a graph nothing
/// could fill before — and the endpoint takes the story's **text**, not just its id. So
/// the reachability assertion is stricter than it was: it is no longer enough that a tap
/// mounts the screen with the right `storyId`; the draft's content has to arrive with it,
/// or the button is there and the request 400s.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:umberleaf_mobile/app/router/app_router.dart';
import 'package:umberleaf_mobile/app/router/routes.dart';
import 'package:umberleaf_mobile/core/config/app_config.dart';
import 'package:umberleaf_mobile/core/config/app_flavor.dart';
import 'package:umberleaf_mobile/core/di/providers.dart';
import 'package:umberleaf_mobile/features/ai/domain/entities/ai_feature_flag.dart';
import 'package:umberleaf_mobile/features/ai/domain/value_objects/ai_feature_ids.dart';
import 'package:umberleaf_mobile/features/ai/domain/value_objects/story_map_seed.dart';
import 'package:umberleaf_mobile/features/ai/presentation/screens/story_explorer_screen.dart';
import 'package:umberleaf_mobile/features/writing/domain/entities/draft.dart';
import 'package:umberleaf_mobile/features/writing/presentation/controllers/current_draft_controller.dart';
import 'package:umberleaf_mobile/features/writing/presentation/providers/writing_providers.dart';
import 'package:umberleaf_mobile/features/writing/presentation/screens/editor_screen.dart';
import 'package:umberleaf_mobile/shared/theme/app_theme.dart';

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

/// `storyId === pieceId` server-side, so the route takes the draft's **remoteId**. A draft
/// that has never synced has no story to map, which is what hides the entry.
const String _remoteId = 'a1b2c3d4-0000-4000-8000-000000000001';
const String _localId = 'loc-1';
const String _bodyText = 'once upon a time';

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
          <String, dynamic>{'type': 'text', 'text': _bodyText},
        ],
      },
    ],
  },
  createdAt: DateTime.utc(2026, 7),
  localUpdatedAt: DateTime.utc(2026, 7, 2),
);

/// The editor's writing-tools group is gated on these, and Story Map sits under the same
/// account-level switch. Note there is no `ask_book` row any more — B2 deleted that flag
/// server-side, and `AiFeatureIds` no longer has an id to match it against.
const AiFeatures _features = AiFeatures(
  aiEnabled: true,
  features: <AiFeatureFlag>[
    AiFeatureFlag(
      feature: AiFeatureIds.writingAssistant,
      flagKey: 'feature.ai.writingAssistant.enabled',
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
  ],
);

/// The editor mounted inside a router that serves the **real** Story Map screen, and
/// forwards `extra` the way `app_router.dart` does.
Future<void> _pumpEditor(
  WidgetTester tester, {
  AppConfig config = _aiOn,
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
      aiRepository: FakeAiRepository(features: features ?? _features),
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
        builder: (_, GoRouterState s) {
          final Object? seed = s.extra;
          return StoryExplorerScreen(
            storyId: s.pathParameters['storyId'] ?? '',
            content: seed is StoryMapSeed ? seed.content : null,
            storyTitle: seed is StoryMapSeed ? seed.title : null,
          );
        },
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: buildUmberleafTheme(brightness: Brightness.light),
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

/// Open Story Map the way a **deep link** does — straight at the route, with no `extra`.
/// B5's gate has to hold on the destination too, or hiding the overflow entry is theatre.
Future<void> _pushStoryMap(WidgetTester tester) async {
  final BuildContext context = tester.element(find.byType(EditorScreen));
  // The push's future completes when the route is POPPED, which never happens here.
  unawaited(GoRouter.of(context).push(Routes.aiExplorerPath(_remoteId)));
  await tester.pumpAndSettle();
}

void main() {
  group('Story Map is reachable by a user (W5-3)', () {
    testWidgets('the editor overflow opens the real screen for this story', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester);
      await _openOverflow(tester);

      expect(find.text('Story Map'), findsOneWidget);
      await tester.tap(find.text('Story Map'));
      await tester.pumpAndSettle();

      // The screen itself, not a stub target — a tap that 404s the route or throws on
      // build would fail here rather than pass as "navigated".
      final StoryExplorerScreen screen = tester.widget<StoryExplorerScreen>(
        find.byType(StoryExplorerScreen),
      );
      // The SERVER piece id. `widget.draftId` is the local route id and the endpoint's
      // `ParseUUIDPipe` would reject it — the same trap the AF6 group documents.
      expect(screen.storyId, _remoteId);
    });

    /// **The assertion D5 added, and the one that decides whether the feature works.**
    ///
    /// `POST /story-intelligence/:storyId/map/stream` takes the story's content in the
    /// body — deliberately, so a writer can map a draft they have not saved. The editor
    /// is the only place that holds that text. Arriving with the id alone would give the
    /// writer a "Map this story" button whose request the DTO rejects outright, which is
    /// exactly the shape of W5-3: a surface that looks reachable and is not usable.
    testWidgets('and carries the draft’s text across, not just its id', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester);
      await _openOverflow(tester);
      await tester.tap(find.text('Story Map'));
      await tester.pumpAndSettle();

      final StoryExplorerScreen screen = tester.widget<StoryExplorerScreen>(
        find.byType(StoryExplorerScreen),
      );
      expect(screen.content, contains(_bodyText));
      expect(screen.storyTitle, 'The Cartographer');
    });
  });

  group('the entry respects the gates its route carries (W5-3)', () {
    testWidgets('a draft that never synced offers it not at all', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester, remoteId: null);
      await _openOverflow(tester);

      expect(find.text('Story Map'), findsNothing);
    });

    testWidgets('a build with AI dark offers nothing', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester, config: testConfig);
      await _openOverflow(tester);

      expect(find.text('Story Map'), findsNothing);
      // The non-AI entries are untouched — this is the kill switch working, not the
      // whole menu disappearing.
      expect(find.text('Save draft'), findsOneWidget);
    });

    /// **B5 (`platfrom/docs/45` §4.10)** — a writer who turned AI off must not be left
    /// with entry points into it.
    ///
    /// Story Map is the one that was actually broken: its route carries no feature flag,
    /// so the overflow gated it on the COMPILE-TIME switch and `isRemote` alone and never
    /// consulted the server at all. On a build with AI compiled in, an opted-out writer
    /// kept a live entry whose first request 403s.
    testWidgets('a writer who turned AI off keeps NO entry in the overflow', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester, features: _userTurnedAiOff);
      await _openOverflow(tester);

      expect(find.text('Story Map'), findsNothing);
      // The surfaces D5 deleted are not there either — and these assertions are cheap
      // insurance that a future change does not quietly restore one.
      expect(find.text('AI conversations'), findsNothing);
      expect(find.text('Prompt library'), findsNothing);
      expect(find.text('AI usage'), findsNothing);
      expect(find.text('Ask my book'), findsNothing);
      // The non-AI entries are untouched — B5 turns AI off, not the editor.
      expect(find.text('Save draft'), findsOneWidget);
    });

    testWidgets('the screen itself refuses, so a deep link cannot walk around it', (
      WidgetTester tester,
    ) async {
      // Deep links and stale menus both reach the screen directly, so the affordance
      // disappearing is not enough — the destination has to refuse too.
      await _pumpEditor(tester, features: _userTurnedAiOff);
      await _pushStoryMap(tester);

      // **D5 merged the two "off" states.** The old copy said "You turned AI off" and
      // told the writer to turn it back on in Settings › AI — a screen D5 deleted. One
      // sentence now covers both causes because only one of them ever had a remedy, and
      // that remedy is gone.
      expect(find.text('Writing tools aren’t available'), findsOneWidget);
      expect(find.text('You turned AI off'), findsNothing);
      expect(find.textContaining('Settings'), findsNothing);
    });
  });

  group('the app router serves the path (W5-3)', () {
    test(
      'namedLocation resolves aiExplorer, and the deleted names are gone',
      () async {
        // The other half of the loop. `namedLocation` throws for an unregistered name, so
        // this fails loudly if the route is dropped while the menu entry survives — and,
        // in the other direction, proves D5's deletions actually left the router.
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
        // Session-gated, like every other `/ai` surface.
        expect(Routes.isProtected(Routes.aiExplorerPath(_remoteId)), isTrue);

        for (final String name in <String>[
          'aiAsk',
          'aiConversations',
          'aiConversation',
          'promptLibrary',
          'aiUsage',
          'settingsAi',
        ]) {
          expect(
            () => router.namedLocation(name),
            throwsA(anything),
            reason: '$name must no longer resolve after D5',
          );
        }
      },
    );
  });
}

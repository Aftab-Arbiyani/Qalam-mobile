/// Closes docs/48 §3.12's prompt-library gap end to end: mobile's only way to get a
/// preset into the assistant was the clipboard (`prompt_library_screen.dart:92,116`),
/// a dead end when the clipboard is denied or unavailable. **Use in assistant** hands
/// the instruction straight to the editor's Writing Assistant instead.
///
/// Following the lesson `af4_entry_points_test.dart` documents (and W5-3/M5-1/R-1
/// before it): a defect this shape ships a screen, a route, even a working action —
/// and still isn't reachable, because nothing actually chains the pieces together. So
/// this asserts the **whole hop**: editor overflow → real `PromptLibraryScreen` →
/// "Use in assistant" → the real `WritingAssistantPanel`, pre-filled and un-sent.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qalam_mobile/app/router/routes.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/ai/domain/entities/ai_feature_flag.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/ai_feature_ids.dart';
import 'package:qalam_mobile/features/ai/presentation/panels/writing_assistant_panel.dart';
import 'package:qalam_mobile/features/ai/presentation/screens/prompt_library_screen.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
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

const String _localId = 'loc-1';

Draft _draft() => Draft(
  localId: _localId,
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

AiFeatures _features() => const AiFeatures(
  aiEnabled: true,
  features: <AiFeatureFlag>[
    AiFeatureFlag(
      feature: AiFeatureIds.writingAssistant,
      flagKey: 'feature.ai.writingAssistant.enabled',
      enabled: true,
    ),
  ],
);

/// The editor mounted inside a router that serves the real prompt library — the
/// same route shape `app_router.dart` registers, `routeId` query param included.
Future<void> _pumpEditor(WidgetTester tester) async {
  tester.view.physicalSize = const Size(700, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  late final ProviderContainer container;
  await tester.runAsync(() async {
    container = await buildTestContainer(
      config: _aiOn,
      pieceEditorRepository: FakePieceEditorRepository(),
      taxonomyRepository: FakeTaxonomyRepository(),
      aiRepository: FakeAiRepository(features: _features()),
      // D3 (`platfrom/docs/45` §4 row D3): the assistant panel is wrapped in a `PremiumGate`
      // on `ai_writing`, and the gate FAILS CLOSED — so this test has to say the writer is
      // entitled or the panel it is about renders a lock instead. The gate itself is covered
      // by `ai_writing_gate_test.dart`; here it is held open.
      entitlementSnapshot: const EntitlementSnapshot(
        tier: PlanTier.plus,
        status: EntitlementStatus.allow,
        features: <EntitlementDecision>[
          EntitlementDecision(
            feature: PremiumFeature.aiWriting,
            status: EntitlementStatus.allow,
            allowed: true,
            reason: EntitlementReason.planIncludes,
          ),
        ],
      ),
    );
    await container.read(preferencesStoreProvider).setEditorAutosave(false);
    await container.read(draftLocalDataSourceProvider).write(_draft());
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
        path: Routes.promptLibrary,
        builder: (_, GoRouterState s) =>
            PromptLibraryScreen(routeId: s.uri.queryParameters['routeId']),
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

void main() {
  group('Use in assistant reaches the real Writing Assistant (docs/48 §3.12)', () {
    testWidgets(
      'editor overflow → prompt library → Use in assistant pre-fills the panel',
      (WidgetTester tester) async {
        await _pumpEditor(tester);
        await _openOverflow(tester);

        expect(find.text('Prompt library'), findsOneWidget);
        await tester.tap(find.text('Prompt library'));
        await tester.pumpAndSettle();

        // The real screen, carrying this draft's route id — not a stub.
        final PromptLibraryScreen screen = tester.widget<PromptLibraryScreen>(
          find.byType(PromptLibraryScreen),
        );
        expect(screen.routeId, _localId);

        await tester.tap(find.byTooltip('Use in assistant').first);
        await tester.pumpAndSettle();

        // Back on the editor, with the real panel open — not a stub target.
        expect(find.byType(PromptLibraryScreen), findsNothing);
        expect(find.byType(WritingAssistantPanel), findsOneWidget);

        final TextField askField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(WritingAssistantPanel),
            matching: find.byType(TextField),
          ),
        );
        expect(
          askField.controller?.text,
          'Help me improve this passage while keeping my voice and '
          'meaning intact.',
        );

        // Filled, not fired — nothing has been sent to the assistant yet.
        expect(find.text('Thinking…'), findsNothing);
      },
    );

    testWidgets('Copy from the prompt library still works, unreplaced', (
      WidgetTester tester,
    ) async {
      await _pumpEditor(tester);
      await _openOverflow(tester);
      await tester.tap(find.text('Prompt library'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('General writing'));
      await tester.pump();

      expect(find.text('Prompt copied.'), findsOneWidget);
      // Copy doesn't pop or open the assistant — it's additive, not a replacement.
      expect(find.byType(PromptLibraryScreen), findsOneWidget);
      expect(find.byType(WritingAssistantPanel), findsNothing);
    });
  });
}

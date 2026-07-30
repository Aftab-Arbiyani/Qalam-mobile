import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/ai.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/harness.dart';

Widget _wrap(Widget home) => MaterialApp(
  theme: buildQalamTheme(brightness: Brightness.light),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

ExplorerViewResult _graph() => const ExplorerViewResult(
  storyId: 'piece-1',
  view: 'characters',
  nodes: <StoryGraphNode>[
    StoryGraphNode(
      id: 'c1',
      type: 'character',
      name: 'Aria',
      aliases: <String>[],
      summary: 'the brave hero',
      data: <String, dynamic>{'role': 'protagonist'},
      confidence: 0.9,
      mentionCount: 12,
      firstChapter: 'ch1',
      evidence: <StoryGraphEvidence>[],
    ),
    StoryGraphNode(
      id: 'c2',
      type: 'character',
      name: 'Kael',
      aliases: <String>[],
      summary: 'the mentor',
      data: <String, dynamic>{},
      confidence: 0.7,
      mentionCount: 5,
      firstChapter: null,
      evidence: <StoryGraphEvidence>[],
    ),
  ],
  edges: <StoryGraphEdge>[
    StoryGraphEdge(
      id: 'e1',
      type: 'relationship',
      sourceId: 'c1',
      targetId: 'c2',
      label: 'mentored by',
      data: <String, dynamic>{},
      confidence: 0.8,
    ),
  ],
  nodeCount: 2,
  edgeCount: 1,
);

void main() {
  testWidgets(
    'Story Explorer renders graph nodes and opens an interactive node sheet',
    (WidgetTester tester) async {
      late final Widget app;
      await tester.runAsync(() async {
        app = await buildTestApp(
          child: _wrap(const StoryExplorerScreen(storyId: 'piece-1')),
          aiRepository: FakeAiRepository(explorer: _graph()),
        );
      });
      await tester.pumpWidget(app);
      await settleFrames(tester);

      // Nodes render from the graph objects.
      expect(find.text('Aria'), findsOneWidget);
      expect(find.text('Kael'), findsOneWidget);

      // Tapping a node opens its detail sheet with its connected neighbours.
      await tester.tap(find.text('Aria'));
      await settleFrames(tester);
      expect(find.text('Connected'), findsOneWidget);
    },
  );

  testWidgets(
    'Story Explorer shows an empty state when the graph has no nodes',
    (WidgetTester tester) async {
      late final Widget app;
      await tester.runAsync(() async {
        app = await buildTestApp(
          child: _wrap(const StoryExplorerScreen(storyId: 'piece-1')),
          aiRepository: FakeAiRepository(
            explorer: const ExplorerViewResult(
              storyId: 'piece-1',
              view: 'characters',
              nodes: <StoryGraphNode>[],
              edges: <StoryGraphEdge>[],
              nodeCount: 0,
              edgeCount: 0,
            ),
          ),
        );
      });
      await tester.pumpWidget(app);
      await settleFrames(tester);

      expect(find.textContaining('No characters'), findsOneWidget);
    },
  );
}

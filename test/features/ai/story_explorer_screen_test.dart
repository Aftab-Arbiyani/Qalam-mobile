import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/features/ai/ai.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/presentation/widgets/premium_gate.dart';
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

// D4 (docs/48 §5.2, decided 2026-08-21): `story_intelligence` is now entitlement-gated,
// so every test here needs monetization on and an explicit entitlement decision —
// `testConfig`'s default (monetization off) would otherwise short-circuit straight to
// `MonetizationOffScreen` before any graph content ever renders.
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

EntitlementSnapshot _snapshot(EntitlementDecision storyIntelligence) =>
    EntitlementSnapshot(
      tier: PlanTier.pro,
      status: EntitlementStatus.allow,
      features: <EntitlementDecision>[storyIntelligence],
    );

const EntitlementDecision _allowed = EntitlementDecision(
  feature: PremiumFeature.storyIntelligence,
  status: EntitlementStatus.allow,
  allowed: true,
  reason: EntitlementReason.planIncludes,
);

const EntitlementDecision _denied = EntitlementDecision(
  feature: PremiumFeature.storyIntelligence,
  status: EntitlementStatus.deny,
  allowed: false,
  reason: EntitlementReason.planExcludes,
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
      evidence: <StoryGraphEvidence>[],
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
          config: _monetizationOn,
          entitlementSnapshot: _snapshot(_allowed),
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
          config: _monetizationOn,
          entitlementSnapshot: _snapshot(_allowed),
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

  // ── D4 — the entitlement gate itself (docs/48 §5.2) ──────────────────────────────

  testWidgets('a denied viewer sees the lock card, not the graph', (
    WidgetTester tester,
  ) async {
    late final Widget app;
    await tester.runAsync(() async {
      app = await buildTestApp(
        config: _monetizationOn,
        entitlementSnapshot: _snapshot(_denied),
        child: _wrap(const StoryExplorerScreen(storyId: 'piece-1')),
        aiRepository: FakeAiRepository(explorer: _graph()),
      );
    });
    await tester.pumpWidget(app);
    await settleFrames(tester);

    expect(find.text('Aria'), findsNothing);
    expect(find.textContaining('needs a paid plan'), findsOneWidget);
  });

  testWidgets('a dark build shows neither the graph nor a paywall', (
    WidgetTester tester,
  ) async {
    // With payments dark the entitlement snapshot degrades to deny-everything (no
    // subscription can exist), so without this branch the gate would render a lock
    // over a feature that has not shipped — the same trap credit_dashboard_screen
    // already guards against for ai_budget.
    late final Widget app;
    await tester.runAsync(() async {
      app = await buildTestApp(
        child: _wrap(const StoryExplorerScreen(storyId: 'piece-1')),
        aiRepository: FakeAiRepository(explorer: _graph()),
      );
    });
    await tester.pumpWidget(app);
    await settleFrames(tester);

    expect(find.text('Story Explorer isn’t available yet'), findsOneWidget);
    expect(find.byType(PremiumGate), findsNothing);
    expect(find.text('Aria'), findsNothing);
  });
}

/// Regression guard for defect **W8-1** (`platfrom/docs/48` §3.12).
///
/// `createConversation` existed in every mobile AI layer — remote data source,
/// repository interface, repository impl — with **zero UI callers**, so
/// `GET /ai/conversations` returned an empty page forever and the whole screen
/// behind it (detail, rename, archive, delete, export) was dead code. This
/// asserts the entry point that was missing: a user action that creates a
/// conversation and lands on it, not just that the method exists.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qalam_mobile/app/router/routes.dart';
import 'package:qalam_mobile/features/ai/ai.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/harness.dart';

void main() {
  testWidgets('the "New conversation" action creates one and opens it', (
    WidgetTester tester,
  ) async {
    // `getConversation('c-new')` needs a matching `detail` so the destination
    // screen's own load succeeds — otherwise this asserts nothing about the
    // create-and-navigate wiring, only that a 404 renders an error view.
    final AiConversationSummary created = AiConversationSummary(
      id: 'c-new',
      title: null,
      feature: 'writing_assistant',
      status: AiConversationStatus.active,
      messageCount: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final FakeAiRepository fake = FakeAiRepository(
      conversations: const <AiConversationSummary>[],
      detail: AiConversationDetail(
        summary: created,
        messages: const <AiConversationMessage>[],
      ),
    );
    late final ProviderContainer container;
    await tester.runAsync(() async {
      container = await buildTestContainer(aiRepository: fake);
    });
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: Routes.aiConversations,
      routes: <RouteBase>[
        GoRoute(
          path: Routes.aiConversations,
          builder: (_, GoRouterState s) => const AiConversationsScreen(),
        ),
        GoRoute(
          path: '${Routes.aiConversations}/:id',
          builder: (_, GoRouterState s) => AiConversationScreen(
            conversationId: s.pathParameters['id'] ?? '',
          ),
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

    // The empty state this defect left permanently on screen.
    expect(find.text('No conversations yet'), findsOneWidget);

    await tester.tap(find.text('New conversation'));
    await settleFrames(tester);

    // Navigated to the real conversation screen, not a stub — with the id
    // the platform actually created (FakeAiRepository.createConversation
    // returns `c-new`), not a client-invented one.
    final AiConversationScreen screen = tester.widget<AiConversationScreen>(
      find.byType(AiConversationScreen),
    );
    expect(screen.conversationId, 'c-new');
  });
}

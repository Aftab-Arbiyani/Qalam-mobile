/// Regression guards for the conversations screen's two entry points.
///
/// `createConversation` existed in every mobile AI layer — remote data source,
/// repository interface, repository impl — with **zero UI callers**, so
/// `GET /ai/conversations` returned an empty page forever and the whole screen
/// behind it (detail, rename, archive, delete, export) was dead code. This
/// asserts the entry point that was missing: a user action that creates a
/// conversation and lands on it, not just that the method exists.
///
/// The second test covers the archive shelf (`platfrom/docs/48` §3.21). Archiving worked before it
/// and there was no way back: the row left the only list that could show it, so Archive was a delete
/// with a gentler label. Asserted through the UI because the defect was a MISSING CONTROL — a
/// controller test cannot fail on an action nobody can reach, which is the whole shape of W8-1 too.
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
  testWidgets('the archived shelf lists archived rows and offers Restore', (
    WidgetTester tester,
  ) async {
    AiConversationSummary row(String id, AiConversationStatus status) =>
        AiConversationSummary(
          id: id,
          title: 'Chat $id',
          feature: 'writing_assistant',
          status: status,
          messageCount: 2,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        );

    final FakeAiRepository fake = FakeAiRepository(
      conversations: <AiConversationSummary>[
        row('c-active', AiConversationStatus.active),
        row('c-archived', AiConversationStatus.archived),
      ],
    );
    late final ProviderContainer container;
    await tester.runAsync(() async {
      container = await buildTestContainer(aiRepository: fake);
    });
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildQalamTheme(brightness: Brightness.light),
          home: const AiConversationsScreen(),
        ),
      ),
    );
    await settleFrames(tester);

    // The active shelf shows only the active row — the archived one is not in the page at all,
    // because the status is a request parameter and the fake filters the way the route does.
    expect(find.text('Chat c-active'), findsOneWidget);
    expect(find.text('Chat c-archived'), findsNothing);

    await tester.tap(find.text('Archived'));
    await settleFrames(tester);

    expect(fake.lastListedStatus, AiConversationStatus.archived);
    expect(find.text('Chat c-archived'), findsOneWidget);
    expect(find.text('Chat c-active'), findsNothing);

    // And the row's action is the way BACK, which is what the shelf exists for.
    await tester.tap(find.byType(PopupMenuButton<String>));
    await settleFrames(tester);
    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Archive'), findsNothing);

    await tester.tap(find.text('Restore'));
    await settleFrames(tester);

    // Restored, so it leaves the archived shelf.
    expect(find.text('Chat c-archived'), findsNothing);
  });
}

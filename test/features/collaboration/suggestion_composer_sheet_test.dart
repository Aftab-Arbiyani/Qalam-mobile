import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/edit_suggestion.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/text_anchor.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:qalam_mobile/features/collaboration/presentation/widgets/suggestion_composer_sheet.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

class _MockCollaborationRepository extends Mock
    implements CollaborationRepository {}

const EditSuggestion _added = EditSuggestion(
  id: 'sg1',
  storyId: 's1',
  authorId: 'u1',
  anchor: TextAnchor(from: 0, to: 5),
  originalText: 'first',
  suggestedText: 'FIRST',
  status: SuggestionStatus.pending,
);

Future<void> _pumpSheet(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => ElevatedButton(
              onPressed: () => SuggestionComposerSheet.show(
                context,
                storyId: 's1',
                anchor: const TextAnchor(from: 0, to: 5),
                originalText: 'first',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const TextAnchor(from: 0, to: 0));
  });

  testWidgets('shows the quoted original text', (WidgetTester tester) async {
    final _MockCollaborationRepository repo = _MockCollaborationRepository();
    late final ProviderContainer container;
    await tester.runAsync(() async {
      container = await buildTestContainer(collaborationRepository: repo);
    });
    addTearDown(container.dispose);

    await _pumpSheet(tester, container);

    expect(find.text('first'), findsOneWidget);
    expect(find.text('Suggest an edit'), findsOneWidget);
  });

  testWidgets('submit calls addSuggestion with the exact anchor and text', (
    WidgetTester tester,
  ) async {
    final _MockCollaborationRepository repo = _MockCollaborationRepository();
    when(
      () => repo.addSuggestion(
        storyId: any(named: 'storyId'),
        anchor: any(named: 'anchor'),
        originalText: any(named: 'originalText'),
        suggestedText: any(named: 'suggestedText'),
      ),
    ).thenAnswer((_) async => const Ok<EditSuggestion>(_added));

    late final ProviderContainer container;
    await tester.runAsync(() async {
      container = await buildTestContainer(collaborationRepository: repo);
    });
    addTearDown(container.dispose);

    await _pumpSheet(tester, container);
    await tester.enterText(find.byType(TextField), 'FIRST');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    verify(
      () => repo.addSuggestion(
        storyId: 's1',
        anchor: const TextAnchor(from: 0, to: 5),
        originalText: 'first',
        suggestedText: 'FIRST',
      ),
    ).called(1);
    // Success pops the sheet.
    expect(find.text('Suggest an edit'), findsNothing);
  });

  testWidgets('an error keeps the sheet open and surfaces the message', (
    WidgetTester tester,
  ) async {
    final _MockCollaborationRepository repo = _MockCollaborationRepository();
    when(
      () => repo.addSuggestion(
        storyId: any(named: 'storyId'),
        anchor: any(named: 'anchor'),
        originalText: any(named: 'originalText'),
        suggestedText: any(named: 'suggestedText'),
      ),
    ).thenAnswer(
      (_) async => const Err<EditSuggestion>(
        Failure.network(code: ErrorCodes.apiOffline, isOffline: true),
      ),
    );

    late final ProviderContainer container;
    await tester.runAsync(() async {
      container = await buildTestContainer(collaborationRepository: repo);
    });
    addTearDown(container.dispose);

    await _pumpSheet(tester, container);
    await tester.enterText(find.byType(TextField), 'FIRST');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Sheet is still open (title still on screen).
    expect(find.text('Suggest an edit'), findsOneWidget);
  });

  testWidgets('an empty replacement disables Submit', (
    WidgetTester tester,
  ) async {
    final _MockCollaborationRepository repo = _MockCollaborationRepository();
    late final ProviderContainer container;
    await tester.runAsync(() async {
      container = await buildTestContainer(collaborationRepository: repo);
    });
    addTearDown(container.dispose);

    await _pumpSheet(tester, container);

    final FilledButton submit = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Submit'),
    );
    expect(submit.onPressed, isNull);
    verifyNever(
      () => repo.addSuggestion(
        storyId: any(named: 'storyId'),
        anchor: any(named: 'anchor'),
        originalText: any(named: 'originalText'),
        suggestedText: any(named: 'suggestedText'),
      ),
    );
  });
}

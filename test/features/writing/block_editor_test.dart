import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/presentation/controllers/current_draft_controller.dart';
import 'package:qalam_mobile/features/writing/presentation/editor/block_editor.dart';
import 'package:qalam_mobile/features/writing/presentation/providers/writing_providers.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_writing.dart';
import '../../support/harness.dart';

void main() {
  testWidgets('typing in a block updates the document via the controller', (
    WidgetTester tester,
  ) async {
    late ProviderContainer c;
    await tester.runAsync(() async {
      c = await buildTestContainer(
        pieceEditorRepository: FakePieceEditorRepository(),
        taxonomyRepository: FakeTaxonomyRepository(),
      );
      await c.read(preferencesStoreProvider).setEditorAutosave(false);
      await c
          .read(draftLocalDataSourceProvider)
          .write(
            Draft(
              localId: 'loc-1',
              languageCode: 'ur',
              createdAt: DateTime.utc(2026, 7),
              localUpdatedAt: DateTime.utc(2026, 7),
            ),
          );
      await c.read(currentDraftControllerProvider('loc-1').future);
    });
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: buildQalamTheme(brightness: Brightness.light),
          home: const Scaffold(
            body: BlockEditor(
              routeId: 'loc-1',
              baseFontSize: 18,
              lineHeight: 1.6,
              direction: TextDirectionKind.ltr,
              placeholder: 'Tell your story…',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Once upon a time');
    await tester.pump();

    final document = c
        .read(currentDraftControllerProvider('loc-1'))
        .asData!
        .value
        .document;
    expect(document.blocks.single.text.text, 'Once upon a time');
  });

  testWidgets('pressing enter splits the block into two paragraphs', (
    WidgetTester tester,
  ) async {
    late ProviderContainer c;
    await tester.runAsync(() async {
      c = await buildTestContainer(
        pieceEditorRepository: FakePieceEditorRepository(),
        taxonomyRepository: FakeTaxonomyRepository(),
      );
      await c.read(preferencesStoreProvider).setEditorAutosave(false);
      await c
          .read(draftLocalDataSourceProvider)
          .write(
            Draft(
              localId: 'loc-1',
              languageCode: 'ur',
              createdAt: DateTime.utc(2026, 7),
              localUpdatedAt: DateTime.utc(2026, 7),
            ),
          );
      await c.read(currentDraftControllerProvider('loc-1').future);
    });
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: buildQalamTheme(brightness: Brightness.light),
          home: const Scaffold(
            body: BlockEditor(
              routeId: 'loc-1',
              baseFontSize: 18,
              lineHeight: 1.6,
              direction: TextDirectionKind.ltr,
              placeholder: 'Tell your story…',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'first\nsecond');
    await tester.pump();

    final document = c
        .read(currentDraftControllerProvider('loc-1'))
        .asData!
        .value
        .document;
    expect(document.blocks.length, 2);
    expect(document.blocks[0].text.text, 'first');
    expect(document.blocks[1].text.text, 'second');
  });
}

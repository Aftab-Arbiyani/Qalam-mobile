/// **Polish** — the in-editor writing tool (**D5**).
///
/// This replaces the tests that drove `WritingAssistantPanel`. The sheet's mechanism is
/// unchanged, so what is worth asserting is what D5 *decided*: which actions exist, that
/// each still resolves to the right server prompt key, that an accepted suggestion goes
/// through the editor's own commands and can be undone, and that the disclosure is
/// present exactly once.
///
/// The absences are assertions too. There is no Continue/Rewrite/Expand chip, no tone
/// picker, no "Ask AI" field and no Prompt Library — those were the generation surface,
/// and their server prompt templates went with them (B2). A chip that came back here
/// would send a key the orchestrator no longer has.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/core/config/app_config.dart';
import 'package:umberleaf_mobile/core/config/app_flavor.dart';
import 'package:umberleaf_mobile/core/di/providers.dart';
import 'package:umberleaf_mobile/features/ai/domain/entities/ai_completion.dart';
import 'package:umberleaf_mobile/features/ai/domain/entities/ai_stream_event.dart';
import 'package:umberleaf_mobile/features/ai/domain/entities/ai_suggestion.dart';
import 'package:umberleaf_mobile/features/ai/domain/value_objects/ai_writing_context.dart';
import 'package:umberleaf_mobile/features/ai/presentation/editor/ai_editor_target.dart';
import 'package:umberleaf_mobile/features/ai/presentation/panels/polish_sheet.dart';
import 'package:umberleaf_mobile/features/ai/presentation/providers/ai_providers.dart';
import 'package:umberleaf_mobile/features/ai/presentation/support/ai_error_copy.dart';
import 'package:umberleaf_mobile/features/ai/presentation/widgets/ai_writing_lock_card.dart';
import 'package:umberleaf_mobile/features/ai/presentation/widgets/model_disclosure_note.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:umberleaf_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:umberleaf_mobile/shared/theme/app_theme.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/harness.dart';

const AppConfig _config = AppConfig(
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

EntitlementSnapshot _snapshot({required bool writingAllowed}) =>
    EntitlementSnapshot(
      tier: writingAllowed ? PlanTier.plus : PlanTier.free,
      status: EntitlementStatus.allow,
      features: <EntitlementDecision>[
        EntitlementDecision(
          feature: PremiumFeature.aiWriting,
          status: writingAllowed
              ? EntitlementStatus.allow
              : EntitlementStatus.deny,
          allowed: writingAllowed,
          reason: writingAllowed
              ? EntitlementReason.planIncludes
              : EntitlementReason.planExcludes,
        ),
      ],
    );

/// A recording editor target. It stands in for `DraftAiEditorTarget`, whose whole job is
/// to route an apply through `CurrentDraftController` — the point being that the AI layer
/// never touches the document, so what a test can observe is the CALL, not a mutation.
class _FakeTarget implements AiEditorTarget {
  _FakeTarget({this.selection = 'The old house stood alone.'});

  final String selection;

  String? replacedWith;
  String? insertedBelow;
  String? appended;
  bool undone = false;

  @override
  AiWritingContext get context => AiWritingContext(
    selectionText: selection,
    chapterText: 'The old house stood alone. It had stood a long time.',
    title: 'Chapter 1',
    language: 'English',
    wordCount: 10,
  );

  @override
  bool get canReplaceSelection => selection.trim().isNotEmpty;

  @override
  AiApplyHandle? replaceSelection(String text) {
    replacedWith = text;
    return AiApplyHandle(
      placement: AiSuggestionPlacement.replaceSelection,
      undo: () => undone = true,
    );
  }

  @override
  AiApplyHandle? insertBelow(String text) {
    insertedBelow = text;
    return AiApplyHandle(
      placement: AiSuggestionPlacement.insertBelow,
      undo: () => undone = true,
    );
  }

  @override
  AiApplyHandle? append(String text) {
    appended = text;
    return AiApplyHandle(
      placement: AiSuggestionPlacement.append,
      undo: () => undone = true,
    );
  }

  @override
  Future<String?> saveAsNewDraft(String text) async => 'draft-1';
}

const List<AiStreamEvent> _stubStream = <AiStreamEvent>[
  AiStreamEvent(
    type: AiStreamEventType.start,
    provider: 'stub',
    model: 'stub-1',
  ),
  AiStreamEvent(type: AiStreamEventType.delta, text: 'The old house stood '),
  AiStreamEvent(type: AiStreamEventType.delta, text: 'alone, and had.'),
  AiStreamEvent(type: AiStreamEventType.done),
];

Future<FakeAiRepository> _pump(
  WidgetTester tester, {
  required bool writingAllowed,
  _FakeTarget? target,
  List<AiStreamEvent> stream = _stubStream,
}) async {
  tester.view.physicalSize = const Size(800, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final FakeAiRepository fake = FakeAiRepository(streamEvents: stream);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        aiRepositoryProvider.overrideWithValue(fake),
        entitlementSnapshotProvider.overrideWith(
          (_) async => _snapshot(writingAllowed: writingAllowed),
        ),
      ],
      child: MaterialApp(
        theme: buildUmberleafTheme(brightness: Brightness.light),
        home: Scaffold(body: PolishSheet(target: target ?? _FakeTarget())),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return fake;
}

void main() {
  group('the gate (D3)', () {
    testWidgets('withholds the whole sheet from a FREE writer', (
      WidgetTester tester,
    ) async {
      await _pump(tester, writingAllowed: false);

      expect(find.byType(AiWritingLockCard), findsOneWidget);
      expect(find.text(AiErrorCopy.aiWritingLocked.title), findsOneWidget);
      // Not one action is offered — nothing invites a request that would 402.
      expect(find.text('Simplify'), findsNothing);
      expect(find.text('Condense'), findsNothing);
      expect(find.text('Clarity'), findsNothing);
      // And nothing to disclose when nothing can run.
      expect(find.text(ModelDisclosureNote.text), findsNothing);
    });

    testWidgets('lets an ENTITLED writer straight through', (
      WidgetTester tester,
    ) async {
      await _pump(tester, writingAllowed: true);

      expect(find.byType(AiWritingLockCard), findsNothing);
      expect(find.text('Polish'), findsOneWidget);
    });
  });

  group('what the sheet offers, and what it no longer does', () {
    testWidgets('two one-click actions plus the eight Improve aspects', (
      WidgetTester tester,
    ) async {
      await _pump(tester, writingAllowed: true);

      expect(find.text('Simplify'), findsOneWidget);
      expect(find.text('Condense'), findsOneWidget);
      for (final String aspect in <String>[
        'Flow',
        'Clarity',
        'Grammar',
        'Style',
        'Dialogue',
        'Description',
        'Scene',
        'Transition',
      ]) {
        expect(find.text(aspect), findsOneWidget, reason: '$aspect is missing');
      }
    });

    /// The generation surface, asserted by its absence. Each of these was a chip or a
    /// field on `WritingAssistantPanel`; each mapped to a `writing_assistant.*` prompt
    /// key that B2 deleted from the server catalogue.
    testWidgets('no generation actions, no tone picker, no free-text box', (
      WidgetTester tester,
    ) async {
      await _pump(tester, writingAllowed: true);

      for (final String gone in <String>[
        'Continue',
        'Rewrite',
        'Expand',
        'Tone…',
        'Improve…',
        'Ask the assistant',
        'Prompts',
        'Keep history',
      ]) {
        expect(find.text(gone), findsNothing, reason: '$gone must be gone');
      }
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('the disclosure is present, and exactly once', (
      WidgetTester tester,
    ) async {
      await _pump(tester, writingAllowed: true);

      expect(find.text(ModelDisclosureNote.text), findsOneWidget);
    });
  });

  group('running an action', () {
    testWidgets('an Improve aspect sends its prompt key and {{aspect}}', (
      WidgetTester tester,
    ) async {
      final FakeAiRepository fake = await _pump(tester, writingAllowed: true);

      await tester.tap(find.text('Clarity'));
      await settleFrames(tester);

      final AiCompletionRequest req = fake.lastStreamRequest!;
      expect(req.feature, 'writing_assistant');
      expect(req.promptKey, 'writing_assistant.improve');
      expect(req.promptVariables, <String, dynamic>{'aspect': 'clarity'});
      // The operand is the message; the client never embeds a prompt body.
      expect(req.messages!.single.content, 'The old house stood alone.');
    });

    testWidgets('Condense sends its own key with no variables', (
      WidgetTester tester,
    ) async {
      final FakeAiRepository fake = await _pump(tester, writingAllowed: true);

      await tester.tap(find.text('Condense'));
      await settleFrames(tester);

      expect(fake.lastStreamRequest!.promptKey, 'writing_assistant.condense');
      expect(fake.lastStreamRequest!.promptVariables, isNull);
    });

    /// Applying goes through [AiEditorTarget], never through the document. That is the
    /// property that keeps autosave, offline sync and version history working with no
    /// AI-specific logic anywhere in the editor — and it is what makes Undo an ordinary
    /// edit rather than a special case.
    testWidgets(
      'accepting replaces the selection via the editor seam, and undoes',
      (WidgetTester tester) async {
        final _FakeTarget target = _FakeTarget();
        await _pump(tester, writingAllowed: true, target: target);

        await tester.tap(find.text('Condense'));
        await settleFrames(tester);

        // A selection is present, so the default placement replaces it.
        await tester.tap(find.text('Apply (replace selection)'));
        await settleFrames(tester);

        expect(target.replacedWith, 'The old house stood alone, and had.');
        expect(target.insertedBelow, isNull);
        expect(find.text('Applied to your draft'), findsOneWidget);

        await tester.tap(find.text('Undo'));
        await settleFrames(tester);
        expect(target.undone, isTrue);
        // D5 copy: the snackbar no longer calls it an "AI change".
        expect(find.text('Change undone.'), findsOneWidget);
        expect(find.textContaining('AI'), findsNothing);
      },
    );

    testWidgets('with no selection the default placement inserts below', (
      WidgetTester tester,
    ) async {
      final _FakeTarget target = _FakeTarget(selection: '');
      await _pump(tester, writingAllowed: true, target: target);

      await tester.tap(find.text('Simplify'));
      await settleFrames(tester);

      await tester.tap(find.text('Apply (insert below)'));
      await settleFrames(tester);

      expect(target.insertedBelow, isNotNull);
      expect(target.replacedWith, isNull);
    });

    /// The window the gate cannot cover: an entitlement can be revoked between opening
    /// the sheet and the stream finishing. Naming the feature is what selects the Polish
    /// remedy over the generic paid-plan one.
    testWidgets('a mid-flight 402 renders the Polish remedy', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        writingAllowed: true,
        stream: const <AiStreamEvent>[
          AiStreamEvent(
            type: AiStreamEventType.error,
            code: 'ENTITLEMENT_DENIED',
          ),
        ],
      );

      await tester.tap(find.text('Simplify'));
      await settleFrames(tester);

      expect(find.text(AiErrorCopy.aiWritingLocked.title), findsOneWidget);
      expect(find.text('This needs a paid plan'), findsNothing);
      expect(find.text('See plans'), findsOneWidget);
    });
  });
}

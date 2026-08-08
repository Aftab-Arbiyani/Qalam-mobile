/// The plan piece cap on mobile (B4, `platfrom/docs/45` §4.9).
///
/// The cap gates the product's core write path, so these tests assert **reachability**,
/// not wire shape: that the count is on the screen before it bites, that the create
/// affordance is genuinely inert when the server says the author is out of slots, and
/// that the copy never offers a reset — a piece cap does not have one, and pointing a
/// blocked writer at one is the W4 defect (`platfrom/docs/48` §3.6).
///
/// Mobile has two defects on record at exactly these seams: **C-1**, an affordance that
/// vanished silently instead of explaining itself, and **W3c-1**, a control left live in
/// front of a server that refuses it. The blocked FAB here is neither — visible, plainly
/// disabled, and labelled with the reason.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/writing/data/mappers/piece_write_mappers.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_summary.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_sync.dart';
import 'package:qalam_mobile/features/writing/domain/entities/piece_allowance.dart';
import 'package:qalam_mobile/features/writing/presentation/controllers/draft_list_controller.dart';
import 'package:qalam_mobile/features/writing/presentation/providers/writing_providers.dart';
import 'package:qalam_mobile/features/writing/presentation/screens/drafts_screen.dart';
import 'package:qalam_mobile/features/writing/presentation/support/piece_limit_copy.dart';
import 'package:qalam_mobile/features/writing/presentation/widgets/piece_limit_notice.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

const AppConfig _config = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: false,
  enableMonetization: true,
  enableCollaboration: false,
);

const PieceAllowance _unlimited = PieceAllowance(
  used: 900,
  limit: 0,
  unlimited: true,
  canCreate: true,
);

const PieceAllowance _room = PieceAllowance(
  used: 24,
  limit: 25,
  remaining: 1,
  unlimited: false,
  canCreate: true,
);

const PieceAllowance _full = PieceAllowance(
  used: 25,
  limit: 25,
  remaining: 0,
  unlimited: false,
  canCreate: false,
);

/// Plus (250) → Free (25) with 100 pieces in hand. Reachable, and the decision was to
/// keep every one of them.
const PieceAllowance _afterDowngrade = PieceAllowance(
  used: 100,
  limit: 25,
  remaining: 0,
  unlimited: false,
  canCreate: false,
);

/// The drafts list, canned — the screen under test owns the cap, not the list.
class _FakeDraftList extends DraftListController {
  _FakeDraftList(this._drafts);

  final List<DraftSummary> _drafts;

  @override
  Future<List<DraftSummary>> build() async => _drafts;
}

Future<void> _pumpDrafts(
  WidgetTester tester, {
  PieceAllowance? allowance,
  List<DraftSummary> drafts = const <DraftSummary>[],
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        pieceAllowanceProvider.overrideWith((_) async => allowance),
        draftListControllerProvider.overrideWith(() => _FakeDraftList(drafts)),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: brightness),
        home: const DraftsScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

FloatingActionButton _fab(WidgetTester tester) => tester
    .widget<FloatingActionButton>(find.byType(FloatingActionButton).first);

void main() {
  group('PieceLimitCopy', () {
    test('counts down toward a capped plan', () {
      expect(PieceLimitCopy.of(_room).countLabel, '24 of 25 pieces');
    });

    test('says nothing on an unlimited plan', () {
      final PieceLimitCopy copy = PieceLimitCopy.of(_unlimited);
      expect(copy.countLabel, isNull);
      expect(copy.blocked, isFalse);
    });

    test(
      'says nothing, and blocks nothing, while the allowance is unknown',
      () {
        final PieceLimitCopy copy = PieceLimitCopy.of(null);
        expect(copy.countLabel, isNull);
        expect(copy.blocked, isFalse);
      },
    );

    test('blocks at the cap and still shows the count', () {
      final PieceLimitCopy copy = PieceLimitCopy.of(_full);
      expect(copy.blocked, isTrue);
      expect(copy.overLimit, isFalse);
      expect(copy.countLabel, '25 of 25 pieces');
      expect(copy.headline, 'You’ve used all 25 pieces on your plan.');
    });

    test('names the over-limit case for what it is', () {
      final PieceLimitCopy copy = PieceLimitCopy.of(_afterDowngrade);
      expect(copy.overLimit, isTrue);
      expect(copy.headline, 'You have 100 pieces and your plan includes 25.');
    });

    test('offers delete and upgrade, never a reset', () {
      final PieceLimitCopy copy = PieceLimitCopy.of(_full);
      expect(copy.message, contains('delete a piece'));
      expect(copy.message, contains('larger plan'));
      expect(
        copy.message,
        isNot(matches(RegExp('reset|wait', caseSensitive: false))),
      );
    });

    test('mirrors the web wording, so the two clients say the same thing', () {
      // Parity is binding (docs/48): the same writer on the other platform must not be
      // told a different story about the same cap.
      expect(
        PieceLimitCopy.of(_full).message,
        startsWith('Everything you’ve written stays exactly where it is'),
      );
    });
  });

  group('pieceAllowanceFromJson', () {
    test('reads the server verdict rather than deriving one', () {
      final PieceAllowance a = pieceAllowanceFromJson(<String, dynamic>{
        'used': 25,
        'limit': 25,
        'remaining': 0,
        'unlimited': false,
        'canCreate': false,
      });
      expect(a.used, 25);
      expect(a.canCreate, isFalse);
      expect(a.isBlocked, isTrue);
      expect(a.isOverLimit, isFalse);
    });

    test('treats limit 0 as unlimited, with no remaining to show', () {
      final PieceAllowance a = pieceAllowanceFromJson(<String, dynamic>{
        'used': 900,
        'limit': 0,
        'remaining': null,
        'unlimited': true,
        'canCreate': true,
      });
      expect(a.unlimited, isTrue);
      expect(a.remaining, isNull);
      expect(a.isOverLimit, isFalse);
    });

    test('flags the over-limit case a downgrade produces', () {
      final PieceAllowance a = pieceAllowanceFromJson(<String, dynamic>{
        'used': 100,
        'limit': 25,
        'remaining': 0,
        'unlimited': false,
        'canCreate': false,
      });
      expect(a.isOverLimit, isTrue);
    });
  });

  group('the drafts screen surfaces the cap', () {
    testWidgets('shows the count before it bites, create still live', (
      WidgetTester tester,
    ) async {
      await _pumpDrafts(tester, allowance: _room);
      expect(find.text('24 of 25 pieces'), findsOneWidget);
      expect(_fab(tester).onPressed, isNotNull);
      expect(find.byType(PieceLimitNotice), findsOneWidget);
      expect(find.text('See plans'), findsNothing);
    });

    testWidgets('shows no count on an unlimited plan', (
      WidgetTester tester,
    ) async {
      await _pumpDrafts(tester, allowance: _unlimited);
      expect(find.textContaining('pieces'), findsNothing);
      expect(_fab(tester).onPressed, isNotNull);
    });

    testWidgets('stays usable while the allowance is unknown', (
      WidgetTester tester,
    ) async {
      await _pumpDrafts(tester);
      expect(_fab(tester).onPressed, isNotNull);
    });

    testWidgets(
      'disables the create action once the plan is full, and says why',
      (WidgetTester tester) async {
        await _pumpDrafts(tester, allowance: _full);

        // Not hidden (C-1) and not live-but-refused (W3c-1) — visible and inert.
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(_fab(tester).onPressed, isNull);
        expect(
          find.text('You’ve used all 25 pieces on your plan.'),
          findsOneWidget,
        );
        expect(find.text('See plans'), findsOneWidget);
      },
    );

    testWidgets('labels the disabled create action for a screen reader', (
      WidgetTester tester,
    ) async {
      await _pumpDrafts(tester, allowance: _full);
      expect(
        find.bySemanticsLabel(
          'New piece, unavailable — your plan’s piece limit is full',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'keeps the work visible after a downgrade puts it over the cap',
      (WidgetTester tester) async {
        await _pumpDrafts(
          tester,
          allowance: _afterDowngrade,
          drafts: <DraftSummary>[
            const DraftSummary(remoteId: 'p1', title: 'A published ghazal'),
          ],
        );
        expect(
          find.text('You have 100 pieces and your plan includes 25.'),
          findsOneWidget,
        );
        // "Keep everything" has to be true on screen, not only in the backend.
        expect(find.text('A published ghazal'), findsOneWidget);
        expect(
          find.textContaining('stays exactly where it is'),
          findsOneWidget,
        );
      },
    );

    testWidgets('never tells a blocked writer to wait for a reset', (
      WidgetTester tester,
    ) async {
      await _pumpDrafts(tester, allowance: _full);
      expect(find.textContaining('reset'), findsNothing);
      expect(
        find.textContaining('delete a piece to free a slot'),
        findsOneWidget,
      );
    });

    testWidgets('explains a draft the cap refused at sync, with a way out', (
      WidgetTester tester,
    ) async {
      // The reachable race: another device took the last slot after this draft was
      // minted, so the create 402s at sync time and lands as a terminal failure.
      await _pumpDrafts(
        tester,
        allowance: _full,
        drafts: <DraftSummary>[
          const DraftSummary(
            localId: 'loc-1',
            title: 'Stranded draft',
            syncState: DraftSyncState.failed,
            lastError: ErrorCodes.pieceLimitReached,
          ),
        ],
      );
      expect(
        find.textContaining('Not saved — your plan’s piece limit is full'),
        findsOneWidget,
      );
      expect(
        find.text('See plans'),
        findsNWidgets(2),
      ); // notice + the row's own
    });

    testWidgets('leaves an ordinary sync failure alone', (
      WidgetTester tester,
    ) async {
      await _pumpDrafts(
        tester,
        allowance: _room,
        drafts: <DraftSummary>[
          const DraftSummary(
            localId: 'loc-1',
            title: 'Ordinary failure',
            syncState: DraftSyncState.failed,
            lastError: ErrorCodes.validationFailed,
          ),
        ],
      );
      expect(find.textContaining('piece limit is full'), findsNothing);
      expect(find.text('Sync failed'), findsOneWidget);
    });
  });

  // The rendered a11y scan, in BOTH themes — deferring dark mode is how the UI-quality
  // debt in this project accumulated (docs/45 §2 step 5).
  group('accessibility, light and dark', () {
    for (final (String name, Brightness brightness) in <(String, Brightness)>[
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('the blocked state meets contrast + tap targets ($name)', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await _pumpDrafts(
          tester,
          allowance: _afterDowngrade,
          brightness: brightness,
          drafts: <DraftSummary>[
            const DraftSummary(remoteId: 'p1', title: 'A published ghazal'),
          ],
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // `iOSTapTargetGuideline` (44), not `androidTapTargetGuideline` (48): every
        // `QButton` in this app is 44 tall by construction (`q_button.dart` clamps its
        // tap height to `max(visualHeight, 44)`), so the 48 guideline fails app-wide and
        // not because of anything B4 added. Making this one button taller would buy a
        // green assertion and an inconsistent control; the gap is recorded for the
        // register instead.
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });
    }
  });
}

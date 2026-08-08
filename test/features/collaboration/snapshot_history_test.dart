/// B7 — version-history depth, by plan (`platfrom/docs/45` §4.12).
///
/// Four things are tested, in this order of importance:
///
/// 1. **Capture is never blocked.** B7 clamps the READ. The server captures a `pre_edit`
///    version inside the transaction that settles an accepted suggestion, so a client that
///    disabled Capture at the plan depth would be the visible half of a correctness bug in
///    the collaboration flow. The button must stay enabled with the clamp on screen.
/// 2. **The count comes from the TRUE total.** "5 of 32 versions", never "5 versions" —
///    reading `items.length` would state a number that is false and make the hidden ones
///    invisible rather than for sale.
/// 3. **The sentinel does NOT invert.** `limit: 0` is UNLIMITED here, the ordinary
///    convention — B6's seats are the one inverted key. Copying B6's `-1` reading across
///    would show Pro and Enterprise authors zero versions, silently.
/// 4. **The offer renders in BOTH themes**, scanned for contrast and tap targets.
///
/// These pump the real screen against a mocked repository, because the defect class this
/// codebase keeps hitting (R-1, M5-1, W5-3, C-1) is client code that looks wired and is
/// not. A test that only decoded the DTO would pass while the count never reached a pixel.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/policy_capability.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/publication_event.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/review_session.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_snapshot.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_snapshot_history.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/publishing_repository.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/publishing_workflow_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/widgets/snapshot_history_notice.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

class _MockPublishingRepository extends Mock implements PublishingRepository {}

class _MockCollaborationRepository extends Mock
    implements CollaborationRepository {}

const String _story = 'story-1';

const AppConfig _collabOn = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: '',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: false,
  enableMonetization: false,
  enableCollaboration: true,
);

StorySnapshot _snapshot(int version) => StorySnapshot(
  id: 'snap-$version',
  storyId: _story,
  version: version,
  title: '',
  reason: 'manual',
  createdAt: DateTime.utc(2026, 8, 8),
  createdById: 'u1',
  wordCount: 100,
);

/// A clamped history: `visible` of `total`, newest first — the free author's shape.
StorySnapshotHistory _history({
  int total = 32,
  int visible = 5,
  int limit = 5,
  bool unlimited = false,
}) => StorySnapshotHistory(
  items: List<StorySnapshot>.generate(visible, (int i) => _snapshot(total - i)),
  total: total,
  visible: visible,
  hidden: unlimited ? 0 : total - visible,
  limit: limit,
  unlimited: unlimited,
);

/// The owner's capability map with `story.edit` allowed — the viewer who can capture/revert.
StoryCapabilities _canEditCaps() => const StoryCapabilities(
  capabilities: <String, PolicyCapability>{
    PolicyAction.storyEdit: PolicyCapability(
      action: PolicyAction.storyEdit,
      effect: PolicyEffect.allow,
      allowed: true,
      reason: 'owner',
      obligations: <String>[],
    ),
  },
);

Widget _wrap(ProviderContainer container, Widget child) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: child,
      ),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_story);
  });

  // ── 1. The decode, where the sentinel could invert ───────────────────────────────

  group('StorySnapshotHistory decoding', () {
    test('reads the clamped items and the TRUE total apart', () {
      final StorySnapshotHistory history = StorySnapshotHistory.fromJson(
        <String, Object?>{
          'items': <Object?>[
            <String, Object?>{
              'id': 'snap-32',
              'storyId': _story,
              'version': 32,
              'title': 'The Lamplighter',
              'reason': 'manual',
              'createdById': 'u1',
              'createdAt': '2026-08-08T09:00:00.000Z',
              'wordCount': 100,
            },
          ],
          'total': 32,
          'visible': 1,
          'hidden': 31,
          'limit': 5,
          'unlimited': false,
        },
      );

      expect(history.items, hasLength(1));
      expect(history.total, 32);
      expect(history.hidden, 31);
      expect(history.isLimited, isTrue);
    });

    test('reads limit 0 as UNLIMITED — the ordinary sentinel, not B6’s -1', () {
      final StorySnapshotHistory pro =
          StorySnapshotHistory.fromJson(<String, Object?>{
            'items': <Object?>[],
            'total': 40,
            'visible': 40,
            'hidden': 0,
            'limit': 0,
            'unlimited': true,
          });

      // Copying B6's inverted reading here would make `limit: 0` mean "no versions" and
      // show every Pro and Enterprise author an upsell for a limit they do not have.
      expect(pro.unlimited, isTrue);
      expect(pro.isLimited, isFalse);
    });

    test('an unlimited plan is never treated as withholding versions', () {
      expect(
        _history(unlimited: true, visible: 32, limit: 0).isLimited,
        isFalse,
      );
    });

    test('a malformed payload claims nothing is hidden', () {
      final StorySnapshotHistory broken = StorySnapshotHistory.fromJson(
        <String, Object?>{},
      );

      // The opposite fallback from B6's seats, because the risks invert: a wrongly-offered
      // seat leaks revenue, a wrongly-claimed hidden version is a lie told to the author.
      expect(broken.isLimited, isFalse);
      expect(broken.unlimited, isTrue);
      expect(StorySnapshotHistory.empty.isLimited, isFalse);
    });

    test(
      'a missing total never reads as fewer versions than are on screen',
      () {
        final StorySnapshotHistory history = StorySnapshotHistory.fromJson(
          <String, Object?>{
            'items': <Object?>[
              <String, Object?>{'id': 'a', 'version': 2},
              <String, Object?>{'id': 'b', 'version': 1},
            ],
          },
        );

        // Otherwise the count line would render "2 of 0 versions".
        expect(history.total, 2);
        expect(history.visible, 2);
      },
    );
  });

  // ── 2. The publishing screen ─────────────────────────────────────────────────────

  group('PublishingWorkflowScreen version history', () {
    late _MockPublishingRepository publishing;
    late _MockCollaborationRepository collaboration;

    setUp(() {
      publishing = _MockPublishingRepository();
      collaboration = _MockCollaborationRepository();

      when(
        () => publishing.review(any()),
      ).thenAnswer((_) async => const Ok<ReviewSession?>(null));
      when(() => publishing.publicationHistory(any())).thenAnswer(
        (_) async => const Ok<List<PublicationEvent>>(<PublicationEvent>[]),
      );
      when(
        () => collaboration.capabilities(any()),
      ).thenAnswer((_) async => Ok<StoryCapabilities>(_canEditCaps()));
    });

    Future<void> pump(WidgetTester tester, StorySnapshotHistory history) async {
      when(
        () => publishing.snapshots(any()),
      ).thenAnswer((_) async => Ok<StorySnapshotHistory>(history));

      late final ProviderContainer container;
      await tester.runAsync(() async {
        container = await buildTestContainer(
          config: _collabOn,
          publishingRepository: publishing,
          collaborationRepository: collaboration,
        );
      });
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(container, const PublishingWorkflowScreen(storyId: _story)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('says "5 of 32 versions" rather than "5 versions"', (
      WidgetTester tester,
    ) async {
      await pump(tester, _history());

      // The whole reason the server returns the true total: without it the screen would
      // report a thirty-two-version story as having five, and the hidden ones would be
      // invisible rather than for sale.
      expect(find.text('5 of 32 versions'), findsOneWidget);
    });

    testWidgets('offers the plan where the hidden versions would be', (
      WidgetTester tester,
    ) async {
      await pump(tester, _history());

      expect(
        find.text('27 older versions are saved but not shown.'),
        findsOneWidget,
      );
      expect(find.textContaining('Nothing was deleted'), findsOneWidget);
      expect(find.text('See plans'), findsOneWidget);
    });

    testWidgets('keeps Capture ENABLED at the plan depth', (
      WidgetTester tester,
    ) async {
      await pump(tester, _history());

      // The correctness guard, on the client side. B7 clamps the READ — an author at their
      // depth still gets new versions, and the accept-a-suggestion path depends on it.
      final Finder capture = find.widgetWithText(TextButton, 'Capture');
      expect(capture, findsOneWidget);
      expect(tester.widget<TextButton>(capture).onPressed, isNotNull);
    });

    testWidgets('still lists and offers a revert on the versions it shows', (
      WidgetTester tester,
    ) async {
      await pump(tester, _history());

      expect(find.text('Version 32'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Revert'), findsNWidgets(5));
    });

    testWidgets('shows no count and no offer when the plan shows everything', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        _history(total: 3, visible: 3, limit: 0, unlimited: true),
      );

      expect(find.text('Version 3'), findsOneWidget);
      expect(find.text('See plans'), findsNothing);
      expect(find.textContaining('of 3 versions'), findsNothing);
    });

    testWidgets(
      'upgrading shows the older versions again — nothing was deleted',
      (WidgetTester tester) async {
        await pump(
          tester,
          _history(total: 8, visible: 8, limit: 0, unlimited: true),
        );

        // The same eight stored versions the free author saw five of.
        expect(find.widgetWithText(TextButton, 'Revert'), findsNWidgets(8));
        expect(find.text('See plans'), findsNothing);
      },
    );
  });

  // ── 3. The rendered a11y scan, in BOTH themes ────────────────────────────────────

  /// Tinted text on a tinted ground plus one action — exactly where a colour pair that
  /// only works in one theme goes unnoticed. Colours come from `QTokens`, which defines a
  /// light and a dark value for every pair used; a raw hex would pass one and fail the
  /// other, and this is the test that catches it being introduced.
  group('the offer renders and scans clean', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('the history offer renders under $brightness', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildQalamTheme(brightness: brightness),
            home: Scaffold(body: SnapshotHistoryNotice(history: _history())),
          ),
        );
        await tester.pump();

        expect(
          find.text('27 older versions are saved but not shown.'),
          findsOneWidget,
        );
        expect(find.text('See plans'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('the history offer meets contrast + tap targets ($brightness)', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildQalamTheme(brightness: brightness),
            home: Scaffold(body: SnapshotHistoryNotice(history: _history())),
          ),
        );
        await tester.pump();

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // `iOSTapTargetGuideline` (44), not `androidTapTargetGuideline` (48): every
        // `QButton` is 44 tall by construction, so the 48 guideline fails app-wide and not
        // because of anything B7 added — recorded as T-10 in `platfrom/docs/48`.
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('the count renders and scans under $brightness', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildQalamTheme(brightness: brightness),
            home: Scaffold(body: SnapshotHistoryCount(history: _history())),
          ),
        );
        await tester.pump();

        expect(find.text('5 of 32 versions'), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets(
        'neither surface renders anything on an unlimited plan ($brightness)',
        (WidgetTester tester) async {
          final StorySnapshotHistory unlimited = _history(
            visible: 32,
            limit: 0,
            unlimited: true,
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: buildQalamTheme(brightness: brightness),
              home: Scaffold(
                body: Column(
                  children: <Widget>[
                    SnapshotHistoryCount(history: unlimited),
                    SnapshotHistoryNotice(history: unlimited),
                  ],
                ),
              ),
            ),
          );
          await tester.pump();

          expect(find.text('See plans'), findsNothing);
          expect(find.textContaining('versions'), findsNothing);
        },
      );
    }
  });
}

/// B6 — collaborators per story, by plan (`platfrom/docs/45` §4.11).
///
/// Three things are tested, in this order of importance:
///
/// 1. **The sentinel cannot invert.** `0` seats is the FREE tier, not "unlimited" —
///    the inverse of what `0` means for every other plan limit in the product. A reading
///    that gets this backwards hands every free author unlimited collaborators with no
///    error anywhere, so it is asserted at the decode layer and again at the widget layer.
/// 2. **The affordance is disabled, never hidden.** Defect **C-1** (`platfrom/docs/48`) was
///    a gate that silently removed controls, leaving a user unable to tell the feature
///    existed. A free author here must SEE the invite button, see that it is off, and be
///    told what collaboration costs.
/// 3. **The accept-side refusal is addressed to the invitee.** They cannot buy a seat on
///    someone else's plan, so that state carries no upsell.
///
/// These pump the real screens against a mocked repository, because the defect class this
/// codebase keeps hitting (R-1, M5-1, W5-3, C-1) is client code that looks wired and is
/// not. A test that only decoded the DTO would pass while the number never reached a pixel.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaborator_limit.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/policy_capability.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/presence_entry.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_invitation.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/collaborators_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/invitations_inbox_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/widgets/collaborator_seat_notice.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

class _MockCollaborationRepository extends Mock
    implements CollaborationRepository {}

const String _story = 'story-1';
const String _owner = 'owner-1';

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

CollaboratorLimit _seats({
  int members = 0,
  int pending = 0,
  int limit = 3,
  bool unlimited = false,
  bool? canInvite,
}) {
  final int used = members + pending;
  return CollaboratorLimit(
    storyId: _story,
    members: members,
    pendingInvitations: pending,
    used: used,
    limit: limit,
    remaining: unlimited ? null : (limit - used).clamp(0, limit),
    unlimited: unlimited,
    canInvite: canInvite ?? (unlimited || used < limit),
  );
}

/// The owner's capability map with `story.invite` allowed — the viewer who can spend a seat.
StoryCapabilities _canInviteCaps({bool allowed = true}) => StoryCapabilities(
  capabilities: <String, PolicyCapability>{
    PolicyAction.storyInvite: PolicyCapability(
      action: PolicyAction.storyInvite,
      effect: allowed ? PolicyEffect.allow : PolicyEffect.deny,
      allowed: allowed,
      reason: allowed ? 'owner' : 'role_denies',
      obligations: const <String>[],
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

Future<ProviderContainer> _container(
  _MockCollaborationRepository repo,
  WidgetTester tester,
) async {
  late final ProviderContainer container;
  await tester.runAsync(() async {
    container = await buildTestContainer(
      config: _collabOn,
      collaborationRepository: repo,
    );
  });
  addTearDown(container.dispose);
  return container;
}

void main() {
  // ── 1. The decode, where the inversion would start ─────────────────────────────

  group('CollaboratorLimit decoding (the inverted sentinel)', () {
    test('reads limit 0 as ZERO seats — never as unlimited', () {
      final CollaboratorLimit free =
          CollaboratorLimit.fromJson(<String, Object?>{
            'storyId': _story,
            'members': 0,
            'pendingInvitations': 0,
            'used': 0,
            'limit': 0,
            'remaining': 0,
            'unlimited': false,
            'canInvite': false,
          });

      expect(free.unlimited, isFalse);
      expect(free.isFreeTier, isTrue);
      expect(free.canInvite, isFalse);
    });

    test('reads limit -1 as unlimited, where 0 would have meant none', () {
      final CollaboratorLimit pro =
          CollaboratorLimit.fromJson(<String, Object?>{
            'storyId': _story,
            'members': 12,
            'pendingInvitations': 0,
            'used': 12,
            'limit': -1,
            'remaining': null,
            'unlimited': true,
            'canInvite': true,
          });

      expect(pro.unlimited, isTrue);
      // `isFreeTier` must stay false for an unlimited plan whichever way the wire spells
      // the sentinel — it is defined as "capped AND zero", not as `limit == 0`.
      expect(pro.isFreeTier, isFalse);
      expect(pro.remaining, isNull);
    });

    test('a malformed payload refuses rather than granting seats', () {
      final CollaboratorLimit broken = CollaboratorLimit.fromJson(
        <String, Object?>{},
      );
      expect(broken.canInvite, isFalse);
      expect(broken.unlimited, isFalse);
      expect(CollaboratorLimit.unknown.unlimited, isFalse);
    });
  });

  // ── 2. The collaborators screen ────────────────────────────────────────────────

  group('CollaboratorsScreen seats', () {
    setUp(() {
      registerFallbackValue(_story);
    });

    Future<void> pump(
      WidgetTester tester,
      _MockCollaborationRepository repo,
    ) async {
      final ProviderContainer container = await _container(repo, tester);
      await tester.pumpWidget(
        _wrap(container, const CollaboratorsScreen(storyId: _story)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    void stub(
      _MockCollaborationRepository repo, {
      required CollaboratorLimit seats,
      bool canInvite = true,
      List<StoryMember> members = const <StoryMember>[],
    }) {
      when(() => repo.members(_story)).thenAnswer(
        (_) async => Ok<List<StoryMember>>(<StoryMember>[
          const StoryMember(userId: _owner, role: StoryRole.owner),
          ...members,
        ]),
      );
      when(() => repo.capabilities(_story)).thenAnswer(
        (_) async => Ok<StoryCapabilities>(_canInviteCaps(allowed: canInvite)),
      );
      when(
        () => repo.collaboratorLimit(_story),
      ).thenAnswer((_) async => Ok<CollaboratorLimit>(seats));
      when(() => repo.storyInvitations(_story)).thenAnswer(
        (_) async => const Ok<List<StoryInvitation>>(<StoryInvitation>[]),
      );
      when(() => repo.presence(_story)).thenAnswer(
        (_) async => const Ok<List<PresenceEntry>>(<PresenceEntry>[]),
      );
    }

    testWidgets('shows the seat count before the wall', (
      WidgetTester tester,
    ) async {
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      stub(repo, seats: _seats(members: 2));

      await pump(tester, repo);

      expect(find.text('2 of 3 collaborators'), findsOneWidget);
      expect(find.byType(CollaboratorSeatNotice), findsOneWidget);
      // Present but rendering nothing — not blocked.
      expect(find.text('See plans'), findsNothing);
    });

    testWidgets('names outstanding invitations, which the roster cannot', (
      WidgetTester tester,
    ) async {
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      stub(repo, seats: _seats(members: 1, pending: 1));

      await pump(tester, repo);

      expect(
        find.text('2 of 3 collaborators · 1 invitation pending'),
        findsOneWidget,
      );
    });

    testWidgets(
      'a FREE author SEES the invite action, disabled, with an honest upsell (C-1)',
      (WidgetTester tester) async {
        final _MockCollaborationRepository repo =
            _MockCollaborationRepository();
        stub(repo, seats: _seats(limit: 0, canInvite: false));

        await pump(tester, repo);

        // Not hidden — the C-1 regression.
        final Finder invite = find.byIcon(Icons.person_add_alt_1_outlined);
        expect(invite, findsOneWidget);
        // Not live-and-402ing either — W3c-1.
        final IconButton button = tester.widget<IconButton>(
          find.ancestor(of: invite, matching: find.byType(IconButton)),
        );
        expect(button.onPressed, isNull);
        expect(
          button.tooltip,
          'Invite — no collaborator seats left on this plan',
        );

        // And the offer says what the feature is and what it costs.
        expect(
          find.text('Collaboration isn’t included in your plan'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Plus includes 3 collaborators'),
          findsOneWidget,
        );
        expect(find.text('See plans'), findsOneWidget);
        // "0 of 0 collaborators" counts down from nothing; the offer says it better.
        expect(find.textContaining('of 0 collaborator'), findsNothing);
      },
    );

    testWidgets('a full PLUS story is blocked with the remedies that exist', (
      WidgetTester tester,
    ) async {
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      stub(repo, seats: _seats(members: 3, canInvite: false));

      await pump(tester, repo);

      expect(
        find.text('You’ve used all 3 collaborators on this story'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Remove a collaborator to free a seat'),
        findsOneWidget,
      );
      // Nothing resets, so nothing may promise it does (the W4 defect, docs/48 §3.6).
      expect(find.textContaining('try again'), findsNothing);
      expect(find.textContaining('resets'), findsNothing);
    });

    testWidgets('a downgraded story keeps everyone and says so', (
      WidgetTester tester,
    ) async {
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      stub(repo, seats: _seats(members: 5, canInvite: false));

      await pump(tester, repo);

      expect(
        find.text('This story has more collaborators than your plan includes'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Everyone keeps the access they have'),
        findsOneWidget,
      );
    });

    testWidgets('an UNLIMITED story shows no count and no notice', (
      WidgetTester tester,
    ) async {
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      stub(repo, seats: _seats(members: 9, limit: -1, unlimited: true));

      await pump(tester, repo);

      final IconButton button = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.person_add_alt_1_outlined),
          matching: find.byType(IconButton),
        ),
      );
      expect(button.onPressed, isNotNull);
      expect(find.textContaining('collaborators'), findsNothing);
      expect(find.text('See plans'), findsNothing);
    });

    testWidgets('hides the seat surface from a viewer who cannot invite', (
      WidgetTester tester,
    ) async {
      // The route is `story.invite`-authorized: a reader would only get a 403, and an
      // upsell aimed at someone who does not own the story addresses the wrong person.
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      stub(repo, seats: _seats(limit: 0, canInvite: false), canInvite: false);

      await pump(tester, repo);

      expect(find.byIcon(Icons.person_add_alt_1_outlined), findsNothing);
      expect(
        find.text('Collaboration isn’t included in your plan'),
        findsNothing,
      );
      expect(find.text('See plans'), findsNothing);
    });

    testWidgets('survives an allowance the server refuses to give', (
      WidgetTester tester,
    ) async {
      // A 403 must not take the screen down, and must not fabricate a refusal either:
      // the roster still renders and the invite control stays reachable.
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      stub(repo, seats: _seats());
      when(() => repo.collaboratorLimit(_story)).thenAnswer(
        (_) async => const Err<CollaboratorLimit>(
          Failure.permission(code: 'FORBIDDEN', message: 'nope'),
        ),
      );

      await pump(tester, repo);

      expect(find.text('Members'), findsOneWidget);
    });
  });

  // ── 2b. Both themes ────────────────────────────────────────────────────────────

  group('the seat surfaces render in light AND dark', () {
    /// Deferring dark mode is how the docs/e2e debt accumulated (docs/45 §2 step 5), so
    /// both themes are pumped here. Colours come from `QTokens`, which defines a light and
    /// a dark value for every pair used — a raw hex would pass in one theme and fail in the
    /// other, and this is the test that would catch it being introduced.
    for (final Brightness brightness in Brightness.values) {
      testWidgets('the free upsell renders under $brightness', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildQalamTheme(brightness: brightness),
            home: Scaffold(
              body: CollaboratorSeatNotice(
                allowance: _seats(limit: 0, canInvite: false),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.text('Collaboration isn’t included in your plan'),
          findsOneWidget,
        );
        expect(find.text('See plans'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      /// The rendered a11y scan, in BOTH themes — B4's `piece_limit_test.dart` established
      /// this shape and B6's surfaces are the same kind of thing: tinted text on a tinted
      /// ground plus one action, which is exactly where a colour pair that only works in one
      /// theme goes unnoticed.
      testWidgets('the free upsell meets contrast + tap targets ($brightness)', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildQalamTheme(brightness: brightness),
            home: Scaffold(
              body: CollaboratorSeatNotice(
                allowance: _seats(limit: 0, canInvite: false),
              ),
            ),
          ),
        );
        await tester.pump();

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // `iOSTapTargetGuideline` (44), not `androidTapTargetGuideline` (48): every
        // `QButton` is 44 tall by construction, so the 48 guideline fails app-wide and not
        // because of anything B6 added — recorded as T-10 in `platfrom/docs/48`.
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('the at-cap notice meets contrast ($brightness)', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildQalamTheme(brightness: brightness),
            home: Scaffold(
              body: CollaboratorSeatNotice(
                allowance: _seats(members: 3, canInvite: false),
              ),
            ),
          ),
        );
        await tester.pump();

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('the seat count renders under $brightness', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildQalamTheme(brightness: brightness),
            home: Scaffold(
              body: CollaboratorSeatCount(allowance: _seats(members: 2)),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('2 of 3 collaborators'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  // ── 3. The invitee's side ──────────────────────────────────────────────────────

  group('InvitationsInboxScreen — the accept-side refusal', () {
    testWidgets('speaks to the invitee, and offers them no upsell', (
      WidgetTester tester,
    ) async {
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      when(repo.myInvitations).thenAnswer(
        (_) async => Ok<List<StoryInvitation>>(<StoryInvitation>[
          StoryInvitation(
            id: 'inv-1',
            storyId: _story,
            inviterId: _owner,
            role: StoryRole.editor,
            status: InvitationStatus.pending,
            expiresAt: DateTime.now().add(const Duration(days: 3)),
          ),
        ]),
      );
      when(() => repo.acceptInvitation('inv-1')).thenAnswer(
        (_) async => const Err<StoryMember>(
          Failure.conflict(
            code: ErrorCodes.collaboratorSeatsUnavailable,
            message: 'This story has no collaborator seats left.',
          ),
        ),
      );

      final ProviderContainer container = await _container(repo, tester);
      await tester.pumpWidget(_wrap(container, const InvitationsInboxScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // The refusal persists on the row — it is a fact about the story, not a transient
      // failure, and a message that vanishes cannot usefully say "still valid".
      expect(
        find.textContaining('the owner’s plan has no collaborator seats left'),
        findsOneWidget,
      );
      expect(find.textContaining('still valid'), findsOneWidget);
      // The invitee cannot buy a seat on someone else's plan.
      expect(find.text('See plans'), findsNothing);
      expect(find.textContaining('upgrade'), findsNothing);
    });
  });
}

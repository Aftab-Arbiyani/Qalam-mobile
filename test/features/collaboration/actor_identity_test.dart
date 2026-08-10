/// B3 — profile lookup by id, and its adoption on every id-bearing surface
/// (`platfrom/docs/45` §4).
///
/// Collaboration DTOs carry user **ids** and no names, so until `GET /users/by-id/:id`
/// existed these six screens showed a truncated UUID to real users. The client half of
/// the row is only real if each screen actually resolves it, so these are **reachability**
/// tests: every screen is mounted for real and asserted to render the pen name and NOT
/// the id fragment. The repeated defect class here (R-1, M5-1, W5-3, W8-1) is code that
/// looked wired and was not — a widget that exists but no screen renders.
///
/// The last group covers the other half of honesty: when the lookup fails (a deleted
/// account, offline), the short id comes back as the fallback rather than a blank row or
/// an invented name.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/block_entry.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_comment.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/edit_suggestion.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/policy_capability.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/presence_entry.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/publication_event.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/review_session.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_invitation.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_snapshot.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_snapshot_history.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/trust_summary.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/publishing_repository.dart';
import 'package:qalam_mobile/features/collaboration/presentation/providers/collaboration_providers.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/blocks_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/collaborators_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/comments_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/invitations_inbox_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/publishing_workflow_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/suggestions_screen.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile.dart';
import 'package:qalam_mobile/features/profile/presentation/controllers/actor_profile_controller.dart';
import 'package:qalam_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_profile_repository.dart';

class _MockPublishingRepository extends Mock implements PublishingRepository {}

const String kStoryId = 'story-1';
const String kActorId = '019f9247-c8a6-759f-afa2-cb4ca5fe6ebe';

/// What the surfaces used to show, and what they must fall back to — never the default.
const String kShortId = '019f…6ebe';

const AppConfig _collaborationOn = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: false,
  enableMonetization: false,
  enableCollaboration: true,
);

final Profile _actor = kFakeProfile.copyWith(
  id: kActorId,
  username: 'meera_k',
  penName: 'Meera K.',
);

FakeProfileRepository _repo({Failure? failure}) =>
    FakeProfileRepository(profile: _actor, failure: failure);

/// Mounts [child] with the B3 lookup backed by [repo] and the collaboration data the
/// screen under test reads. Deliberately does NOT stub `actorProfileProvider` — the
/// point is to exercise the real provider → repository path each screen depends on.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required FakeProfileRepository repo,
  List<Object?> data = const <Object?>[],
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_collaborationOn),
        profileRepositoryProvider.overrideWithValue(repo),
        storyCapabilitiesProvider(kStoryId).overrideWith(
          (_) async => const StoryCapabilities(
            capabilities: <String, PolicyCapability>{},
          ),
        ),
        ...data.cast(),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: child,
      ),
    ),
  );
  // Two frames for the screen's own read, two more for the identity lookup it fans out.
  for (int i = 0; i < 4; i++) {
    await tester.pump();
  }
}

void main() {
  group('the by-id lookup itself', () {
    test('resolves an id to a profile through the repository', () async {
      final FakeProfileRepository repo = _repo();
      final ProviderContainer container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final Profile? profile = await container.read(
        actorProfileProvider(kActorId).future,
      );

      expect(profile?.penName, 'Meera K.');
      expect(repo.byIdCalls, <String>[kActorId]);
    });

    /// A failure is not an error state on an identity chip — it resolves to null and the
    /// callers fall back. If this ever threw, every list carrying a deleted user's id
    /// would break instead of degrading.
    test('resolves to null on failure rather than throwing', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(
            _repo(
              failure: const Failure.network(
                code: ErrorCodes.apiOffline,
                message: 'offline',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        await container.read(actorProfileProvider(kActorId).future),
        isNull,
      );
    });

    /// The N+1 answer: one request per DISTINCT user for the session, not per row.
    test('costs one request per distinct id, however many rows ask', () async {
      final FakeProfileRepository repo = _repo();
      final ProviderContainer container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await Future.wait<Profile?>(<Future<Profile?>>[
        for (int i = 0; i < 20; i++)
          container.read(actorProfileProvider(kActorId).future),
      ]);
      await container.read(actorProfileProvider('other-user').future);

      expect(repo.byIdCalls, <String>[kActorId, 'other-user']);
    });
  });

  group('every id-bearing screen renders a real name (reachability)', () {
    testWidgets('comments — the comment author', (WidgetTester tester) async {
      await _pump(
        tester,
        const CollaborationCommentsScreen(storyId: kStoryId),
        repo: _repo(),
        data: <Object?>[
          storyCommentsProvider(kStoryId).overrideWith(
            (_) async => CursorPage<CollaborationComment>(
              items: <CollaborationComment>[_comment()],
              meta: const CursorMeta(),
            ),
          ),
        ],
      );

      expect(find.text('Meera K.'), findsWidgets);
      expect(find.text(kShortId), findsNothing);
    });

    testWidgets('suggestions — the suggestion author', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const SuggestionsScreen(storyId: kStoryId),
        repo: _repo(),
        data: <Object?>[
          storySuggestionsProvider(kStoryId).overrideWith(
            (_) async => CursorPage<EditSuggestion>(
              items: <EditSuggestion>[_suggestion()],
              meta: const CursorMeta(),
            ),
          ),
          viewerIdProvider.overrideWith((_) async => 'someone-else'),
        ],
      );

      expect(find.text('Meera K.'), findsOneWidget);
      expect(find.text(kShortId), findsNothing);
    });

    testWidgets('blocks — the blocked person', (WidgetTester tester) async {
      await _pump(
        tester,
        const BlocksScreen(),
        repo: _repo(),
        data: <Object?>[
          myBlocksProvider.overrideWith((_) async => <BlockEntry>[_block()]),
          trustSummaryProvider.overrideWith((_) async => TrustSummary.healthy),
        ],
      );

      expect(find.text('Meera K.'), findsOneWidget);
      expect(find.text(kShortId), findsNothing);
    });

    testWidgets('invitations inbox — the inviter', (WidgetTester tester) async {
      await _pump(
        tester,
        const InvitationsInboxScreen(),
        repo: _repo(),
        data: <Object?>[
          myInvitationsProvider.overrideWith(
            (_) async => <StoryInvitation>[_invitation()],
          ),
        ],
      );

      expect(find.text('from Meera K.'), findsOneWidget);
      expect(find.textContaining(kShortId), findsNothing);
    });

    testWidgets('collaborators — the member row AND the pending invitee', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CollaboratorsScreen(storyId: kStoryId),
        repo: _repo(),
        data: <Object?>[
          storyMembersProvider(
            kStoryId,
          ).overrideWith((_) async => <StoryMember>[_member()]),
          storyInvitationsProvider(
            kStoryId,
          ).overrideWith((_) async => <StoryInvitation>[_invitation()]),
          storyPresenceProvider(
            kStoryId,
          ).overrideWith((_) async => <PresenceEntry>[_presence()]),
        ],
      );

      // The member row and the pending-invitation row both name the same person.
      expect(find.text('Meera K.'), findsNWidgets(2));
      expect(find.text(kShortId), findsNothing);
    });

    testWidgets('presence bar — the roster avatar’s semantics label', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CollaboratorsScreen(storyId: kStoryId),
        repo: _repo(),
        data: <Object?>[
          storyMembersProvider(
            kStoryId,
          ).overrideWith((_) async => <StoryMember>[]),
          storyInvitationsProvider(
            kStoryId,
          ).overrideWith((_) async => <StoryInvitation>[]),
          storyPresenceProvider(
            kStoryId,
          ).overrideWith((_) async => <PresenceEntry>[_presence()]),
        ],
      );

      // A screen reader hears the person, not a uuid — `PresenceDto` carries no name,
      // so `entry.label` used to fall through to the RAW id here (worse than the short
      // fragment the other surfaces showed).
      expect(find.bySemanticsLabel(RegExp('Meera K.')), findsOneWidget);
    });
  });

  group('the honest fallback survives a failed lookup', () {
    testWidgets('a comment author that cannot be resolved shows the short id', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CollaborationCommentsScreen(storyId: kStoryId),
        repo: _repo(
          failure: const Failure.notFound(
            code: ErrorCodes.userNotFound,
            message: 'gone',
          ),
        ),
        data: <Object?>[
          storyCommentsProvider(kStoryId).overrideWith(
            (_) async => CursorPage<CollaborationComment>(
              items: <CollaborationComment>[_comment()],
              meta: const CursorMeta(),
            ),
          ),
        ],
      );

      // Not blank, and not a fabricated name.
      expect(find.text(kShortId), findsOneWidget);
      expect(find.text('Meera K.'), findsNothing);
    });
  });

  /// The SEVENTH surface, which the row's list did not name: publication history.
  ///
  /// `PublicationEventDto` sends `actorId` and no name, but the entity parsed an
  /// `actorName` the wire has **never** carried — so the history row silently rendered no
  /// actor at all, not even a short id. The phantom field is gone and the actor is
  /// resolved by id like everywhere else.
  group('publication history names its actor (the phantom actorName)', () {
    testWidgets('renders the resolved actor, not a nameless row', (
      WidgetTester tester,
    ) async {
      final _MockPublishingRepository publishing = _MockPublishingRepository();
      when(
        () => publishing.review(any()),
      ).thenAnswer((_) async => const Ok<ReviewSession?>(null));
      when(() => publishing.snapshots(any())).thenAnswer(
        (_) async => const Ok<StorySnapshotHistory>(
          StorySnapshotHistory(
            items: <StorySnapshot>[],
            total: 0,
            visible: 0,
            hidden: 0,
            limit: 0,
            unlimited: true,
          ),
        ),
      );
      when(() => publishing.publicationHistory(any())).thenAnswer(
        (_) async => Ok<List<PublicationEvent>>(<PublicationEvent>[
          PublicationEvent(
            id: 'event-1',
            storyId: kStoryId,
            type: 'published',
            createdAt: DateTime.utc(2026, 8, 4),
            actorId: kActorId,
          ),
        ]),
      );

      await _pump(
        tester,
        const PublishingWorkflowScreen(storyId: kStoryId),
        repo: _repo(),
        data: <Object?>[
          publishingRepositoryProvider.overrideWithValue(publishing),
        ],
      );

      expect(find.textContaining('Meera K.'), findsOneWidget);
    });
  });
}

CollaborationComment _comment() => CollaborationComment(
  id: 'comment-1',
  storyId: kStoryId,
  authorId: kActorId,
  body: 'This stanza needs air.',
  kind: CommentKind.general,
  status: CommentStatus.open,
  mentions: const <String>[],
  createdAt: DateTime.utc(2026, 8, 4),
);

EditSuggestion _suggestion() => EditSuggestion(
  id: 'suggestion-1',
  storyId: kStoryId,
  authorId: kActorId,
  status: SuggestionStatus.pending,
  originalText: 'the moon',
  suggestedText: 'the waning moon',
  anchor: null,
  createdAt: DateTime.utc(2026, 8, 2),
);

BlockEntry _block() => BlockEntry(
  id: 'relationship-1',
  blockerId: 'me-0000',
  blockedId: kActorId,
  kind: 'block',
  createdAt: DateTime.utc(2026, 7, 10),
);

StoryInvitation _invitation() => StoryInvitation(
  id: 'invitation-1',
  storyId: kStoryId,
  inviterId: kActorId,
  inviteeId: kActorId,
  role: StoryRole.editor,
  status: InvitationStatus.pending,
  createdAt: DateTime.utc(2026, 8, 3),
);

StoryMember _member() => StoryMember(
  userId: kActorId,
  role: StoryRole.editor,
  joinedAt: DateTime.utc(2026, 7, 4),
);

PresenceEntry _presence() =>
    const PresenceEntry(userId: kActorId, state: PresenceState.active);

/// Composing and rendering an @mention on the comments screen (**P-2**,
/// `platfrom/docs/48` §5.1).
///
/// The repeated defect class in this codebase (R-1, M5-1, W5-3, W8-1) is code that
/// *looked* wired and was not, so these are **reachability** tests: the real screen is
/// mounted, the real field is typed into, the real person is tapped, and the argument
/// that reaches the repository is inspected for an id. Asserting the wire shape alone
/// would pass even if the typeahead never opened.
///
/// Deliberately the same cases as web's `comment-composer.spec.tsx` — P-2 is the one
/// W7 item that touches both clients, and parity is binding.
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
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_comment.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/policy_capability.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:qalam_mobile/features/collaboration/presentation/providers/collaboration_providers.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/comments_screen.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile.dart';
import 'package:qalam_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:qalam_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

class _MockCollaborationRepository extends Mock
    implements CollaborationRepository {}

const String kStoryId = 'story-1';
const String kFarheenId = '550e8400-e29b-41d4-a716-446655440000';
const String kAliId = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

/// Nobody on this story. Its id must never reach the composer, and when one turns up
/// in a stored body it must degrade rather than print.
const String kStrangerId = '3f2504e0-4f89-11d3-9a0c-0305e82c3301';

const Profile _farheen = Profile(
  id: kFarheenId,
  username: 'farheen',
  penName: 'Farheen Q',
);
const Profile _ali = Profile(id: kAliId, username: 'ali', penName: 'Ali R');

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

/// A by-id lookup with more than one person in it — the shared fake returns the same
/// profile for every id, which cannot express "the typeahead offered the right two".
class _RosterProfileRepository implements ProfileRepository {
  final List<String> byIdCalls = <String>[];
  final List<String> byUsernameCalls = <String>[];

  static const Map<String, Profile> _people = <String, Profile>{
    kFarheenId: _farheen,
    kAliId: _ali,
  };

  @override
  Future<Result<CachedProfile>> publicProfileById(String userId) async {
    byIdCalls.add(userId);
    final Profile? profile = _people[userId];
    if (profile == null) {
      return const Err<CachedProfile>(
        Failure.notFound(code: ErrorCodes.userNotFound, message: 'gone'),
      );
    }
    return Ok<CachedProfile>((profile: profile, isStale: false));
  }

  @override
  Future<Result<CachedProfile>> publicProfile(String username) async {
    byUsernameCalls.add(username);
    return const Err<CachedProfile>(
      Failure.notFound(code: ErrorCodes.userNotFound, message: 'gone'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} not used in this test');
}

CollaborationComment _comment({required String body, String? id}) =>
    CollaborationComment(
      id: id ?? 'c-1',
      storyId: kStoryId,
      authorId: kFarheenId,
      kind: CommentKind.general,
      status: CommentStatus.open,
      body: body,
      mentions: const <String>[],
      createdAt: DateTime.utc(2026, 8, 10),
    );

Future<_RosterProfileRepository> _pump(
  WidgetTester tester, {
  required _MockCollaborationRepository repo,
  List<CollaborationComment> comments = const <CollaborationComment>[],
  CommentThread? thread,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final _RosterProfileRepository profiles = _RosterProfileRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_collaborationOn),
        profileRepositoryProvider.overrideWithValue(profiles),
        collaborationRepositoryProvider.overrideWithValue(repo),
        storyCapabilitiesProvider(kStoryId).overrideWith(
          (_) async => const StoryCapabilities(
            capabilities: <String, PolicyCapability>{
              PolicyAction.storyComment: PolicyCapability(
                action: PolicyAction.storyComment,
                effect: PolicyEffect.allow,
                allowed: true,
                reason: 'role_allows',
                obligations: <String>[],
              ),
            },
          ),
        ),
        storyCommentsProvider(kStoryId).overrideWith(
          (_) async => CursorPage<CollaborationComment>(
            items: comments,
            meta: const CursorMeta(),
          ),
        ),
        if (thread != null)
          storyCommentThreadProvider(
            thread.comment.id,
          ).overrideWith((_) async => thread),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const CollaborationCommentsScreen(storyId: kStoryId),
      ),
    ),
  );
  for (int i = 0; i < 6; i++) {
    await tester.pump();
  }
  return profiles;
}

/// Every [Text] on screen, as the eye reads it.
///
/// `find.textContaining` cannot be used on a mention body: a `Text.rich` is matched via
/// `TextSpan.toPlainText()`, which by default SUBSTITUTES each span's `semanticsLabel`
/// for its text — so it reports "mention of Farheen Q" where the screen says "@farheen".
/// That would make the assertion pass on the label while the visible run said anything
/// at all, including a raw id.
List<String> _visibleText(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map(
      (Text text) =>
          text.data ??
          text.textSpan?.toPlainText(includeSemanticsLabels: false) ??
          '',
    )
    .toList();

/// The same spans' semantics labels — what a screen reader is handed instead.
List<String> _semanticLabels(WidgetTester tester) {
  final List<String> labels = <String>[];
  for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
    text.textSpan?.visitChildren((InlineSpan span) {
      final String? label = span is TextSpan ? span.semanticsLabel : null;
      if (label != null) labels.add(label);
      return true;
    });
  }
  return labels;
}

void main() {
  late _MockCollaborationRepository repo;

  setUp(() {
    repo = _MockCollaborationRepository();
    when(() => repo.members(kStoryId)).thenAnswer(
      (_) async => const Ok<List<StoryMember>>(<StoryMember>[
        StoryMember(userId: kFarheenId, role: StoryRole.owner),
        StoryMember(userId: kAliId, role: StoryRole.editor),
      ]),
    );
  });

  group('composing', () {
    testWidgets(
      'typing @ and tapping a person posts the uuid, and shows a name',
      (WidgetTester tester) async {
        when(
          () => repo.addComment(
            storyId: kStoryId,
            body: any(named: 'body'),
            kind: any(named: 'kind'),
            mentions: any(named: 'mentions'),
          ),
        ).thenAnswer(
          (_) async => Ok<CollaborationComment>(_comment(body: 'ok')),
        );

        await _pump(tester, repo: repo);

        await tester.enterText(find.byType(TextField).last, 'nice catch @far');
        await tester.pump();
        await tester.pump();

        // The person is offered by name, and only the person is — no id on screen.
        expect(find.text('Farheen Q'), findsOneWidget);
        expect(find.text('@farheen'), findsOneWidget);
        expect(find.textContaining(kFarheenId), findsNothing);

        await tester.tap(find.text('Farheen Q'));
        await tester.pump();

        // What the writer now sees is a handle, never 37 characters of hex.
        final TextField field = tester.widget<TextField>(
          find.byType(TextField).last,
        );
        expect(field.controller!.text, 'nice catch @farheen ');

        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();

        final VerificationResult call = verify(
          () => repo.addComment(
            storyId: kStoryId,
            body: captureAny(named: 'body'),
            kind: any(named: 'kind'),
            mentions: captureAny(named: 'mentions'),
          ),
        );
        expect(call.captured[0], 'nice catch @$kFarheenId');
        expect(call.captured[1], <String>[kFarheenId]);
      },
    );

    testWidgets('offers only people who can see the story', (
      WidgetTester tester,
    ) async {
      final _RosterProfileRepository profiles = await _pump(tester, repo: repo);

      await tester.enterText(find.byType(TextField).last, '@');
      await tester.pump();
      await tester.pump();

      expect(find.text('Farheen Q'), findsOneWidget);
      expect(find.text('Ali R'), findsOneWidget);

      // The roster is the ONLY source of candidates. `GET /users/:username` resolves
      // anybody on the platform, which is exactly the id a mention must not carry —
      // `notifyComment` applies no access check to the ids it is handed.
      verify(() => repo.members(kStoryId)).called(greaterThan(0));
      verifyNever(() => repo.resolveInvitee(any()));
      expect(profiles.byUsernameCalls, isEmpty);
      expect(profiles.byIdCalls, containsAll(<String>[kFarheenId, kAliId]));
    });

    testWidgets('narrows the list as the handle is typed', (
      WidgetTester tester,
    ) async {
      await _pump(tester, repo: repo);

      await tester.enterText(find.byType(TextField).last, '@');
      await tester.pump();
      await tester.pump();
      expect(find.text('Ali R'), findsOneWidget);
      expect(find.text('Farheen Q'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, '@ali');
      await tester.pump();
      expect(find.text('Ali R'), findsOneWidget);
      expect(find.text('Farheen Q'), findsNothing);
    });

    testWidgets('a typed @ that is never resolved stays plain text', (
      WidgetTester tester,
    ) async {
      when(
        () => repo.addComment(
          storyId: kStoryId,
          body: any(named: 'body'),
          kind: any(named: 'kind'),
          mentions: any(named: 'mentions'),
        ),
      ).thenAnswer((_) async => Ok<CollaborationComment>(_comment(body: 'ok')));

      await _pump(tester, repo: repo);

      await tester.enterText(
        find.byType(TextField).last,
        'what about @nobody_here',
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      final VerificationResult call = verify(
        () => repo.addComment(
          storyId: kStoryId,
          body: captureAny(named: 'body'),
          kind: any(named: 'kind'),
          mentions: captureAny(named: 'mentions'),
        ),
      );
      // Literal text, and nobody notified — the composer never confirmed who it meant.
      expect(call.captured[0], 'what about @nobody_here');
      expect(call.captured[1], isEmpty);
    });

    testWidgets('the counter reflects the RAW body, not the visible text', (
      WidgetTester tester,
    ) async {
      await _pump(tester, repo: repo);

      await tester.enterText(find.byType(TextField).last, '@far');
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Farheen Q'));
      await tester.pump();

      // Eight visible characters; thirty-seven on the wire, and the UI says so rather
      // than leaving the gap to be discovered at rejection time.
      expect(find.textContaining('37 / 5000'), findsOneWidget);
      expect(
        find.textContaining('each mention counts as the person’s id'),
        findsOneWidget,
      );
    });
  });

  /// The reply composer is a second call site, not a second widget — and P-2's row is
  /// only closed if mentions reach `POST /comments/:id/replies` too. What could
  /// silently break is the thread failing to pass `storyId` down (no roster → no
  /// typeahead) or dropping `mentions` on the way to the controller.
  testWidgets('a reply resolves a mention and posts the id', (
    WidgetTester tester,
  ) async {
    when(
      () => repo.replyToComment(
        commentId: 'c-1',
        body: any(named: 'body'),
        mentions: any(named: 'mentions'),
      ),
    ).thenAnswer(
      (_) async => Ok<CollaborationComment>(_comment(body: 'ok', id: 'c-2')),
    );

    await _pump(
      tester,
      repo: repo,
      comments: <CollaborationComment>[_comment(body: 'the ending needs work')],
      thread: CommentThread(
        comment: _comment(body: 'the ending needs work'),
        replies: const <CollaborationComment>[],
      ),
    );

    await tester.tap(find.text('Replies'));
    for (int i = 0; i < 4; i++) {
      await tester.pump();
    }

    // The reply field is the last one on screen; the root composer is in the bottom bar.
    final Finder replyField = find.byType(TextField).first;
    await tester.enterText(replyField, 'agreed @ali');
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Ali R'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.send).first);
    await tester.pump();

    final VerificationResult call = verify(
      () => repo.replyToComment(
        commentId: 'c-1',
        body: captureAny(named: 'body'),
        mentions: captureAny(named: 'mentions'),
      ),
    );
    expect(call.captured[0], 'agreed @$kAliId');
    expect(call.captured[1], <String>[kAliId]);
  });

  group('rendering', () {
    testWidgets('a stored @<uuid> renders as a name in the thread', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        repo: repo,
        comments: <CollaborationComment>[
          _comment(body: 'nice catch @$kFarheenId'),
        ],
      );
      await tester.pump();

      expect(_visibleText(tester), contains('nice catch @farheen'));
      // The id itself never reaches the reader.
      expect(
        _visibleText(tester).any((String t) => t.contains(kFarheenId)),
        isFalse,
      );
      // …and the pen name is what a screen reader hears for the run.
      expect(_semanticLabels(tester), contains('mention of Farheen Q'));
    });

    testWidgets('an unresolvable id degrades to the B3 fallback', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        repo: repo,
        comments: <CollaborationComment>[
          _comment(body: 'what about @$kStrangerId?'),
        ],
      );
      await tester.pump();

      // The short-id floor: recognisably an id, never the full UUID and never a
      // fabricated name.
      expect(_visibleText(tester), contains('what about @3f25…3301?'));
      expect(
        _visibleText(tester).any((String t) => t.contains(kStrangerId)),
        isFalse,
      );
    });
  });
}

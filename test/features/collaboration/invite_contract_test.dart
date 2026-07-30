/// Regression guard for defect **M-1** (`platfrom/docs/48` §3.1).
///
/// Mobile used to invite with `{role, email}`. `CreateInvitationDto` requires exactly
/// `{inviteeId, role}`, and the API runs `ValidationPipe({whitelist: true,
/// forbidNonWhitelisted: true})` — so `email` was rejected as an unknown property AND the required
/// `inviteeId` was missing. Every invitation 400'd, on every build, since AF6 shipped.
///
/// These tests pin the request shape at the only layer that knows it (the data source) plus the
/// contract types either side of it, so the email-shaped call cannot come back by refactor.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/network/api_client.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/collaboration_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/data/repositories/collaboration_repository_impl.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/invitee_candidate.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_invitation.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockCollabRemote extends Mock implements CollaborationRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
  });

  group('invite request shape (M-1)', () {
    late _MockApiClient api;
    late CollaborationRemoteDataSource remote;

    setUp(() {
      api = _MockApiClient();
      remote = CollaborationRemoteDataSource(api);
    });

    test(
      'sends exactly {inviteeId, role} — never an email or a userId key',
      () async {
        when(
          () => api.post<StoryInvitation>(
            any(),
            body: any(named: 'body'),
            decode: any(named: 'decode'),
          ),
        ).thenAnswer(
          (_) async => const StoryInvitation(
            id: 'inv1',
            storyId: 's1',
            role: StoryRole.editor,
            status: InvitationStatus.pending,
            inviterId: 'u1',
            inviteeId: 'u2',
          ),
        );

        await remote.invite(
          storyId: 's1',
          inviteeId: 'u2',
          role: StoryRole.editor,
        );

        final Map<String, Object?> body =
            verify(
                  () => api.post<StoryInvitation>(
                    '/stories/s1/invitations',
                    body: captureAny(named: 'body'),
                    decode: any(named: 'decode'),
                  ),
                ).captured.single
                as Map<String, Object?>;

        expect(body, <String, Object?>{
          'inviteeId': 'u2',
          'role': StoryRole.editor,
        });
        // The two keys that made every invitation fail validation.
        expect(body.containsKey('email'), isFalse);
        expect(body.containsKey('userId'), isFalse);
      },
    );

    test(
      'resolveInvitee reads the profile by username to get the id',
      () async {
        when(
          () => api.get<InviteeCandidate>(
            any(),
            decode: any(named: 'decode'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async => const InviteeCandidate(
            id: 'u2',
            username: 'farheen',
            penName: 'Farheen',
          ),
        );

        final InviteeCandidate candidate = await remote.resolveInvitee(
          'farheen',
        );

        expect(candidate.id, 'u2');
        expect(candidate.label, 'Farheen');
        verify(
          () => api.get<InviteeCandidate>(
            '/users/farheen',
            decode: any(named: 'decode'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(1);
      },
    );
  });

  group('accept returns the new member, not the invitation', () {
    test('repository surfaces a StoryMember', () async {
      // The endpoint answers with `MemberDto`. Decoding it as a StoryInvitation used to "work"
      // silently, because that entity defaults every missing field — producing an invitation with
      // an empty id and story id rather than an error.
      final _MockCollabRemote remote = _MockCollabRemote();
      final CollaborationRepositoryImpl repo = CollaborationRepositoryImpl(
        remote,
      );
      const StoryMember member = StoryMember(
                userId: 'u2',
        role: StoryRole.editor,
      );
      when(
        () => remote.acceptInvitation('inv1'),
      ).thenAnswer((_) async => member);

      final Result<StoryMember> result = await repo.acceptInvitation('inv1');

      expect(result.valueOrNull, member);
    });
  });

  group('StoryInvitation mirrors InvitationDto', () {
    test(
      'parses the real wire keys (inviterId / inviteeId), not invented ones',
      () {
        final StoryInvitation invitation =
            StoryInvitation.fromJson(<String, dynamic>{
              'id': 'inv1',
              'storyId': 's1',
              'inviterId': 'u1',
              'inviteeId': 'u2',
              'role': StoryRole.editor,
              'status': InvitationStatus.pending,
              'expiresAt': '2026-08-01T00:00:00.000Z',
              'respondedAt': null,
              'createdAt': '2026-07-28T00:00:00.000Z',
            });

        expect(invitation.inviterId, 'u1');
        expect(invitation.inviteeId, 'u2');
        expect(invitation.expiresAt, isNotNull);
        expect(invitation.isPending, isTrue);
      },
    );

    test('shortActorId keeps an id recognisable without inventing a name', () {
      expect(shortActorId('019f9247-c8a6-759f-afa2-cb4ca5fe6ebe'), '019f…6ebe');
      expect(shortActorId(null), 'someone');
    });
  });

  group('InviteeCandidate', () {
    test('falls back to the handle when the profile has no pen name', () {
      const InviteeCandidate candidate = InviteeCandidate(
        id: 'u3',
        username: 'noor',
      );
      expect(candidate.label, '@noor');
    });

    test('parses the profile payload', () {
      final InviteeCandidate candidate = InviteeCandidate.fromJson(
        <String, dynamic>{
          'id': 'u4',
          'username': 'zeb',
          'penName': 'Zeb',
          'bio': 'ignored',
        },
      );
      expect(candidate.id, 'u4');
      expect(candidate.username, 'zeb');
      expect(candidate.penName, 'Zeb');
    });
  });
}

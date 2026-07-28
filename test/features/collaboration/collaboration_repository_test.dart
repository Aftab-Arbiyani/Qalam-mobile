import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/error/api_exception.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/collaboration_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/publishing_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/trust_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/data/repositories/collaboration_repository_impl.dart';
import 'package:qalam_mobile/features/collaboration/data/repositories/publishing_repository_impl.dart';
import 'package:qalam_mobile/features/collaboration/data/repositories/trust_repository_impl.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/policy_capability.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/review_session.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/trust_summary.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

class _MockCollabRemote extends Mock implements CollaborationRemoteDataSource {}

class _MockPublishingRemote extends Mock
    implements PublishingRemoteDataSource {}

class _MockTrustRemote extends Mock implements TrustRemoteDataSource {}

void main() {
  const ApiException boom = ApiException(
    code: ErrorCodes.internalServerError,
    message: 'boom',
    status: 500,
  );

  group('CollaborationRepositoryImpl', () {
    late _MockCollabRemote remote;
    late CollaborationRepositoryImpl repo;

    setUp(() {
      remote = _MockCollabRemote();
      repo = CollaborationRepositoryImpl(remote);
    });

    test('members() returns Ok with the decoded members', () async {
      const StoryMember member = StoryMember(
                userId: 'u1',
        role: StoryRole.editor,
      );
      when(
        () => remote.members('s1'),
      ).thenAnswer((_) async => <StoryMember>[member]);

      final Result<List<StoryMember>> result = await repo.members('s1');

      expect(result, isA<Ok<List<StoryMember>>>());
      expect(result.valueOrNull, <StoryMember>[member]);
    });

    test('capabilities() maps an ApiException to a Failure (Err)', () async {
      when(() => remote.capabilities('s1')).thenThrow(boom);

      final Result<StoryCapabilities> result = await repo.capabilities('s1');

      expect(result, isA<Err<StoryCapabilities>>());
      expect(result.failureOrNull, isNotNull);
    });

    test('removeMember() returns Ok<Unit> on success', () async {
      when(
        () => remote.removeMember(storyId: 's1', userId: 'u1'),
      ).thenAnswer((_) async {});

      final result = await repo.removeMember(storyId: 's1', userId: 'u1');

      expect(result.isOk, isTrue);
      verify(() => remote.removeMember(storyId: 's1', userId: 'u1')).called(1);
    });

    test('heartbeat() returns Ok<Unit> on success', () async {
      when(
        () => remote.heartbeat(storyId: 's1', state: PresenceState.typing),
      ).thenAnswer((_) async {});

      final result = await repo.heartbeat(
        storyId: 's1',
        state: PresenceState.typing,
      );

      expect(result.isOk, isTrue);
    });
  });

  group('PublishingRepositoryImpl', () {
    late _MockPublishingRemote remote;
    late PublishingRepositoryImpl repo;

    setUp(() {
      remote = _MockPublishingRemote();
      repo = PublishingRepositoryImpl(remote);
    });

    test('review() returns Ok with the decoded session', () async {
      const ReviewSession session = ReviewSession(
        id: 'r1',
        storyId: 's1',
        state: ReviewState.inReview,
      );
      when(() => remote.review('s1')).thenAnswer((_) async => session);

      // Nullable: no session is a legitimate `data: null`, not an error (P-4).
      final Result<ReviewSession?> result = await repo.review('s1');

      expect(result.valueOrNull, session);
    });

    test('review() returns Ok(null) when the story has no session (P-4)', () async {
      when(() => remote.review('s1')).thenAnswer((_) async => null);

      final Result<ReviewSession?> result = await repo.review('s1');

      expect(result.isErr, isFalse);
      expect(result.valueOrNull, isNull);
    });

    test('publish() maps an ApiException to a Failure (Err)', () async {
      when(() => remote.publish(storyId: 's1')).thenThrow(boom);

      final result = await repo.publish(storyId: 's1');

      expect(result.isErr, isTrue);
    });
  });

  group('TrustRepositoryImpl', () {
    late _MockTrustRemote remote;
    late TrustRepositoryImpl repo;

    setUp(() {
      remote = _MockTrustRemote();
      repo = TrustRepositoryImpl(remote);
    });

    test('myTrust() returns Ok with the decoded summary', () async {
      when(
        () => remote.myTrust(),
      ).thenAnswer((_) async => TrustSummary.healthy);

      final Result<TrustSummary> result = await repo.myTrust();

      expect(result.valueOrNull, TrustSummary.healthy);
    });

    test('block() returns Ok<Unit> and delegates to the remote', () async {
      when(() => remote.block('u9')).thenAnswer((_) async {});

      final result = await repo.block('u9');

      expect(result.isOk, isTrue);
      verify(() => remote.block('u9')).called(1);
    });

    test('mute() maps an ApiException to a Failure (Err)', () async {
      when(() => remote.mute('u9')).thenThrow(boom);

      final result = await repo.mute('u9');

      expect(result.isErr, isTrue);
    });
  });
}

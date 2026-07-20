import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_comment.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:qalam_mobile/features/collaboration/presentation/controllers/collaboration_controller.dart';
import 'package:qalam_mobile/features/collaboration/presentation/providers/collaboration_providers.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

import '../../support/harness.dart';

class _MockCollaborationRepository extends Mock
    implements CollaborationRepository {}

void main() {
  late _MockCollaborationRepository repo;

  const StoryMember member = StoryMember(
    id: 'm1',
    storyId: 's1',
    userId: 'u1',
    role: StoryRole.editor,
  );

  setUp(() {
    repo = _MockCollaborationRepository();
  });

  Future<ProviderContainer> container() =>
      buildTestContainer(collaborationRepository: repo);

  test('removeMember() invalidates the members read on success', () async {
    final ProviderContainer c = await container();
    addTearDown(c.dispose);

    when(() => repo.members('s1')).thenAnswer(
      (_) async => const Ok<List<StoryMember>>(<StoryMember>[member]),
    );
    when(
      () => repo.removeMember(storyId: 's1', userId: 'u1'),
    ).thenAnswer((_) async => const Ok<Unit>(unit));

    // Keep the family instance alive so an invalidation triggers a real re-fetch.
    final sub = c.listen(storyMembersProvider('s1'), (_, _) {});
    addTearDown(sub.close);

    await c.read(storyMembersProvider('s1').future);
    verify(() => repo.members('s1')).called(1);

    final bool ok = await c
        .read(collaborationControllerProvider.notifier)
        .removeMember(storyId: 's1', userId: 'u1');
    expect(ok, isTrue);

    await c.read(storyMembersProvider('s1').future);
    // The invalidation from removeMember forced exactly one more fetch.
    verify(() => repo.members('s1')).called(1);
  });

  test('addComment() surfaces a failure into the controller state', () async {
    final ProviderContainer c = await container();
    addTearDown(c.dispose);

    when(
      () => repo.addComment(
        storyId: 's1',
        body: 'hi',
        kind: CommentKind.general,
        mentions: const <String>[],
      ),
    ).thenAnswer(
      (_) async => const Err<CollaborationComment>(
        Failure.network(code: ErrorCodes.apiOffline, isOffline: true),
      ),
    );

    final CollaborationComment? result = await c
        .read(collaborationControllerProvider.notifier)
        .addComment(storyId: 's1', body: 'hi');

    expect(result, isNull);
    expect(c.read(collaborationControllerProvider).hasError, isTrue);
  });
}

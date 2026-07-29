import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_comment.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/edit_suggestion.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/text_anchor.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:qalam_mobile/features/collaboration/presentation/controllers/collaboration_controller.dart';
import 'package:qalam_mobile/features/collaboration/presentation/providers/collaboration_providers.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_detail.dart';
import 'package:qalam_mobile/features/reading/domain/repositories/reading_repository.dart';
import 'package:qalam_mobile/features/reading/presentation/controllers/piece_detail_controller.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

import '../../support/harness.dart';

class _MockCollaborationRepository extends Mock
    implements CollaborationRepository {}

class _MockReadingRepository extends Mock implements ReadingRepository {}

void main() {
  late _MockCollaborationRepository repo;

  const StoryMember member = StoryMember(
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

  // ── C-13: accepting applies the edit, so the piece read must follow ──────────
  //
  // The server rewrites the anchored range of the story body on accept (D1,
  // `docs/56` §3b). A client that refreshes only the suggestions list then renders
  // prose the server has already changed. Reject and withdraw move no prose, so they
  // must NOT dump the piece — refetching it on every resolution would be waste.

  const EditSuggestion suggestion = EditSuggestion(
    id: 'sg1',
    storyId: 's1',
    authorId: 'u1',
    anchor: TextAnchor(from: 0, to: 3),
    originalText: 'old',
    suggestedText: 'new',
    status: SuggestionStatus.accepted,
  );

  const PieceDetail piece = PieceDetail(
    id: 's1',
    title: 'A story',
    author: Author(username: 'farheen'),
  );

  /// Counts the piece reads a resolution triggers: one on first listen, plus one
  /// per invalidation. Returns the count AFTER the given action ran.
  Future<int> pieceReadsAfter(
    Future<void> Function(CollaborationController c) action,
  ) async {
    final _MockReadingRepository reading = _MockReadingRepository();
    when(() => reading.getPiece('s1')).thenAnswer(
      (_) async => const Ok<CachedDetail>((piece: piece, isStale: false)),
    );
    final ProviderContainer c = await buildTestContainer(
      collaborationRepository: repo,
      readingRepository: reading,
    );
    addTearDown(c.dispose);

    // Keep the family instance alive so an invalidation triggers a real re-fetch.
    final sub = c.listen(pieceDetailControllerProvider('s1'), (_, _) {});
    addTearDown(sub.close);
    await c.read(pieceDetailControllerProvider('s1').future);

    await action(c.read(collaborationControllerProvider.notifier));
    await c.read(pieceDetailControllerProvider('s1').future);
    return verify(() => reading.getPiece('s1')).callCount;
  }

  test('acceptSuggestion() re-reads the piece body it just rewrote', () async {
    when(
      () => repo.acceptSuggestion('sg1'),
    ).thenAnswer((_) async => const Ok<EditSuggestion>(suggestion));

    // 1 initial read + 1 forced by the invalidation.
    expect(await pieceReadsAfter((c) => c.acceptSuggestion('sg1')), 2);
  });

  test('rejectSuggestion() leaves the cached piece alone', () async {
    when(
      () => repo.rejectSuggestion('sg1'),
    ).thenAnswer((_) async => const Ok<EditSuggestion>(suggestion));

    // Only the initial read — nothing invalidated the piece.
    expect(await pieceReadsAfter((c) => c.rejectSuggestion('sg1')), 1);
  });

  test('withdrawSuggestion() leaves the cached piece alone', () async {
    when(
      () => repo.withdrawSuggestion('sg1'),
    ).thenAnswer((_) async => const Ok<EditSuggestion>(suggestion));

    expect(await pieceReadsAfter((c) => c.withdrawSuggestion('sg1')), 1);
  });
}

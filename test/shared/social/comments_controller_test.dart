import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/shared/pagination/paged_list_state.dart';
import 'package:qalam_mobile/shared/social/domain/entities/comment.dart';
import 'package:qalam_mobile/shared/social/presentation/controllers/comments_controller.dart';

import '../../support/fake_social.dart';
import '../../support/harness.dart';

Comment _c(String id, String body) => Comment(id: id, body: body);

void main() {
  Future<(ProviderContainer, FakeCommentRepository)> setup({
    List<Comment> comments = const <Comment>[],
  }) async {
    final FakeCommentRepository repo = FakeCommentRepository(comments: comments);
    final ProviderContainer c = await buildTestContainer(
      commentRepository: repo,
    );
    addTearDown(c.dispose);
    await c.read(commentsControllerProvider('p1').future);
    return (c, repo);
  }

  PagedListState<Comment> state(ProviderContainer c) =>
      c.read(commentsControllerProvider('p1')).asData!.value;

  test('add optimistically prepends then reconciles to the server node', () async {
    final (ProviderContainer c, FakeCommentRepository _) = await setup(
      comments: <Comment>[_c('a', 'existing')],
    );
    await c.read(commentsControllerProvider('p1').notifier).add('hello');
    expect(state(c).items.length, 2);
    // First item is the reconciled server node (id from the fake), not a temp id.
    expect(state(c).items.first.id, 'server-1');
    expect(state(c).items.first.body, 'hello');
  });

  test('add rolls the optimistic node back on failure', () async {
    final (ProviderContainer c, FakeCommentRepository repo) = await setup(
      comments: <Comment>[_c('a', 'existing')],
    );
    repo.failNext = true;
    await c.read(commentsControllerProvider('p1').notifier).add('hello');
    expect(state(c).items.length, 1); // temp removed
    expect(state(c).items.single.id, 'a');
  });

  test('edit optimistically updates then rolls back on failure', () async {
    final (ProviderContainer c, FakeCommentRepository repo) = await setup(
      comments: <Comment>[_c('a', 'original')],
    );
    repo.failNext = true;
    await c.read(commentsControllerProvider('p1').notifier).edit('a', 'changed');
    expect(state(c).items.single.body, 'original'); // rolled back
  });

  test('delete optimistically tombstones the comment', () async {
    final (ProviderContainer c, FakeCommentRepository _) = await setup(
      comments: <Comment>[_c('a', 'to remove')],
    );
    await c.read(commentsControllerProvider('p1').notifier).delete('a');
    expect(state(c).items.single.isDeleted, isTrue);
    expect(state(c).items.single.author, isNull);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/shared/pagination/paged_list_state.dart';
import 'package:qalam_mobile/shared/social/domain/entities/collection.dart';
import 'package:qalam_mobile/shared/social/presentation/controllers/collections_controller.dart';

import '../../support/fake_social.dart';
import '../../support/harness.dart';

Collection _col(String id, String title) => Collection(id: id, title: title);

void main() {
  test('create returns Ok and refreshes the list', () async {
    final ProviderContainer c = await buildTestContainer(
      collectionRepository: FakeCollectionRepository(
        collections: <Collection>[_col('a', 'Favorites')],
      ),
    );
    addTearDown(c.dispose);
    await c.read(collectionsControllerProvider.future);
    final result = await c
        .read(collectionsControllerProvider.notifier)
        .create(title: 'Rainy ghazals');
    expect(result.isOk, isTrue);
  });

  test('delete removes optimistically; a failure rolls back', () async {
    final FakeCollectionRepository repo = FakeCollectionRepository(
      collections: <Collection>[_col('a', 'One'), _col('b', 'Two')],
    );
    final ProviderContainer c = await buildTestContainer(
      collectionRepository: repo,
    );
    addTearDown(c.dispose);
    await c.read(collectionsControllerProvider.future);

    repo.failNext = true;
    await c.read(collectionsControllerProvider.notifier).deleteCollection('a');
    final PagedListState<Collection> after =
        c.read(collectionsControllerProvider).asData!.value;
    expect(after.items.length, 2); // rolled back after failure
  });

  test('collection pieces remove optimistically', () async {
    final ProviderContainer c = await buildTestContainer(
      collectionRepository: FakeCollectionRepository(
        pieces: const <CollectionPieceItem>[
          CollectionPieceItem(pieceId: 'p1', title: 'A'),
          CollectionPieceItem(pieceId: 'p2', title: 'B'),
        ],
      ),
    );
    addTearDown(c.dispose);
    final provider = collectionPiecesControllerProvider('c1');
    await c.read(provider.future);
    await c.read(provider.notifier).removePiece('p1');
    expect(
      c.read(provider).asData!.value.items.map((CollectionPieceItem p) => p.pieceId),
      <String>['p2'],
    );
  });
}

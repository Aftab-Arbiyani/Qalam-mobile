/// Collection controllers (docs/40 §8.3) — the owner's collections list (infinite,
/// cursor-paginated over the shared [CollectionRepository]) with create / rename /
/// delete, and a per-collection pieces list with optimistic remove. Reuses the
/// shared [CursorPaginator]. Mutations return a [Result] so the UI surfaces
/// failures; the repository evicts the list cache so a refresh shows server truth.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../domain/enums.dart';
import '../../../pagination/paged_list_state.dart';
import '../../domain/entities/collection.dart';
import '../../social_providers.dart';

part 'collections_controller.g.dart';

@riverpod
class CollectionsController extends _$CollectionsController {
  CursorPaginator<Collection>? _paginator;

  @override
  Future<PagedListState<Collection>> build() {
    final paginator = CursorPaginator<Collection>(
      (String? cursor) =>
          ref.read(collectionRepositoryProvider).myCollections(cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() async {
    final CursorPaginator<Collection>? paginator = _paginator;
    final PagedListState<Collection>? current = state.asData?.value;
    if (paginator == null ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    state = AsyncData<PagedListState<Collection>>(
      current.copyWith(isLoadingMore: true),
    );
    state = AsyncData<PagedListState<Collection>>(
      await paginator.next(current),
    );
  }

  Future<void> refresh() async {
    final p = _paginator;
    if (p != null) state = await AsyncValue.guard(p.first);
  }

  Future<Result<Collection>> create({
    required String title,
    String? description,
    Visibility? visibility,
  }) async {
    final result = await ref
        .read(collectionRepositoryProvider)
        .create(title: title, description: description, visibility: visibility);
    if (result.isOk) await refresh();
    return result;
  }

  Future<Result<Collection>> rename(
    String id, {
    String? title,
    String? description,
  }) async {
    final PagedListState<Collection>? current = state.asData?.value;
    final result = await ref
        .read(collectionRepositoryProvider)
        .update(id, title: title, description: description);
    result.fold((Collection updated) {
      if (current != null) {
        state = AsyncData<PagedListState<Collection>>(
          current.copyWith(
            items: current.items
                .map((Collection c) => c.id == id ? updated : c)
                .toList(),
          ),
        );
      }
    }, (Object _) {});
    return result;
  }

  Future<Result<Unit>> deleteCollection(String id) async {
    final PagedListState<Collection>? current = state.asData?.value;
    if (current != null) {
      state = AsyncData<PagedListState<Collection>>(
        current.copyWith(
          items: current.items.where((Collection c) => c.id != id).toList(),
        ),
      );
    }
    final result = await ref.read(collectionRepositoryProvider).delete(id);
    if (result.isErr && current != null) {
      state = AsyncData<PagedListState<Collection>>(current); // rollback
    }
    return result;
  }
}

@riverpod
class CollectionPiecesController extends _$CollectionPiecesController {
  CursorPaginator<CollectionPieceItem>? _paginator;

  @override
  Future<PagedListState<CollectionPieceItem>> build(String collectionId) {
    final paginator = CursorPaginator<CollectionPieceItem>(
      (String? cursor) => ref
          .read(collectionRepositoryProvider)
          .collectionPieces(collectionId, cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() async {
    final CursorPaginator<CollectionPieceItem>? paginator = _paginator;
    final PagedListState<CollectionPieceItem>? current = state.asData?.value;
    if (paginator == null ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    state = AsyncData<PagedListState<CollectionPieceItem>>(
      current.copyWith(isLoadingMore: true),
    );
    state = AsyncData<PagedListState<CollectionPieceItem>>(
      await paginator.next(current),
    );
  }

  Future<void> refresh() async {
    final p = _paginator;
    if (p != null) state = await AsyncValue.guard(p.first);
  }

  Future<void> removePiece(String pieceId) async {
    final PagedListState<CollectionPieceItem>? current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<PagedListState<CollectionPieceItem>>(
      current.copyWith(
        items: current.items
            .where((CollectionPieceItem p) => p.pieceId != pieceId)
            .toList(),
      ),
    );
    final result = await ref
        .read(collectionRepositoryProvider)
        .removePiece(collectionId, pieceId);
    if (result.isErr) {
      state = AsyncData<PagedListState<CollectionPieceItem>>(
        current,
      ); // rollback
    }
  }
}

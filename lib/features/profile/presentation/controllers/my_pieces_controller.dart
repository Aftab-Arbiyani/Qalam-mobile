/// The signed-in user's published-pieces grid (docs/40 §19). Holds an
/// `AsyncValue<PagedListState<ProfilePiece>>` over `GET /me/pieces?status=published`
/// through the shared [CursorPaginator] — page-1 load/error is the `AsyncValue`;
/// [loadMore]/[refresh] mutate the accumulated state. There is NO public equivalent
/// for other authors on the frozen `v1` (documented gap, docs/40 §45) — this is a
/// self-only surface.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/pagination/paged_list_state.dart';
import '../../domain/entities/profile_piece.dart';
import '../providers/profile_providers.dart';

part 'my_pieces_controller.g.dart';

@riverpod
class MyPiecesController extends _$MyPiecesController {
  CursorPaginator<ProfilePiece>? _paginator;

  @override
  Future<PagedListState<ProfilePiece>> build() {
    final CursorPaginator<ProfilePiece> paginator =
        CursorPaginator<ProfilePiece>(
          (String? cursor) => ref
              .read(profileRepositoryProvider)
              .myPublishedPieces(cursor: cursor),
        );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() async {
    final CursorPaginator<ProfilePiece>? paginator = _paginator;
    final PagedListState<ProfilePiece>? current = state.asData?.value;
    if (paginator == null ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    state = AsyncData<PagedListState<ProfilePiece>>(
      current.copyWith(isLoadingMore: true),
    );
    state = AsyncData<PagedListState<ProfilePiece>>(
      await paginator.next(current),
    );
  }

  Future<void> refresh() async {
    final CursorPaginator<ProfilePiece>? paginator = _paginator;
    if (paginator == null) return;
    state = await AsyncValue.guard(paginator.first);
  }
}

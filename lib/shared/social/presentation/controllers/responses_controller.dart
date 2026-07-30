/// Responses controller (docs/40 §8.3) — the infinite cursor-paginated list of a
/// piece's responses (reusing the shared [CursorPaginator]) plus a create action
/// that returns the new draft piece id for the caller to open in the editor.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/result.dart';
import '../../../pagination/paged_list_state.dart';
import '../../domain/entities/response_item.dart';
import '../../social_providers.dart';

part 'responses_controller.g.dart';

@riverpod
class ResponsesController extends _$ResponsesController {
  CursorPaginator<ResponseItem>? _paginator;

  @override
  Future<PagedListState<ResponseItem>> build(String pieceId) {
    final paginator = CursorPaginator<ResponseItem>(
      (String? cursor) =>
          ref.read(responseRepositoryProvider).listResponses(pieceId, cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() async {
    final CursorPaginator<ResponseItem>? paginator = _paginator;
    final PagedListState<ResponseItem>? current = state.asData?.value;
    if (paginator == null ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    state = AsyncData<PagedListState<ResponseItem>>(
      current.copyWith(isLoadingMore: true),
    );
    state = AsyncData<PagedListState<ResponseItem>>(
      await paginator.next(current),
    );
  }

  Future<void> refresh() async {
    final p = _paginator;
    if (p != null) state = await AsyncValue.guard(p.first);
  }

  /// Create a response draft; returns the new draft piece id (or a [Failure]).
  Future<Result<String>> createResponse({
    required String languageCode,
    String? title,
  }) => ref
      .read(responseRepositoryProvider)
      .createResponse(pieceId, title: title, languageCode: languageCode);
}

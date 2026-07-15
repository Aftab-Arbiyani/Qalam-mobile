/// The piece-detail controller (docs/40 §8.3) — loads the full reading aggregate
/// cache-then-network for a piece id. Page-load/error is the `AsyncValue` (→
/// skeleton / error view); [refresh] re-fetches network-first. Carries [isStale]
/// so the reader can flag cached-offline content.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/reading_repository.dart';
import '../providers/reading_providers.dart';

part 'piece_detail_controller.g.dart';

@riverpod
class PieceDetailController extends _$PieceDetailController {
  @override
  Future<CachedDetail> build(String pieceId) async {
    final result = await ref.watch(readingRepositoryProvider).getPiece(pieceId);
    return result.fold(
      (CachedDetail detail) => detail,
      (Object failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(readingRepositoryProvider)
          .getPiece(pieceId);
      return result.fold(
        (CachedDetail detail) => detail,
        (Object failure) => throw failure,
      );
    });
  }
}

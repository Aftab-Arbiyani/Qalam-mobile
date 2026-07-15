/// Discovery shelf controllers (docs/40 §6) — each loads the FIRST page of a
/// discovery endpoint (cache-then-network via the shared feed repository) for a
/// horizontally-scrolling shelf. "Continue Reading" / "Recently Read" are local
/// reading history (separate providers in `core/reading_history`) — no backend
/// endpoint exists for them.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/enums.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/entities/writer_summary.dart';
import '../providers/feed_providers.dart';

part 'discovery_controllers.g.dart';

@riverpod
Future<List<PieceSummary>> discoverPiecesShelf(
  Ref ref,
  DiscoverPieceKind kind,
) async {
  final result = await ref.watch(feedRepositoryProvider).discoverPieces(kind);
  return result.fold(
    (CachedPage<PieceSummary> page) => page.page.items,
    (Object failure) => throw failure,
  );
}

@riverpod
Future<List<WriterSummary>> discoverWritersShelf(
  Ref ref,
  WriterKind kind,
) async {
  final result = await ref.watch(feedRepositoryProvider).discoverWriters(kind);
  return result.fold(
    (CachedPage<WriterSummary> page) => page.page.items,
    (Object failure) => throw failure,
  );
}

@riverpod
Future<List<TrendingTag>> trendingTagsShelf(Ref ref) async {
  final result = await ref.watch(feedRepositoryProvider).trendingTags();
  return result.fold(
    (CachedPage<TrendingTag> page) => page.page.items,
    (Object failure) => throw failure,
  );
}

/// Discovery composition root + shelf providers (docs/40 §6, §9). Binds the
/// [DiscoveryRepository] to its implementation and exposes one first-page
/// provider per shelf. Shelves load the FIRST page only (horizontal, best-effort)
/// and throw the [Failure] on error so a [DiscoveryShelf] renders skeleton → data
/// → hidden. Consumed by both the feed `/discover` screen and the search
/// discovery landing (docs/40 §7.3 — shared, so neither feature imports the other).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../domain/entities/piece_summary.dart';
import '../domain/entities/trend_item.dart';
import '../domain/entities/writer_summary.dart';
import '../domain/enums.dart';
import '../pagination/cached_page.dart';
import 'data/discovery_remote_data_source.dart';
import 'data/discovery_repository_impl.dart';
import 'domain/discovery_repository.dart';

part 'discovery_providers.g.dart';

@riverpod
DiscoveryRemoteDataSource discoveryRemoteDataSource(Ref ref) =>
    DiscoveryRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
DiscoveryRepository discoveryRepository(Ref ref) => DiscoveryRepositoryImpl(
  ref.watch(discoveryRemoteDataSourceProvider),
  ref.watch(cacheListDataSourceProvider),
);

@riverpod
Future<List<PieceSummary>> discoverPiecesShelf(
  Ref ref,
  DiscoverPieceKind kind,
) async {
  final result = await ref
      .watch(discoveryRepositoryProvider)
      .discoverPieces(kind);
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
  final result = await ref
      .watch(discoveryRepositoryProvider)
      .discoverWriters(kind);
  return result.fold(
    (CachedPage<WriterSummary> page) => page.page.items,
    (Object failure) => throw failure,
  );
}

@riverpod
Future<List<TrendingTag>> trendingTagsShelf(Ref ref) async {
  final result = await ref.watch(discoveryRepositoryProvider).trendingTags();
  return result.fold(
    (CachedPage<TrendingTag> page) => page.page.items,
    (Object failure) => throw failure,
  );
}

@riverpod
Future<List<TrendingGenre>> trendingGenresShelf(Ref ref) async {
  final result = await ref.watch(discoveryRepositoryProvider).trendingGenres();
  return result.fold(
    (CachedPage<TrendingGenre> page) => page.page.items,
    (Object failure) => throw failure,
  );
}

@riverpod
Future<List<TrendingLanguage>> trendingLanguagesShelf(Ref ref) async {
  final result = await ref
      .watch(discoveryRepositoryProvider)
      .trendingLanguages();
  return result.fold(
    (CachedPage<TrendingLanguage> page) => page.page.items,
    (Object failure) => throw failure,
  );
}

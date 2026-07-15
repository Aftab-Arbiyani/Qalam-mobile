/// Shared taxonomy composition root (docs/40 §9). Binds the taxonomy domain
/// repository to its data implementation and exposes the language + genre option
/// lists as `AsyncValue` (cache-then-network with offline fallback in the
/// repository). Server state, so repository-backed FutureProviders, not UI
/// notifiers. Consumed by both the writing metadata form and the profile editor.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../../core/utils/result.dart';
import '../domain/entities/taxonomy.dart';
import 'data/taxonomy_remote_data_source.dart';
import 'data/taxonomy_repository_impl.dart';
import 'domain/taxonomy_repository.dart';

part 'taxonomy_providers.g.dart';

@Riverpod(keepAlive: true)
TaxonomyRemoteDataSource taxonomyRemoteDataSource(Ref ref) =>
    TaxonomyRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
TaxonomyRepository taxonomyRepository(Ref ref) => TaxonomyRepositoryImpl(
  ref.watch(taxonomyRemoteDataSourceProvider),
  ref.watch(cacheStoreProvider),
);

@riverpod
Future<List<LanguageRef>> taxonomyLanguages(Ref ref) async {
  final Result<List<LanguageRef>> result = await ref
      .watch(taxonomyRepositoryProvider)
      .languages();
  return result.fold(
    (List<LanguageRef> languages) => languages,
    (Object failure) => throw failure,
  );
}

@riverpod
Future<List<GenreRef>> taxonomyGenres(Ref ref) async {
  final Result<List<GenreRef>> result = await ref
      .watch(taxonomyRepositoryProvider)
      .genres();
  return result.fold(
    (List<GenreRef> genres) => genres,
    (Object failure) => throw failure,
  );
}

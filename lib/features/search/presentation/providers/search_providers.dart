/// The search feature's composition root (docs/40 §9). Binds the domain
/// [SearchRepository] to its implementation and exposes the data source + the
/// device-local recents store. The repository is kept alive while the app runs so
/// its single-flight autocomplete cancel-token survives between keystrokes.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/search_recents_store.dart';
import '../../data/datasources/search_remote_data_source.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/repositories/search_repository.dart';

part 'search_providers.g.dart';

@riverpod
SearchRemoteDataSource searchRemoteDataSource(Ref ref) =>
    SearchRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
SearchRecentsStore searchRecentsStore(Ref ref) =>
    SearchRecentsStore(ref.watch(prefsBoxProvider));

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) => SearchRepositoryImpl(
  ref.watch(searchRemoteDataSourceProvider),
  ref.watch(cacheListDataSourceProvider),
  ref.watch(cacheStoreProvider),
);

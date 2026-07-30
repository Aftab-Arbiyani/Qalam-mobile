/// The profile feature's composition root (docs/40 §9). Binds the profile domain
/// repository to its data implementation off the shared `ApiClient` + `CacheStore`,
/// mirroring every other feature's `*_providers.dart`. Consumers (controllers)
/// depend on `profileRepositoryProvider`; tests override it at this boundary.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) =>
    ProfileRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  ref.watch(profileRemoteDataSourceProvider),
  ref.watch(cacheStoreProvider),
);

/// The feed feature's composition root (docs/40 §9). One-line providers bind the
/// domain [FeedRepository] to its data implementation and expose the data sources.
/// Consumers depend on the repository provider (typed as the interface); tests
/// override at any boundary.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/feed_local_data_source.dart';
import '../../data/datasources/feed_remote_data_source.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/repositories/feed_repository.dart';

part 'feed_providers.g.dart';

@riverpod
FeedRemoteDataSource feedRemoteDataSource(Ref ref) =>
    FeedRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
FeedLocalDataSource feedLocalDataSource(Ref ref) =>
    FeedLocalDataSource(ref.watch(cacheStoreProvider));

@riverpod
FeedRepository feedRepository(Ref ref) => FeedRepositoryImpl(
  ref.watch(feedRemoteDataSourceProvider),
  ref.watch(feedLocalDataSourceProvider),
);

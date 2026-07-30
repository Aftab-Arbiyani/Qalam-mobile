/// The analytics module composition root (docs/40 §9). Binds the analytics data
/// source + repository. DI is Riverpod only; there is no duplicate analytics
/// repository anywhere else.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/analytics_remote_data_source.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/repositories/analytics_repository.dart';

part 'analytics_providers.g.dart';

@riverpod
AnalyticsRemoteDataSource analyticsRemoteDataSource(Ref ref) =>
    AnalyticsRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AnalyticsRepository analyticsRepository(Ref ref) => AnalyticsRepositoryImpl(
  ref.watch(analyticsRemoteDataSourceProvider),
  ref.watch(cacheStoreProvider),
);

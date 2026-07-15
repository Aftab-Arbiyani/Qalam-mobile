/// The reading feature's composition root (docs/40 §9). Binds the reading + engagement
/// domain repositories to their data implementations and exposes the data sources.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/engagement_remote_data_source.dart';
import '../../data/datasources/piece_local_data_source.dart';
import '../../data/datasources/piece_remote_data_source.dart';
import '../../data/repositories/engagement_repository_impl.dart';
import '../../data/repositories/reading_repository_impl.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../domain/repositories/reading_repository.dart';

part 'reading_providers.g.dart';

@riverpod
PieceRemoteDataSource pieceRemoteDataSource(Ref ref) =>
    PieceRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
PieceLocalDataSource pieceLocalDataSource(Ref ref) =>
    PieceLocalDataSource(ref.watch(cacheStoreProvider));

@riverpod
EngagementRemoteDataSource engagementRemoteDataSource(Ref ref) =>
    EngagementRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
ReadingRepository readingRepository(Ref ref) => ReadingRepositoryImpl(
  ref.watch(pieceRemoteDataSourceProvider),
  ref.watch(pieceLocalDataSourceProvider),
);

@riverpod
EngagementRepository engagementRepository(Ref ref) =>
    EngagementRepositoryImpl(ref.watch(engagementRemoteDataSourceProvider));

/// The reading feature's composition root (docs/40 §9). Binds the reading domain
/// repository to its data implementation and exposes the piece data sources. The
/// engagement / follow / report mutations now live in the shared social module
/// (`shared/social/social_providers.dart`) — reading consumes them (docs/40 §7.3).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/piece_local_data_source.dart';
import '../../data/datasources/piece_remote_data_source.dart';
import '../../data/repositories/reading_repository_impl.dart';
import '../../domain/repositories/reading_repository.dart';

part 'reading_providers.g.dart';

@riverpod
PieceRemoteDataSource pieceRemoteDataSource(Ref ref) =>
    PieceRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
PieceLocalDataSource pieceLocalDataSource(Ref ref) =>
    PieceLocalDataSource(ref.watch(cacheStoreProvider));

@riverpod
ReadingRepository readingRepository(Ref ref) => ReadingRepositoryImpl(
  ref.watch(pieceRemoteDataSourceProvider),
  ref.watch(pieceLocalDataSourceProvider),
);

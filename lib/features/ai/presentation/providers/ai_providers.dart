/// The AI feature's composition root (AF1, docs/40 §9). Binds the AI repository
/// to its data implementation and exposes the feature-flag state. Kept alive for
/// the app lifetime (the repository is stateless + cross-cutting).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/ai_remote_data_source.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/repositories/ai_repository.dart';

part 'ai_providers.g.dart';

@Riverpod(keepAlive: true)
AiRemoteDataSource aiRemoteDataSource(Ref ref) =>
    AiRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AiRepository aiRepository(Ref ref) =>
    AiRepositoryImpl(ref.watch(aiRemoteDataSourceProvider));

/// The caller's AI feature-flag state (server source of truth for gating).
@riverpod
Future<AiFeatures> aiFeatures(Ref ref) async {
  final Result<AiFeatures> result = await ref.watch(aiRepositoryProvider).features();
  return switch (result) {
    Ok<AiFeatures>(:final AiFeatures value) => value,
    Err<AiFeatures>(:final Failure failure) => throw failure,
  };
}

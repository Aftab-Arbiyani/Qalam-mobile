/// The AI feature's composition root (AF1 + AF2, docs/40 §9). Binds the AI repository
/// to its data implementation and exposes the feature-flag state, usage, and the
/// on-device prompt-library store. Repository + store are kept alive for the app
/// lifetime (stateless + cross-cutting); flag/usage reads are autoDispose.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/ai_remote_data_source.dart';
import '../../data/local/prompt_library_store.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/ai_usage.dart';
import '../../domain/repositories/ai_repository.dart';

part 'ai_providers.g.dart';

@Riverpod(keepAlive: true)
AiRemoteDataSource aiRemoteDataSource(Ref ref) =>
    AiRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AiRepository aiRepository(Ref ref) =>
    AiRepositoryImpl(ref.watch(aiRemoteDataSourceProvider));

/// The on-device Prompt Library store (favourites / custom presets / history).
@Riverpod(keepAlive: true)
PromptLibraryStore promptLibraryStore(Ref ref) =>
    PromptLibraryStore(ref.watch(prefsBoxProvider));

/// The caller's AI feature-flag state (server source of truth for gating).
@riverpod
Future<AiFeatures> aiFeatures(Ref ref) async {
  final Result<AiFeatures> result = await ref.watch(aiRepositoryProvider).features();
  return switch (result) {
    Ok<AiFeatures>(:final AiFeatures value) => value,
    Err<AiFeatures>(:final Failure failure) => throw failure,
  };
}

/// The caller's AI usage (daily/monthly/lifetime + per feature) for the token meter.
@riverpod
Future<AiUsageSummary> aiUsage(Ref ref) async {
  final Result<AiUsageSummary> result = await ref.watch(aiRepositoryProvider).usage();
  return switch (result) {
    Ok<AiUsageSummary>(:final AiUsageSummary value) => value,
    Err<AiUsageSummary>(:final Failure failure) => throw failure,
  };
}

/// The AI feature's composition root (AF1 + AF2, docs/40 §9). Binds the AI repository
/// to its data implementation and exposes the feature-flag state. The repository is
/// kept alive for the app lifetime (stateless + cross-cutting); the flag read is
/// autoDispose.
///
/// **D5** removed two providers. `promptLibraryStore` went with the Prompt Library and
/// the "Keep history" binding it also held; `aiUsage` went with `GET /ai/usage/me`,
/// which B2 deleted — the writer-facing meter is per-feature *allowances* now
/// (`GET /monetization/usage`, M3), not a token count.
///
/// **M2** folded the old `retrieval_providers.dart` away: its search-history and
/// saved-search stores went to `lib/shared/retrieval/` with the rest of retrieval, and
/// the explorer cache — which is Story Map's, not search's — moved here.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/ai_remote_data_source.dart';
import '../../data/local/explorer_cache_store.dart';
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
///
/// ⚠️ This is an AUTHENTICATED read. Nothing on a public surface may watch it: a 401
/// outside `/auth` is terminal to the api client and would end an anonymous reader's
/// session. Since D5 that rules out search and recommendations, which are public.
@riverpod
Future<AiFeatures> aiFeatures(Ref ref) async {
  final Result<AiFeatures> result = await ref
      .watch(aiRepositoryProvider)
      .features();
  return switch (result) {
    Ok<AiFeatures>(:final AiFeatures value) => value,
    Err<AiFeatures>(:final Failure failure) => throw failure,
  };
}

/// Disposable last-viewed Story Map cache (instant / offline render).
@Riverpod(keepAlive: true)
ExplorerCacheStore explorerCacheStore(Ref ref) =>
    ExplorerCacheStore(ref.watch(cacheBoxProvider));

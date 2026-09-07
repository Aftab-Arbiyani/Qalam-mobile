/// Retrieval composition root + server-state providers (docs/40 §6, §9).
///
/// Shared rather than feature-owned, on the same reasoning as `shared/discovery`: the
/// search screen, the discover shelves and the reading page's "More like this" all
/// consume this, and features never import features
/// (`docs/folder-structure.md`). Before **D5** it lived inside `features/ai`, which is
/// where AF4 happened to arrive — not where it belongs.
///
/// **The auth split is enforced here, not left to callers.** [retrievalResults] and
/// [retrievalSuggestions] are public; [recommendations] and the saved-search reads need
/// a session, and firing one without a session is a 401 — which `ApiClient` treats as
/// terminal outside `/auth/*`, ending the reader's session and clearing the caches
/// (`platfrom/docs/48` §3.25). So [recommendations] watches the session and answers
/// empty rather than reaching the network. Callers still gate their own rendering; this
/// is the floor beneath that, because the render check is the one that was forgotten.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../../core/error/failure.dart';
import '../../core/session/session_controller.dart';
import '../../core/session/session_state.dart';
import '../../core/utils/result.dart';
import 'data/retrieval_remote_data_source.dart';
import 'data/retrieval_repository_impl.dart';
import 'data/saved_searches_store.dart';
import 'domain/retrieval.dart';
import 'domain/retrieval_repository.dart';
import 'domain/retrieval_requests.dart';
import 'domain/retrieval_vocab.dart';

part 'retrieval_providers.g.dart';

@Riverpod(keepAlive: true)
RetrievalRemoteDataSource retrievalRemoteDataSource(Ref ref) =>
    RetrievalRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
RetrievalRepository retrievalRepository(Ref ref) =>
    RetrievalRepositoryImpl(ref.watch(retrievalRemoteDataSourceProvider));

/// Device-local mirror of the caller's saved searches.
@Riverpod(keepAlive: true)
SavedSearchesStore savedSearchesStore(Ref ref) =>
    SavedSearchesStore(ref.watch(prefsBoxProvider));

/// Family args for a ranked search (records give value equality = cache key).
typedef RetrievalArgs = ({String query, String? storyId});

/// Family args for suggestions.
typedef SuggestionArgs = ({String prefix, String? storyId});

typedef RecommendationArgs = ({
  RecommendationKind kind,
  String? storyId,
  String? pieceId,
});

/// Ranked, grounded, explainable results for a submitted query. **Public.**
@riverpod
Future<SemanticSearchResponse> retrievalResults(
  Ref ref,
  RetrievalArgs args,
) async {
  final Result<SemanticSearchResponse> result = await ref
      .watch(retrievalRepositoryProvider)
      .search(SemanticSearchRequest(query: args.query, storyId: args.storyId));
  return switch (result) {
    Ok<SemanticSearchResponse>(:final SemanticSearchResponse value) => value,
    Err<SemanticSearchResponse>(:final Failure failure) => throw failure,
  };
}

/// Query suggestions. **Public**, empty for short prefixes, and never throws — a
/// suggestion strip that errors is worse than one that is absent.
@riverpod
Future<List<String>> retrievalSuggestions(Ref ref, SuggestionArgs args) async {
  if (args.prefix.trim().length < 2) return const <String>[];
  final Result<List<String>> result = await ref
      .watch(retrievalRepositoryProvider)
      .suggestions(args.prefix, storyId: args.storyId);
  return switch (result) {
    Ok<List<String>>(:final List<String> value) => value,
    Err<List<String>>() => const <String>[],
  };
}

/// Explainable recommendations for a surface. **Authenticated** — see the library note.
@riverpod
Future<RecommendationResponse> recommendations(
  Ref ref,
  RecommendationArgs args,
) async {
  final AsyncValue<SessionState> session = ref.watch(sessionControllerProvider);
  if (!(session.asData?.value.isAuthenticated ?? false)) {
    // Not an error and not a wall — the caller's own fallback covers it. Reaching the
    // network here would 401 and take the reader's session down with it.
    return RecommendationResponse(
      kind: args.kind.wire,
      items: const <RecommendationItem>[],
      meta: const RetrievalResponseMeta(
        sources: <String>[],
        totalCandidates: 0,
        returned: 0,
        confidence: 0,
        degraded: false,
      ),
    );
  }
  final Result<RecommendationResponse> result = await ref
      .watch(retrievalRepositoryProvider)
      .recommendations(
        RecommendationQuery(
          kind: args.kind,
          storyId: args.storyId,
          pieceId: args.pieceId,
        ),
      );
  return switch (result) {
    Ok<RecommendationResponse>(:final RecommendationResponse value) => value,
    Err<RecommendationResponse>(:final Failure failure) => throw failure,
  };
}

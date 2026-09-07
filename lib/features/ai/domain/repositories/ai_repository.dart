/// The AI feature's domain contract (AF1 + AF2 + AF3). Presentation depends on this,
/// never on the data layer. Unary calls return `Result<T>`; streaming returns a
/// broadcast-free `Stream<…>` whose cancellation (subscription cancel) aborts the
/// underlying request — so presentation never touches Dio.
///
/// **D5 removed the conversation + usage surface** that AF2 had added here. Both were
/// deleted server-side by B2: completions are stateless now, and the writer-facing
/// meter is a per-feature allowance on `GET /monetization/usage`, not a token count on
/// `GET /ai/usage/me`. Ask My Book went with them.
///
/// What is left is the AF1 platform (features + completions), Story Map's two calls,
/// and — until **M2** lifts them into `lib/shared/retrieval/` — the AF4 retrieval
/// reads. Those last ones are on the wrong side of a feature boundary here: search and
/// recommendations are consumed by `features/search` and `features/reading`, and
/// features never import features.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/ai_completion.dart';
import '../entities/ai_feature_flag.dart';
import '../entities/ai_stream_event.dart';
import '../entities/retrieval.dart';
import '../entities/saved_search.dart';
import '../entities/story_graph.dart';
import '../entities/story_map_event.dart';
import '../value_objects/retrieval_requests.dart';

abstract interface class AiRepository {
  /// Which AI features are enabled for the caller. **Authenticated** — never read on
  /// a public surface (a 401 outside `/auth` ends the session).
  Future<Result<AiFeatures>> features();

  /// A buffered completion.
  Future<Result<AiCompletionResult>> complete(AiCompletionRequest request);

  /// A streamed completion. Cancel by cancelling the subscription.
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request);

  // ── AF3 — Story Map ─────────────────────────────────────────────────────────
  /// A structured Story Map view over the knowledge graph.
  Future<Result<ExplorerViewResult>> explorer(String storyId, String view);

  /// Build the whole map for [storyId] in one action: five analyses, each folded into
  /// the graph as it lands, reported as `progress*` → `done | error`. Cancel by
  /// cancelling the subscription — the server stops spending analyses when the client
  /// goes away, and keeps whatever it already folded in.
  Stream<StoryMapEvent> mapStory(
    String storyId, {
    required String content,
    String? storyTitle,
  });

  // ── AF4 — search / saved searches / recommendations (moving out in M2) ───────
  /// Ranked retrieval over a story graph or the library. **Public since D5** — this
  /// is the one call here that must work without a session.
  Future<Result<SemanticSearchResponse>> searchSemantic(
    SemanticSearchRequest request,
  );

  /// Lightweight query suggestions for a short prefix. Public, like the search.
  Future<Result<List<String>>> searchSuggestions(
    String query, {
    String? storyId,
  });

  /// The caller's saved searches (server copy). Authenticated.
  Future<Result<List<SavedSearch>>> listSavedSearches();

  /// Save a search (idempotent by name). Authenticated.
  Future<Result<SavedSearch>> saveSearch({
    required String name,
    required String query,
    String? queryType,
    String? storyId,
  });

  /// Delete a saved search. Authenticated.
  Future<Result<Unit>> deleteSavedSearch(String id);

  /// Explainable recommendations for a surface. Authenticated.
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  );
}

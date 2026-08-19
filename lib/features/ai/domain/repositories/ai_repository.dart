/// The AI feature's domain contract (AF1 + AF2). Presentation depends on this, never
/// on the data layer. Unary calls return `Result<T>`; streaming returns a broadcast-
/// free `Stream<AiStreamEvent>` whose cancellation (subscription cancel) aborts the
/// underlying request — so presentation never touches Dio. AF2 adds the reusable
/// conversation + usage surface (docs/34 §6, §7) that Writing Assistant + Craft Coach
/// share; no feature re-implements conversation storage or token accounting.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../entities/ai_completion.dart';
import '../entities/ai_conversation.dart';
import '../entities/ai_feature_flag.dart';
import '../entities/ai_stream_event.dart';
import '../entities/ai_usage.dart';
import '../entities/ask_answer.dart';
import '../entities/retrieval.dart';
import '../entities/saved_search.dart';
import '../entities/story_graph.dart';
import '../value_objects/retrieval_requests.dart';

abstract interface class AiRepository {
  /// Which AI features are enabled for the caller.
  Future<Result<AiFeatures>> features();

  /// A buffered completion.
  Future<Result<AiCompletionResult>> complete(AiCompletionRequest request);

  /// A streamed completion. Cancel by cancelling the subscription.
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request);

  /// The caller's AI usage across daily/monthly/lifetime windows + per feature.
  Future<Result<AiUsageSummary>> usage();

  // ── Conversations ──────────────────────────────────────────────────────────
  /// The caller's conversations on one shelf, newest first (cursor-paginated).
  /// Omitting [status] takes the route's default, which is `active`.
  Future<Result<CursorPage<AiConversationSummary>>> listConversations({
    String? cursor,
    int? limit,
    AiConversationStatus? status,
  });

  /// Start a new conversation for [feature].
  Future<Result<AiConversationSummary>> createConversation({
    required String feature,
    String? title,
  });

  /// A conversation with its full message history.
  Future<Result<AiConversationDetail>> getConversation(String id);

  /// Rename a conversation.
  Future<Result<AiConversationSummary>> renameConversation(
    String id,
    String title,
  );

  /// Archive/unarchive a conversation.
  Future<Result<AiConversationSummary>> setConversationStatus(
    String id,
    AiConversationStatus status,
  );

  /// Delete a conversation and its messages.
  Future<Result<Unit>> deleteConversation(String id);

  /// Export a conversation as a portable JSON document.
  Future<Result<Json>> exportConversation(String id);

  // ── AF4 — discovery / search / ask / explorer / recommendations ──────────────
  /// Semantic/hybrid search over a story graph or the library.
  Future<Result<SemanticSearchResponse>> searchSemantic(
    SemanticSearchRequest request,
  );

  /// Lightweight query suggestions for a short prefix.
  Future<Result<List<String>>> searchSuggestions(
    String query, {
    String? storyId,
  });

  /// The caller's saved searches (server copy).
  Future<Result<List<SavedSearch>>> listSavedSearches();

  /// Save a search (idempotent by name).
  Future<Result<SavedSearch>> saveSearch({
    required String name,
    required String query,
    String? queryType,
    String? storyId,
  });

  /// Delete a saved search.
  Future<Result<Unit>> deleteSavedSearch(String id);

  /// A buffered grounded answer about a story.
  Future<Result<AskBookAnswer>> ask(AskBookRequest request);

  /// A streamed grounded answer. Cancel by cancelling the subscription.
  Stream<AskStreamEvent> streamAsk(AskBookRequest request);

  /// A structured Story Explorer view over the knowledge graph.
  Future<Result<ExplorerViewResult>> explorer(String storyId, String view);

  /// Explainable recommendations for a surface.
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  );
}

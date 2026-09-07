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
/// **M2 removed the AF4 retrieval reads**, which were on the wrong side of a feature
/// boundary here — search and recommendations are consumed by `features/search`,
/// `features/feed` and `features/reading`, and features never import features. They
/// live in `lib/shared/retrieval/` now. What is left is five methods: the AF1 platform,
/// and Story Map's two calls.
library;

import '../../../../core/utils/result.dart';
import '../entities/ai_completion.dart';
import '../entities/ai_feature_flag.dart';
import '../entities/ai_stream_event.dart';
import '../entities/story_graph.dart';
import '../entities/story_map_event.dart';

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
}

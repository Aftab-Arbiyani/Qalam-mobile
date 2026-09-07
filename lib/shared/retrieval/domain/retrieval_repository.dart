/// The retrieval contract — ranked search, its suggestions, saved searches, and
/// explainable recommendations.
///
/// Six methods, and they are **not all the same kind of call**. The first two are
/// public since B1; the last four need a session. That split is the reason this
/// interface documents it per-method rather than once at the top: a caller that gets it
/// wrong on a public page does not merely fail — the 401 ends the reader's session
/// (`platfrom/docs/48` §3.25).
library;

import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import 'retrieval.dart';
import 'retrieval_requests.dart';
import 'saved_search.dart';

abstract interface class RetrievalRepository {
  /// Ranked, grounded results. **Public** — works with no session.
  Future<Result<SemanticSearchResponse>> search(SemanticSearchRequest request);

  /// Query suggestions for a short prefix. **Public.**
  Future<Result<List<String>>> suggestions(String query, {String? storyId});

  /// The caller's saved searches (server copy). **Authenticated.**
  Future<Result<List<SavedSearch>>> listSavedSearches();

  /// Save a search (idempotent by name). **Authenticated.**
  Future<Result<SavedSearch>> saveSearch({
    required String name,
    required String query,
    String? queryType,
    String? storyId,
  });

  /// Delete a saved search. **Authenticated.**
  Future<Result<Unit>> deleteSavedSearch(String id);

  /// Explainable recommendations for a surface. **Authenticated** — deliberately, and
  /// unchanged by D5: recommendations are personal, so an anonymous reader gets the
  /// tag-search fallback instead (`related_pieces_controller.dart`).
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  );
}

/// Retrieval remote data source — the only place the `/ai/search*`,
/// `/ai/search/saved*` and `/ai/recommendations` endpoints and `ApiClient` are touched.
///
/// The `/ai/*` prefix stays: **D5's rename is user-facing copy only** (decision 10).
/// What changed is who may call these, and it is not uniform — which is the single most
/// important thing about this file:
///
/// - `search` and `suggestions` are **PUBLIC** since B1. An anonymous reader must be
///   able to reach them, and nothing on the search surface may consult
///   `GET /ai/features` to decide, because that read needs a session.
/// - saved searches and recommendations still need one. Firing either without a session
///   is a 401, and a 401 outside `/auth/*` is terminal to `ApiClient` — it ends the
///   session and clears the caches. Web walked into exactly this when it dropped the
///   feature flag that had been *incidentally* keeping those reads off public pages
///   (`platfrom/docs/48` §3.25). Gate them at the REQUEST, not at the render.
library;

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/typedefs.dart';
import '../domain/retrieval.dart';
import '../domain/retrieval_requests.dart';
import '../domain/saved_search.dart';

class RetrievalRemoteDataSource {
  const RetrievalRemoteDataSource(this._api);

  final ApiClient _api;

  // ── Public ──────────────────────────────────────────────────────────────────

  Future<SemanticSearchResponse> search(
    SemanticSearchRequest request, {
    CancelToken? cancelToken,
  }) => _api.post(
    ApiPaths.aiSearch,
    body: request.toJson(),
    decode: SemanticSearchResponse.fromJson,
    cancelToken: cancelToken,
  );

  Future<List<String>> suggestions(
    String query, {
    String? storyId,
    CancelToken? cancelToken,
  }) async {
    final Json result = await _api.get(
      ApiPaths.aiSearchSuggestions,
      query: <String, dynamic>{'q': query, 'storyId': storyId},
      decode: (Json json) => json,
      cancelToken: cancelToken,
      deduplicate: false,
    );
    return (result['suggestions'] as List?)?.whereType<String>().toList() ??
        const <String>[];
  }

  // ── Authenticated ───────────────────────────────────────────────────────────

  Future<List<SavedSearch>> listSavedSearches({CancelToken? cancelToken}) =>
      _api.getList(
        ApiPaths.aiSearchSaved,
        decodeItem: SavedSearch.fromJson,
        cancelToken: cancelToken,
      );

  Future<SavedSearch> saveSearch(Json body, {CancelToken? cancelToken}) =>
      _api.post(
        ApiPaths.aiSearchSaved,
        body: body,
        decode: SavedSearch.fromJson,
        cancelToken: cancelToken,
      );

  Future<void> deleteSavedSearch(String id) =>
      _api.delete(ApiPaths.aiSearchSavedById(id));

  Future<RecommendationResponse> recommendations(
    RecommendationQuery query, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.aiRecommendations,
    query: query.toQuery(),
    decode: RecommendationResponse.fromJson,
    cancelToken: cancelToken,
  );
}

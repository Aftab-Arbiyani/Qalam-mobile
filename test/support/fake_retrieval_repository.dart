/// A configurable in-memory [RetrievalRepository].
///
/// **New at M2**, when D5 lifted retrieval out of the AI feature into
/// `lib/shared/retrieval/`. It records what it was asked for, which is what lets a test
/// assert the thing that actually matters about this contract: **which calls happen at
/// all**. Two of the six are public and four need a session, and a test that only
/// checks rendering cannot tell the difference — that is precisely how web shipped an
/// authenticated read onto a public page (`platfrom/docs/48` §3.25).
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/shared/retrieval/domain/retrieval.dart';
import 'package:qalam_mobile/shared/retrieval/domain/retrieval_repository.dart';
import 'package:qalam_mobile/shared/retrieval/domain/retrieval_requests.dart';
import 'package:qalam_mobile/shared/retrieval/domain/saved_search.dart';

const RetrievalResponseMeta _emptyMeta = RetrievalResponseMeta(
  sources: <String>[],
  totalCandidates: 0,
  returned: 0,
  confidence: 0,
  degraded: false,
);

class FakeRetrievalRepository implements RetrievalRepository {
  FakeRetrievalRepository({
    SemanticSearchResponse? search,
    List<String>? suggestions,
    List<SavedSearch>? savedSearches,
    RecommendationResponse? recommendations,
    this.failure,
    this.recommendationsFailure,
  }) : _search = search,
       _suggestions = suggestions ?? const <String>[],
       _savedSearches = savedSearches ?? const <SavedSearch>[],
       _recommendations = recommendations;

  final SemanticSearchResponse? _search;
  final List<String> _suggestions;
  final List<SavedSearch> _savedSearches;
  final RecommendationResponse? _recommendations;

  /// When set, every call fails with this failure.
  final Failure? failure;

  /// When set, ONLY [recommendations] fails — so a test can fail the recommender
  /// specifically while everything else succeeds.
  final Failure? recommendationsFailure;

  // ── What was asked for. The authenticated calls are counted rather than merely
  // recorded, because "was this called at all" is the assertion that matters for them.
  SemanticSearchRequest? lastSearchRequest;
  RecommendationQuery? lastRecommendationQuery;
  final List<String> savedSearchNames = <String>[];
  int searchCalls = 0;
  int suggestionCalls = 0;
  int listSavedCalls = 0;
  int recommendationCalls = 0;

  @override
  Future<Result<SemanticSearchResponse>> search(
    SemanticSearchRequest request,
  ) async {
    searchCalls++;
    lastSearchRequest = request;
    if (failure != null) return Err<SemanticSearchResponse>(failure!);
    return Ok<SemanticSearchResponse>(
      _search ??
          SemanticSearchResponse(
            query: request.query,
            intent: 'search',
            queryType: 'natural_language',
            results: const <SearchResultItem>[],
            evidence: const <RetrievalEvidence>[],
            meta: _emptyMeta,
          ),
    );
  }

  @override
  Future<Result<List<String>>> suggestions(
    String query, {
    String? storyId,
  }) async {
    suggestionCalls++;
    return failure != null
        ? Err<List<String>>(failure!)
        : Ok<List<String>>(_suggestions);
  }

  @override
  Future<Result<List<SavedSearch>>> listSavedSearches() async {
    listSavedCalls++;
    return failure != null
        ? Err<List<SavedSearch>>(failure!)
        : Ok<List<SavedSearch>>(_savedSearches);
  }

  @override
  Future<Result<SavedSearch>> saveSearch({
    required String name,
    required String query,
    String? queryType,
    String? storyId,
  }) async {
    savedSearchNames.add(name);
    if (failure != null) return Err<SavedSearch>(failure!);
    return Ok<SavedSearch>(
      SavedSearch(
        id: 'ss-$name',
        name: name,
        query: query,
        queryType: queryType,
        storyId: storyId,
        createdAt: DateTime(2026),
      ),
    );
  }

  @override
  Future<Result<Unit>> deleteSavedSearch(String id) async =>
      failure != null ? Err<Unit>(failure!) : const Ok<Unit>(unit);

  @override
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  ) async {
    recommendationCalls++;
    lastRecommendationQuery = query;
    final Failure? effective = recommendationsFailure ?? failure;
    if (effective != null) return Err<RecommendationResponse>(effective);
    return Ok<RecommendationResponse>(
      _recommendations ??
          RecommendationResponse(
            kind: query.kind.wire,
            items: const <RecommendationItem>[],
            meta: _emptyMeta,
          ),
    );
  }
}

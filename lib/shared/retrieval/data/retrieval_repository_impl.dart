/// Retrieval repository implementation. Wraps remote calls in [guardResult] /
/// [guardUnit] (ApiException → Failure); holds no policy of its own.
library;

import '../../../core/error/result_guard.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../domain/retrieval.dart';
import '../domain/retrieval_repository.dart';
import '../domain/retrieval_requests.dart';
import '../domain/saved_search.dart';
import 'retrieval_remote_data_source.dart';

class RetrievalRepositoryImpl implements RetrievalRepository {
  const RetrievalRepositoryImpl(this._remote);

  final RetrievalRemoteDataSource _remote;

  @override
  Future<Result<SemanticSearchResponse>> search(
    SemanticSearchRequest request,
  ) => guardResult(() => _remote.search(request));

  @override
  Future<Result<List<String>>> suggestions(String query, {String? storyId}) =>
      guardResult(() => _remote.suggestions(query, storyId: storyId));

  @override
  Future<Result<List<SavedSearch>>> listSavedSearches() =>
      guardResult(_remote.listSavedSearches);

  @override
  Future<Result<SavedSearch>> saveSearch({
    required String name,
    required String query,
    String? queryType,
    String? storyId,
  }) => guardResult(
    () => _remote.saveSearch(<String, dynamic>{
      'name': name,
      'query': query,
      'queryType': ?queryType,
      'storyId': ?storyId,
    }),
  );

  @override
  Future<Result<Unit>> deleteSavedSearch(String id) =>
      guardUnit(() => _remote.deleteSavedSearch(id));

  @override
  Future<Result<RecommendationResponse>> recommendations(
    RecommendationQuery query,
  ) => guardResult(() => _remote.recommendations(query));
}

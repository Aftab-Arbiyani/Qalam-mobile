/// Responses repository (docs/40 §16, §23). The list delegates to the shared
/// [loadCachedPage] engine (page-1 cached for offline + stale fallback); create is
/// a guarded mutation returning the new draft piece id.
library;

import '../../../core/error/api_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/storage/cache_policy.dart';
import '../../../core/utils/result.dart';
import '../../data/cache_list_data_source.dart';
import '../../data/cached_page_loader.dart';
import '../../domain/error_codes.dart';
import '../../pagination/cached_page.dart';
import '../domain/entities/response_item.dart';
import '../domain/response_repository.dart';
import 'response_remote_data_source.dart';

class ResponseRepositoryImpl implements ResponseRepository {
  ResponseRepositoryImpl(this._remote, this._cache);

  final ResponseRemoteDataSource _remote;
  final CacheListDataSource _cache;

  @override
  Future<Result<CachedPage<ResponseItem>>> listResponses(
    String pieceId, {
    String? cursor,
  }) => loadCachedPage<ResponseItem>(
    cache: _cache,
    cacheKey: 'responses:piece:$pieceId',
    cursor: cursor,
    fetch: (String? c) => _remote.listResponses(pieceId, cursor: c),
    toJson: (ResponseItem x) => x.toJson(),
    fromJson: ResponseItem.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<String>> createResponse(
    String pieceId, {
    String? title,
    required String languageCode,
  }) async {
    try {
      final String id = await _remote.createResponse(
        pieceId,
        title: title,
        languageCode: languageCode,
      );
      return Ok<String>(id);
    } on ApiException catch (e) {
      return Err<String>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<String>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }
}

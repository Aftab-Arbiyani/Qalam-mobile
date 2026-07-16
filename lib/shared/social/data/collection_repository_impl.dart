/// Collections repository (docs/40 §16, §23). Lists delegate to the shared
/// [loadCachedPage] engine (page-1 cached for offline + stale fallback); reads of
/// a single collection and all mutations are guarded. After a mutation the
/// `collections:mine` cache is evicted so the list reloads fresh.
library;

import '../../../core/error/api_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/storage/cache_policy.dart';
import '../../../core/storage/cache_store.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../../data/cache_list_data_source.dart';
import '../../data/cached_page_loader.dart';
import '../../domain/enums.dart';
import '../../domain/error_codes.dart';
import '../../pagination/cached_page.dart';
import '../domain/collection_repository.dart';
import '../domain/entities/collection.dart';
import 'collection_remote_data_source.dart';

/// The cache key for the owner's collections list — evicted on any mutation.
const String kCollectionsCacheKey = 'collections:mine';

class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._remote, this._cache, this._store);

  final CollectionRemoteDataSource _remote;
  final CacheListDataSource _cache;
  final CacheStore _store;

  @override
  Future<Result<CachedPage<Collection>>> myCollections({String? cursor}) =>
      loadCachedPage<Collection>(
        cache: _cache,
        cacheKey: kCollectionsCacheKey,
        cursor: cursor,
        fetch: (String? c) => _remote.myCollections(cursor: c),
        toJson: (Collection x) => x.toJson(),
        fromJson: Collection.fromJson,
        tier: CacheTier.content,
      );

  @override
  Future<Result<Collection>> getCollection(String id) =>
      _guard(() => _remote.getCollection(id));

  @override
  Future<Result<CachedPage<CollectionPieceItem>>> collectionPieces(
    String id, {
    String? cursor,
  }) => loadCachedPage<CollectionPieceItem>(
    cache: _cache,
    cacheKey: 'collections:pieces:$id',
    cursor: cursor,
    fetch: (String? c) => _remote.collectionPieces(id, cursor: c),
    toJson: (CollectionPieceItem x) => x.toJson(),
    fromJson: CollectionPieceItem.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<Collection>> create({
    required String title,
    String? description,
    Visibility? visibility,
  }) => _mutate(
    () => _remote.create(
      title: title,
      description: description,
      visibility: visibility,
    ),
  );

  @override
  Future<Result<Collection>> update(
    String id, {
    String? title,
    String? description,
    Visibility? visibility,
  }) => _mutate(
    () => _remote.update(
      id,
      title: title,
      description: description,
      visibility: visibility,
    ),
  );

  @override
  Future<Result<Unit>> delete(String id) => _mutate<Unit>(() async {
    await _remote.delete(id);
    return unit;
  });

  @override
  Future<Result<Unit>> addPiece(
    String collectionId,
    String pieceId, {
    String? note,
  }) => _mutate<Unit>(() async {
    await _remote.addPiece(collectionId, pieceId, note: note);
    await _store.evict('collections:pieces:$collectionId');
    return unit;
  });

  @override
  Future<Result<Unit>> removePiece(String collectionId, String pieceId) =>
      _mutate<Unit>(() async {
        await _remote.removePiece(collectionId, pieceId);
        await _store.evict('collections:pieces:$collectionId');
        return unit;
      });

  /// Run a mutation, then evict the collections list cache so it reloads fresh.
  Future<Result<T>> _mutate<T>(Future<T> Function() run) async {
    final Result<T> result = await _guard(run);
    if (result.isOk) await _store.evict(kCollectionsCacheKey);
    return result;
  }

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok<T>(await run());
    } on ApiException catch (e) {
      return Err<T>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<T>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }
}

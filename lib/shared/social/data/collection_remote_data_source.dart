/// Collections remote data source (docs/40 §17.1) — the only place collection
/// reads/mutations touch the wire. Lists return cursor pages; create/update
/// return the [Collection]; add/remove piece and delete are 2xx with no body.
library;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/typedefs.dart';
import '../../api/api_envelope.dart';
import '../../domain/enums.dart';
import '../domain/entities/collection.dart';
import 'mappers/social_mappers.dart';

class CollectionRemoteDataSource {
  CollectionRemoteDataSource(this._api);

  final ApiClient _api;

  static const int _limit = 20;

  Future<CursorPage<Collection>> myCollections({String? cursor}) =>
      _api.getPage<Collection>(
        ApiPaths.collections,
        query: _page(cursor),
        decodeItem: collectionFromJson,
      );

  Future<Collection> getCollection(String id) =>
      _api.get<Collection>(ApiPaths.collection(id), decode: collectionFromJson);

  Future<CursorPage<CollectionPieceItem>> collectionPieces(
    String id, {
    String? cursor,
  }) => _api.getPage<CollectionPieceItem>(
    ApiPaths.collectionPieces(id),
    query: _page(cursor),
    decodeItem: collectionPieceItemFromJson,
  );

  Future<Collection> create({
    required String title,
    String? description,
    Visibility? visibility,
  }) => _api.post<Collection>(
    ApiPaths.collections,
    body: <String, Object?>{
      'title': title,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      if (visibility != null) 'visibility': visibility.wire,
    },
    decode: collectionFromJson,
  );

  Future<Collection> update(
    String id, {
    String? title,
    String? description,
    Visibility? visibility,
  }) => _api.patch<Collection>(
    ApiPaths.collection(id),
    body: <String, Object?>{
      'title': ?title,
      'description': ?description,
      if (visibility != null) 'visibility': visibility.wire,
    },
    decode: collectionFromJson,
  );

  Future<void> delete(String id) => _api.delete(ApiPaths.collection(id));

  Future<void> addPiece(String collectionId, String pieceId, {String? note}) =>
      _api.postVoid(
        ApiPaths.collectionPieces(collectionId),
        body: <String, Object?>{
          'pieceId': pieceId,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );

  Future<void> removePiece(String collectionId, String pieceId) =>
      _api.delete(ApiPaths.collectionPiece(collectionId, pieceId));

  Json _page(String? cursor) => <String, dynamic>{
    'cursor': ?cursor,
    'limit': _limit,
  };
}

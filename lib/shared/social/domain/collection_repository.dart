/// The collections boundary (docs/40 §16, E7) — the owner's collections and their
/// pieces (cursor-paginated, cache-then-network for offline), plus create /
/// rename / delete and add / remove piece. Owner-only; the default "Favorites"
/// collection cannot be renamed or deleted (enforced server-side). Returns
/// domain [Result]s.
library;

import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../../domain/enums.dart';
import '../../pagination/cached_page.dart';
import 'entities/collection.dart';

abstract interface class CollectionRepository {
  Future<Result<CachedPage<Collection>>> myCollections({String? cursor});

  Future<Result<Collection>> getCollection(String id);

  Future<Result<CachedPage<CollectionPieceItem>>> collectionPieces(
    String id, {
    String? cursor,
  });

  Future<Result<Collection>> create({
    required String title,
    String? description,
    Visibility? visibility,
  });

  Future<Result<Collection>> update(
    String id, {
    String? title,
    String? description,
    Visibility? visibility,
  });

  Future<Result<Unit>> delete(String id);

  Future<Result<Unit>> addPiece(
    String collectionId,
    String pieceId, {
    String? note,
  });

  Future<Result<Unit>> removePiece(String collectionId, String pieceId);
}

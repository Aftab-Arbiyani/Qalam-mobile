/// The responses boundary (docs/40 §16, E7) — the list of responses to a piece
/// (cursor-paginated, cache-then-network) and creating a response. A response IS
/// a piece: [createResponse] posts a linked DRAFT and returns its id, which the
/// caller opens in the editor (owned by the writing feature, reached by route).
/// Returns domain [Result]s.
library;

import '../../../core/utils/result.dart';
import '../../pagination/cached_page.dart';
import 'entities/response_item.dart';

abstract interface class ResponseRepository {
  Future<Result<CachedPage<ResponseItem>>> listResponses(
    String pieceId, {
    String? cursor,
  });

  /// Create a response draft linked to [pieceId]; returns the new draft piece id.
  Future<Result<String>> createResponse(
    String pieceId, {
    String? title,
    required String languageCode,
  });
}

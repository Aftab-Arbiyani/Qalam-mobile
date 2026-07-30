/// Responses remote data source (docs/40 §17.1). The list is a cursor page of
/// [ResponseItem]; create posts a `CreatePieceDto` to the responses endpoint and
/// returns the new draft piece's id.
library;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/json_read.dart';
import '../../../core/utils/typedefs.dart';
import '../../api/api_envelope.dart';
import '../domain/entities/response_item.dart';
import 'mappers/social_mappers.dart';

class ResponseRemoteDataSource {
  ResponseRemoteDataSource(this._api);

  final ApiClient _api;

  static const int _limit = 20;

  Future<CursorPage<ResponseItem>> listResponses(
    String pieceId, {
    String? cursor,
  }) => _api.getPage<ResponseItem>(
    ApiPaths.pieceResponses(pieceId),
    query: <String, dynamic>{'cursor': ?cursor, 'limit': _limit},
    decodeItem: responseItemFromJson,
  );

  Future<String> createResponse(
    String pieceId, {
    String? title,
    required String languageCode,
  }) => _api.post<String>(
    ApiPaths.pieceResponses(pieceId),
    body: <String, Object?>{
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      'languageCode': languageCode,
    },
    decode: (Json j) => asString(j['id']),
  );
}

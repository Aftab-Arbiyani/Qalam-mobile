/// Editor taxonomy remote source (docs/40 §17.1). Fetches the language + genre
/// option lists for the metadata form from the frozen discovery endpoints
/// (`GET /discover/languages|genres`) — the contract-bound source since `v1` has no
/// dedicated "list taxonomy" endpoint. `v1` taxonomy is a small fixed set, so one
/// max-size page is fetched (documented limitation, docs/40 §45).
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';

class EditorTaxonomyRemoteDataSource {
  EditorTaxonomyRemoteDataSource(this._api);

  final ApiClient _api;

  /// Cover the whole fixed taxonomy set in one page (max cursor page size).
  static const int _limit = 50;

  Future<List<LanguageRef>> languages() => _api.getList<LanguageRef>(
    ApiPaths.discoverLanguages,
    query: <String, Object?>{'limit': _limit},
    decodeItem: _language,
  );

  Future<List<GenreRef>> genres() => _api.getList<GenreRef>(
    ApiPaths.discoverGenres,
    query: <String, Object?>{'limit': _limit},
    decodeItem: _genre,
  );

  static LanguageRef _language(Json json) => LanguageRef(
    code: asString(json['code']),
    nativeName: asString(json['nativeName']),
    direction: TextDirectionKind.fromWire(asStringOrNull(json['direction'])),
  );

  static GenreRef _genre(Json json) =>
      GenreRef(slug: asString(json['slug']), name: asString(json['name']));
}

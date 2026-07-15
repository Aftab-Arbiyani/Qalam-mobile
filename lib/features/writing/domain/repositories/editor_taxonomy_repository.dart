/// The editor's taxonomy boundary (M4). Supplies the language and genre option
/// lists the metadata form needs (`languageCode` is required by the API; `genreSlug`
/// is required to publish). Sourced from the frozen `v1` discovery endpoints
/// (`GET /discover/languages`, `GET /discover/genres`) — there is no dedicated
/// "list all taxonomy" endpoint in `v1`, so discovery is the contract-bound source
/// (a documented gap, docs/40 §45). Cache-then-network with offline fallback.
library;

import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/taxonomy.dart';

abstract interface class EditorTaxonomyRepository {
  /// Content languages a piece can be written in (RTL-aware via [LanguageRef]).
  Future<Result<List<LanguageRef>>> languages();

  /// Genres a piece can be filed under.
  Future<Result<List<GenreRef>>> genres();
}

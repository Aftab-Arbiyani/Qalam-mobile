/// The shared taxonomy boundary (docs/40 §16). Supplies the language and genre
/// option lists that forms across the app need — the writing metadata form
/// (`languageCode` required to publish, `genreSlug` to file a piece) and the
/// profile editor (default language + up to five genres). Sourced from the frozen
/// `v1` discovery endpoints (`GET /discover/languages`, `GET /discover/genres`) —
/// there is no dedicated "list all taxonomy" endpoint in `v1`, so discovery is the
/// contract-bound source (a documented gap, docs/40 §45). Cache-then-network with
/// offline fallback.
///
/// Promoted from `features/writing/` to `shared/` once a second feature (profile
/// editing) needed the same lists — features never import features, so the single
/// source of truth lives here.
library;

import '../../../core/utils/result.dart';
import '../../domain/entities/taxonomy.dart';

abstract interface class TaxonomyRepository {
  /// Content languages a piece can be written in / a profile can default to
  /// (RTL-aware via [LanguageRef]).
  Future<Result<List<LanguageRef>>> languages();

  /// Genres a piece can be filed under / a profile can list.
  Future<Result<List<GenreRef>>> genres();
}

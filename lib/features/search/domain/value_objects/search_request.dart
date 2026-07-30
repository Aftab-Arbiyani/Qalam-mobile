/// A concrete, submitted search (docs/40 §8.1 "URL"-state) — the normalized
/// query, the scope, and the active filters. Used as the Riverpod family key for
/// the per-type results controllers and as the cache-key component, so it has
/// value equality. Distinct from the live text in the search field: a request is
/// only formed when the user submits, taps a suggestion, or taps a recent search.
library;

import '../../../../shared/domain/enums.dart';
import 'search_filters.dart';

class SearchRequest {
  const SearchRequest({
    required this.query,
    this.type = SearchType.all,
    this.filters = SearchFilters.none,
  });

  final String query;
  final SearchType type;
  final SearchFilters filters;

  bool get isEmpty => query.trim().isEmpty;

  /// A stable cache/identity string. Filters only affect piece/writer results,
  /// but including their signature everywhere keeps the key rule uniform.
  String get signature => '${type.wire}:${query.trim().toLowerCase()}:${filters.signature}';

  SearchRequest withType(SearchType next) =>
      SearchRequest(query: query, type: next, filters: filters);

  @override
  bool operator ==(Object other) =>
      other is SearchRequest && other.signature == signature;

  @override
  int get hashCode => signature.hashCode;
}

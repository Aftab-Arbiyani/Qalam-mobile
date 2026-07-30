/// One recent search (docs/40 E8). A signed-in user's searches are recorded
/// server-side automatically (`GET /search/recent` lists them, newest first) and
/// mirrored into device-local storage so the history is available offline and to
/// anonymous browsers too (docs/40 §23). [serverId] is present only for entries
/// that came from the server — it is what `DELETE /search/recent/:id` takes.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/enums.dart';

part 'recent_search.freezed.dart';
part 'recent_search.g.dart';

@freezed
abstract class RecentSearch with _$RecentSearch {
  const RecentSearch._();

  const factory RecentSearch({
    required String query,
    @Default(SearchType.all) SearchType searchType,
    required DateTime searchedAt,
    String? serverId,
  }) = _RecentSearch;

  factory RecentSearch.fromJson(Map<String, dynamic> json) =>
      _$RecentSearchFromJson(json);

  /// The dedup key — recents are unique by normalized query + scope.
  String get key => '${searchType.wire}:${query.toLowerCase().trim()}';
}

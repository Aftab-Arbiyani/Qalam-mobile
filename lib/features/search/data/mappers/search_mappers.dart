/// Wire → entity mappers for the search feature (docs/40 §18). The only code that
/// knows the `GlobalSearchResultDto` / `AutocompleteResultDto` /
/// `TrendingSearchesDto` / `RecentSearchDto` wire shapes. Reuses the shared
/// read-model mappers (piece / writer / trend) so a result maps identically to a
/// feed card. Pure, total, tolerant — a missing/typed-wrong field coerces to a
/// default, never a throw (docs/40 §18.2).
library;

import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/entity_mappers.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/autocomplete_result.dart';
import '../../domain/entities/global_search_result.dart';
import '../../domain/entities/recent_search.dart';
import '../../domain/entities/trending_searches.dart';

GlobalSearchResult globalSearchFromJson(Json json) => GlobalSearchResult(
  writers: asMapList(json['writers']).map(writerSummaryFromJson).toList(),
  pieces: asMapList(json['pieces']).map(pieceSummaryFromJson).toList(),
  tags: asMapList(json['tags']).map(trendingTagFromJson).toList(),
  genres: asMapList(json['genres']).map(trendingGenreFromJson).toList(),
  languages: asMapList(
    json['languages'],
  ).map(trendingLanguageFromJson).toList(),
);

AutocompleteResult autocompleteFromJson(Json json) => AutocompleteResult(
  writers: asMapList(json['writers'])
      .map(
        (Json w) => WriterSuggestion(
          username: asString(w['username']),
          penName: asStringOrNull(w['penName']),
          avatarKey: asStringOrNull(w['avatarKey']),
        ),
      )
      .toList(),
  tags: asMapList(json['tags'])
      .map(
        (Json t) =>
            TagSuggestion(slug: asString(t['slug']), name: asString(t['name'])),
      )
      .toList(),
  genres: asMapList(json['genres'])
      .map(
        (Json g) => GenreSuggestion(
          slug: asString(g['slug']),
          name: asString(g['name']),
        ),
      )
      .toList(),
  pieces: asMapList(json['pieces'])
      .map(
        (Json p) => PieceSuggestion(
          slug: asStringOrNull(p['slug']),
          title: asString(p['title']),
        ),
      )
      .toList(),
);

TrendingSearches trendingSearchesFromJson(Json json) => TrendingSearches(
  keywords: asMapList(json['keywords'])
      .map(
        (Json k) => TrendingKeyword(
          keyword: asString(k['keyword']),
          searchCount: asInt(k['searchCount']),
        ),
      )
      .toList(),
  tags: asMapList(json['tags']).map(trendingTagFromJson).toList(),
  genres: asMapList(json['genres']).map(trendingGenreFromJson).toList(),
  writers: asMapList(json['writers']).map(writerSummaryFromJson).toList(),
);

RecentSearch recentSearchFromJson(Json json) => RecentSearch(
  serverId: asStringOrNull(json['id']),
  query: asString(json['query']),
  searchType: SearchType.fromWire(asStringOrNull(json['searchType'])),
  searchedAt:
      asUtcDateOrNull(json['searchedAt']) ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
);

import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/features/search/data/mappers/search_mappers.dart';
import 'package:umberleaf_mobile/features/search/domain/entities/autocomplete_result.dart';
import 'package:umberleaf_mobile/features/search/domain/entities/recent_search.dart';
import 'package:umberleaf_mobile/features/search/domain/entities/trending_searches.dart';
import 'package:umberleaf_mobile/shared/domain/enums.dart';

void main() {
  // `globalSearchFromJson` was pinned here. **D5** removed the grouped `GET /search`
  // preview it decoded — the "All" tab runs the ranked retrieval engine now — so the
  // wire shape it mapped has no caller on this client.

  group('autocompleteFromJson', () {
    test('maps suggestions per group', () {
      final AutocompleteResult r = autocompleteFromJson(<String, dynamic>{
        'writers': <dynamic>[
          <String, dynamic>{'username': 'meera_k', 'penName': 'Meera'},
        ],
        'tags': <dynamic>[
          <String, dynamic>{'slug': 'barish', 'name': 'بارش'},
        ],
        'genres': <dynamic>[
          <String, dynamic>{'slug': 'ghazal', 'name': 'Ghazal'},
        ],
        'pieces': <dynamic>[
          <String, dynamic>{'slug': 'barish', 'title': 'Barish'},
        ],
      });
      expect(r.length, 4);
      expect(r.writers.single.label, 'Meera');
    });
  });

  group('trendingSearchesFromJson', () {
    test('maps keywords + tags + genres + writers', () {
      final TrendingSearches t = trendingSearchesFromJson(<String, dynamic>{
        'keywords': <dynamic>[
          <String, dynamic>{'keyword': 'barish', 'searchCount': 42},
        ],
        'tags': <dynamic>[
          <String, dynamic>{'slug': 'ishq', 'name': 'ishq', 'pieceCount': 3},
        ],
        'genres': <dynamic>[
          <String, dynamic>{'slug': 'nazm', 'name': 'Nazm', 'pieceCount': 7},
        ],
        'writers': <dynamic>[
          <String, dynamic>{'username': 'a', 'followersCount': 100},
        ],
      });
      expect(t.keywords.single.keyword, 'barish');
      expect(t.keywords.single.searchCount, 42);
      expect(t.writers.single.followersCount, 100);
    });
  });

  group('recentSearchFromJson', () {
    test('maps a server recent with its id + scope', () {
      final RecentSearch r = recentSearchFromJson(<String, dynamic>{
        'id': 'r1',
        'query': 'barish',
        'searchType': 'pieces',
        'searchedAt': '2026-07-16T10:00:00.000Z',
      });
      expect(r.serverId, 'r1');
      expect(r.searchType, SearchType.pieces);
      expect(r.key, 'pieces:barish');
    });
  });
}

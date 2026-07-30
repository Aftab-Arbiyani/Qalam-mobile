import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/search/data/mappers/search_mappers.dart';
import 'package:qalam_mobile/features/search/domain/entities/autocomplete_result.dart';
import 'package:qalam_mobile/features/search/domain/entities/global_search_result.dart';
import 'package:qalam_mobile/features/search/domain/entities/recent_search.dart';
import 'package:qalam_mobile/features/search/domain/entities/trending_searches.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  group('globalSearchFromJson', () {
    test('maps every group and tolerates a private-writer teaser', () {
      final GlobalSearchResult r = globalSearchFromJson(<String, dynamic>{
        'writers': <dynamic>[
          <String, dynamic>{
            'username': 'meera_k',
            'penName': 'Meera',
            'isPrivate': true,
            'followersCount': 12,
            'rank': 0.9,
          },
        ],
        'pieces': <dynamic>[
          <String, dynamic>{
            'id': 'p1',
            'title': 'Barish',
            'author': <String, dynamic>{'username': 'meera_k'},
            'language': <String, dynamic>{'code': 'ur', 'direction': 'rtl'},
            'rank': 0.8,
          },
        ],
        'tags': <dynamic>[
          <String, dynamic>{'slug': 'barish', 'name': 'بارش', 'pieceCount': 5},
        ],
        'genres': <dynamic>[
          <String, dynamic>{'slug': 'ghazal', 'name': 'Ghazal', 'pieceCount': 9},
        ],
        'languages': <dynamic>[
          <String, dynamic>{
            'code': 'ur',
            'nativeName': 'اردو',
            'direction': 'rtl',
            'pieceCount': 30,
          },
        ],
      });
      expect(r.isEmpty, isFalse);
      expect(r.writers.single.isPrivate, isTrue);
      expect(r.pieces.single.language.direction, TextDirectionKind.rtl);
      expect(r.tags.single.pieceCount, 5);
      expect(r.genres.single.name, 'Ghazal');
      expect(r.languages.single.nativeName, 'اردو');
    });

    test('missing groups coerce to empty (never throws)', () {
      final GlobalSearchResult r = globalSearchFromJson(<String, dynamic>{});
      expect(r.isEmpty, isTrue);
    });
  });

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

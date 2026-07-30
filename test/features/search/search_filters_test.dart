import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/search/domain/value_objects/search_filters.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  group('SearchFilters', () {
    test('none is empty and defaults to relevance', () {
      expect(SearchFilters.none.isEmpty, isTrue);
      expect(SearchFilters.none.activeCount, 0);
      expect(SearchFilters.none.sort, SearchSort.relevance);
    });

    test('activeCount counts each active dimension once', () {
      const SearchFilters f = SearchFilters(
        languages: <String>['ur', 'hi'],
        genres: <String>['ghazal'],
        tag: 'barish',
        minReadingTimeSeconds: 300,
        sort: SearchSort.latest,
      );
      // languages + genres + tag + reading-time band + non-default sort = 5.
      expect(f.activeCount, 5);
      expect(f.isEmpty, isFalse);
    });

    test('toPieceParams omits nulls, comma-lists multi values, always sends sort', () {
      const SearchFilters f = SearchFilters(
        languages: <String>['ur', 'hi'],
        genres: <String>['ghazal', 'nazm'],
        tag: 'barish',
        minReadingTimeSeconds: 60,
        maxReadingTimeSeconds: 900,
        sort: SearchSort.trending,
      );
      final params = f.toPieceParams();
      expect(params['language'], <String>['ur', 'hi']);
      expect(params['genre'], <String>['ghazal', 'nazm']);
      expect(params['tag'], 'barish');
      expect(params['minReadingTime'], 60);
      expect(params['maxReadingTime'], 900);
      expect(params['sort'], 'trending');
      expect(params.containsKey('dateFrom'), isFalse);
    });

    test('toWriterParams uses only the first language + genre', () {
      const SearchFilters f = SearchFilters(
        languages: <String>['ur', 'hi'],
        genres: <String>['ghazal', 'nazm'],
        tag: 'ignored',
      );
      final params = f.toWriterParams();
      expect(params['language'], 'ur');
      expect(params['genre'], 'ghazal');
      expect(params.containsKey('tag'), isFalse);
    });

    test('signature is order-independent → equal filters compare equal', () {
      const SearchFilters a = SearchFilters(
        languages: <String>['ur', 'hi'],
        genres: <String>['nazm', 'ghazal'],
      );
      const SearchFilters b = SearchFilters(
        languages: <String>['hi', 'ur'],
        genres: <String>['ghazal', 'nazm'],
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toJson → fromJson round-trips', () {
      final SearchFilters f = SearchFilters(
        languages: const <String>['ur'],
        genres: const <String>['ghazal'],
        tag: 'barish',
        dateFrom: DateTime.utc(2026),
        minReadingTimeSeconds: 300,
        sort: SearchSort.mostClapped,
      );
      final SearchFilters restored = SearchFilters.fromJson(f.toJson());
      expect(restored, equals(f));
      expect(restored.sort, SearchSort.mostClapped);
      expect(restored.dateFrom, DateTime.utc(2026));
    });

    test('copyWith can clear a nullable field via explicit null', () {
      const SearchFilters f = SearchFilters(tag: 'barish');
      expect(f.copyWith(tag: null).tag, isNull);
      // Omitting tag keeps it.
      expect(f.copyWith(sort: SearchSort.latest).tag, 'barish');
    });
  });
}

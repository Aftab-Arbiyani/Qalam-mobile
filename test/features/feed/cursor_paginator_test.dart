import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/pagination/cached_page.dart';
import 'package:qalam_mobile/shared/pagination/paged_list_state.dart';

CachedPage<String> _page(
  List<String> items, {
  String? nextCursor,
  bool isStale = false,
}) => CachedPage<String>(
  page: CursorPage<String>(
    items: items,
    meta: CursorMeta(nextCursor: nextCursor, hasMore: nextCursor != null),
  ),
  isStale: isStale,
);

void main() {
  group('CursorPaginator', () {
    test('first() returns items + cursor from the page', () async {
      final CursorPaginator<String> p = CursorPaginator<String>(
        (String? cursor) async =>
            Ok<CachedPage<String>>(_page(<String>['a', 'b'], nextCursor: 'c2')),
      );
      final PagedListState<String> state = await p.first();
      expect(state.items, <String>['a', 'b']);
      expect(state.hasMore, isTrue);
      expect(state.nextCursor, 'c2');
    });

    test('first() throws the Failure on error (→ AsyncError)', () async {
      final CursorPaginator<String> p = CursorPaginator<String>(
        (String? cursor) async => const Err<CachedPage<String>>(
          NetworkFailure(code: 'API_OFFLINE', isOffline: true),
        ),
      );
      expect(p.first(), throwsA(isA<NetworkFailure>()));
    });

    test('first() marks stale when served from cache', () async {
      final CursorPaginator<String> p = CursorPaginator<String>(
        (String? cursor) async =>
            Ok<CachedPage<String>>(_page(<String>['a'], isStale: true)),
      );
      final PagedListState<String> state = await p.first();
      expect(state.isStale, isTrue);
      expect(state.hasMore, isFalse);
    });

    test('next() appends the following page and advances the cursor', () async {
      int calls = 0;
      final CursorPaginator<String> p = CursorPaginator<String>((
        String? cursor,
      ) async {
        calls++;
        if (cursor == null) {
          return Ok<CachedPage<String>>(
            _page(<String>['a', 'b'], nextCursor: 'c2'),
          );
        }
        return Ok<CachedPage<String>>(_page(<String>['c', 'd']));
      });
      final PagedListState<String> first = await p.first();
      final PagedListState<String> second = await p.next(first);
      expect(calls, 2);
      expect(second.items, <String>['a', 'b', 'c', 'd']);
      expect(second.hasMore, isFalse);
      expect(second.nextCursor, isNull);
    });

    test('next() is a no-op at end of list', () async {
      final CursorPaginator<String> p = CursorPaginator<String>(
        (String? cursor) async => Ok<CachedPage<String>>(_page(<String>['a'])),
      );
      final PagedListState<String> first = await p.first();
      final PagedListState<String> again = await p.next(first);
      expect(identical(first, again), isTrue);
    });

    test(
      'next() captures a load-more failure but keeps existing items',
      () async {
        final CursorPaginator<String> p = CursorPaginator<String>((
          String? cursor,
        ) async {
          if (cursor == null) {
            return Ok<CachedPage<String>>(
              _page(<String>['a'], nextCursor: 'c2'),
            );
          }
          return const Err<CachedPage<String>>(
            NetworkFailure(code: 'API_NETWORK_ERROR'),
          );
        });
        final PagedListState<String> first = await p.first();
        final PagedListState<String> failed = await p.next(first);
        expect(failed.items, <String>['a']);
        expect(failed.loadMoreFailure, isA<NetworkFailure>());
      },
    );
  });
}

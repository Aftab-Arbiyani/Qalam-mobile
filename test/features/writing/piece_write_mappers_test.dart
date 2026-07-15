import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/writing/data/mappers/piece_write_mappers.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_sync.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

Draft _draft() => Draft(
  localId: 'loc-1',
  title: '  Untitled poem  ',
  languageCode: 'ur',
  genreSlug: 'ghazal',
  tags: const <String>['love', 'longing'],
  createdAt: DateTime.utc(2026, 7),
  localUpdatedAt: DateTime.utc(2026, 7, 2),
);

void main() {
  group('pieceRequestBody', () {
    test(
      'sends only whitelisted writable fields (never status/slug/scheduledAt)',
      () {
        final Map<String, Object?> body = pieceRequestBody(_draft());
        expect(
          body.keys,
          containsAll(<String>['title', 'languageCode', 'visibility', 'tags']),
        );
        expect(body.containsKey('status'), isFalse);
        expect(body.containsKey('slug'), isFalse);
        expect(body.containsKey('scheduledAt'), isFalse);
        expect(body.containsKey('coverImageKey'), isFalse);
      },
    );

    test('trims title and passes the visibility wire value', () {
      final Map<String, Object?> body = pieceRequestBody(_draft());
      expect(body['title'], 'Untitled poem');
      expect(body['visibility'], 'public');
      expect(body['languageCode'], 'ur');
      expect(body['tags'], <String>['love', 'longing']);
    });

    test('omits genreSlug when unset (no accidental clear on PATCH)', () {
      final Draft noGenre = _draft().copyWith(genreSlug: null);
      expect(pieceRequestBody(noGenre).containsKey('genreSlug'), isFalse);
    });
  });

  group('mergeServerPiece', () {
    test('adopts server truth and marks the draft synced', () {
      final Draft merged = mergeServerPiece(_draft(), <String, dynamic>{
        'id': 'srv-9',
        'title': 'Untitled poem',
        'slug': 'untitled-poem',
        'status': 'published',
        'visibility': 'public',
        'language': <String, dynamic>{
          'code': 'ur',
          'nativeName': 'اردو',
          'direction': 'rtl',
        },
        'genre': <String, dynamic>{'slug': 'ghazal', 'name': 'Ghazal'},
        'tags': <dynamic>[
          <String, dynamic>{'slug': 'love', 'name': 'Love'},
        ],
        'wordCount': 42,
        'readingTimeSeconds': 60,
        'updatedAt': '2026-07-15T10:00:00.000Z',
        'publishedAt': '2026-07-15T10:00:00.000Z',
      }, now: DateTime.utc(2026, 7, 15, 11));
      expect(merged.remoteId, 'srv-9');
      expect(merged.slug, 'untitled-poem');
      expect(merged.status, PieceStatus.published);
      expect(merged.direction, TextDirectionKind.rtl);
      expect(merged.genreName, 'Ghazal');
      expect(merged.tags, <String>['Love']);
      expect(merged.wordCount, 42);
      expect(merged.remoteUpdatedAt, DateTime.utc(2026, 7, 15, 10));
      expect(merged.syncState, DraftSyncState.synced);
      expect(merged.localId, 'loc-1'); // preserved
    });
  });

  group('draftSummaryFromListItem', () {
    test('maps a PieceListItemDto to a server-only summary', () {
      final summary = draftSummaryFromListItem(<String, dynamic>{
        'id': 'srv-3',
        'title': 'Scheduled piece',
        'status': 'scheduled',
        'visibility': 'unlisted',
        'wordCount': 100,
        'readingTimeSeconds': 120,
        'scheduledAt': '2026-08-01T09:00:00.000Z',
        'updatedAt': '2026-07-10T09:00:00.000Z',
      });
      expect(summary.remoteId, 'srv-3');
      expect(summary.localId, isNull);
      expect(summary.status, PieceStatus.scheduled);
      expect(summary.visibility, Visibility.unlisted);
      expect(summary.scheduledAt, DateTime.utc(2026, 8, 1, 9));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/feed/data/mappers/feed_mappers.dart';
import 'package:qalam_mobile/features/feed/domain/entities/bookmark_item.dart';
import 'package:qalam_mobile/features/feed/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/features/feed/domain/entities/trend_item.dart';
import 'package:qalam_mobile/features/feed/domain/entities/writer_summary.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  group('pieceSummaryFromJson', () {
    test('maps a full FeedItemDto', () {
      final PieceSummary p = pieceSummaryFromJson(<String, dynamic>{
        'id': 'p1',
        'slug': 'a-ghazal',
        'title': 'A Ghazal',
        'subtitle': 'sub',
        'featuredQuote': 'q',
        'coverImageKey': 'pieces/p1/cover.webp',
        'language': <String, dynamic>{
          'code': 'ur',
          'nativeName': 'اردو',
          'direction': 'rtl',
        },
        'genre': <String, dynamic>{'slug': 'ghazal', 'name': 'Ghazal'},
        'author': <String, dynamic>{
          'username': 'farheen',
          'penName': 'Farheen',
          'avatarKey': 'a.webp',
        },
        'stats': <String, dynamic>{
          'likes': 5,
          'claps': 10,
          'comments': 2,
          'responses': 1,
        },
        'visibility': 'public',
        'wordCount': 300,
        'readingTimeSeconds': 90,
        'publishedAt': '2026-07-10T10:00:00.000Z',
      });

      expect(p.id, 'p1');
      expect(p.direction, TextDirectionKind.rtl);
      expect(p.genre!.name, 'Ghazal');
      expect(p.author.displayName, 'Farheen');
      expect(p.stats.likes, 5);
      expect(p.readingTimeMinutes, 2);
      expect(p.publishedAt!.isUtc, isTrue);
    });

    test('tolerates nulls / missing fields', () {
      final PieceSummary p = pieceSummaryFromJson(<String, dynamic>{
        'id': 'p2',
        'title': 'T',
        'language': <String, dynamic>{'code': 'en'},
        'author': <String, dynamic>{'username': 'ravi'},
      });
      expect(p.slug, isNull);
      expect(p.genre, isNull);
      expect(p.author.penName, isNull);
      expect(p.author.displayName, '@ravi');
      expect(p.direction, TextDirectionKind.ltr);
      expect(p.stats.likes, 0);
      expect(p.publishedAt, isNull);
    });

    test('unknown enum values fall back safely', () {
      final PieceSummary p = pieceSummaryFromJson(<String, dynamic>{
        'id': 'p3',
        'title': 'T',
        'language': <String, dynamic>{'code': 'en', 'direction': 'sideways'},
        'author': <String, dynamic>{'username': 'x'},
        'visibility': 'quantum',
      });
      expect(p.language.direction, TextDirectionKind.ltr);
      expect(p.visibility, Visibility.public);
    });
  });

  test('writerSummaryFromJson', () {
    final WriterSummary w = writerSummaryFromJson(<String, dynamic>{
      'username': 'farheen',
      'penName': 'Farheen',
      'avatarKey': 'a.webp',
      'bio': 'poet',
      'followersCount': 42,
      'piecesCount': 7,
    });
    expect(w.displayName, 'Farheen');
    expect(w.followersCount, 42);
    expect(w.piecesCount, 7);
  });

  test('trendingTagFromJson', () {
    final TrendingTag t = trendingTagFromJson(<String, dynamic>{
      'slug': 'ghazal',
      'name': 'Ghazal',
      'pieceCount': 12,
    });
    expect(t.slug, 'ghazal');
    expect(t.pieceCount, 12);
  });

  test('bookmarkItemFromJson falls back to epoch on a bad date', () {
    final BookmarkItem good = bookmarkItemFromJson(<String, dynamic>{
      'pieceId': 'p1',
      'title': 'T',
      'slug': 's',
      'bookmarkedAt': '2026-07-01T00:00:00.000Z',
    });
    expect(good.pieceId, 'p1');
    expect(good.bookmarkedAt.year, 2026);

    final BookmarkItem bad = bookmarkItemFromJson(<String, dynamic>{
      'pieceId': 'p2',
      'title': 'T',
    });
    expect(bad.bookmarkedAt.millisecondsSinceEpoch, 0);
  });
}

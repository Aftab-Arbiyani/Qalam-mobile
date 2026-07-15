import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/data/mappers/piece_mappers.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_detail.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_engagement.dart';
import 'package:qalam_mobile/features/reading/domain/entities/writer_profile.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  test('pieceDetailFromJson maps content, taxonomy, minimal author', () {
    final PieceDetail d = pieceDetailFromJson(<String, dynamic>{
      'id': 'p1',
      'title': 'A Ghazal',
      'subtitle': 'sub',
      'slug': 'a-ghazal',
      'featuredQuote': 'quote',
      'coverImageKey': 'k.webp',
      'author': <String, dynamic>{'username': 'farheen', 'penName': 'Farheen'},
      'content': <String, dynamic>{'type': 'doc', 'content': <dynamic>[]},
      'language': <String, dynamic>{
        'code': 'ur',
        'nativeName': 'اردو',
        'direction': 'rtl',
      },
      'genre': <String, dynamic>{'slug': 'ghazal', 'name': 'Ghazal'},
      'tags': <dynamic>[
        <String, dynamic>{'slug': 't1', 'name': 'love'},
        <String, dynamic>{'slug': 't2', 'name': 'longing'},
      ],
      'status': 'published',
      'visibility': 'public',
      'wordCount': 200,
      'readingTimeSeconds': 120,
      'publishedAt': '2026-07-10T10:00:00.000Z',
    });

    expect(d.id, 'p1');
    expect(d.author.username, 'farheen');
    expect(d.author.avatarKey, isNull); // not on the piece response
    expect(d.content['type'], 'doc');
    expect(d.direction, TextDirectionKind.rtl);
    expect(d.tags.map((e) => e.name), <String>['love', 'longing']);
    expect(d.readingTimeMinutes, 2);
    expect(d.status, PieceStatus.published);
  });

  test(
    'pieceDetailFromJson tolerates a null language (draft) and unknown status',
    () {
      final PieceDetail d = pieceDetailFromJson(<String, dynamic>{
        'id': 'p2',
        'title': '',
        'author': <String, dynamic>{'username': 'x'},
        'content': <String, dynamic>{},
        'status': 'weird',
      });
      expect(d.language, isNull);
      expect(d.direction, TextDirectionKind.ltr);
      expect(d.status, PieceStatus.published); // fallback
      expect(d.tags, isEmpty);
    },
  );

  test('pieceEngagementFromJson flattens stats + viewer', () {
    final PieceEngagement e = pieceEngagementFromJson(<String, dynamic>{
      'stats': <String, dynamic>{
        'likes': 3,
        'claps': 8,
        'bookmarks': 4,
        'comments': 2,
        'responses': 1,
        'shares': 5,
      },
      'viewer': <String, dynamic>{
        'hasLiked': true,
        'clapCount': 2,
        'hasBookmarked': false,
      },
    });
    expect(e.likes, 3);
    expect(e.shares, 5);
    expect(e.hasLiked, isTrue);
    expect(e.hasBookmarked, isFalse);
    expect(e.clapCount, 2);
  });

  test('pieceEngagementFromJson defaults to empty for anonymous/missing', () {
    final PieceEngagement e = pieceEngagementFromJson(<String, dynamic>{});
    expect(e.likes, 0);
    expect(e.hasLiked, isFalse);
  });

  test('writerProfileFromJson maps id, counts, viewer relation', () {
    final WriterProfile p = writerProfileFromJson(<String, dynamic>{
      'id': 'u1',
      'username': 'farheen',
      'penName': 'Farheen',
      'avatarKey': 'a.webp',
      'bio': 'poet',
      'isPrivate': false,
      'counts': <String, dynamic>{
        'followers': 42,
        'following': 3,
        'piecesPublished': 7,
      },
      'viewerRelation': <String, dynamic>{
        'isSelf': false,
        'isFollowing': true,
        'hasPendingRequest': false,
      },
      'restricted': false,
    });
    expect(p.id, 'u1');
    expect(p.followersCount, 42);
    expect(p.piecesCount, 7);
    expect(p.isFollowing, isTrue);
    expect(p.displayName, 'Farheen');
  });
}

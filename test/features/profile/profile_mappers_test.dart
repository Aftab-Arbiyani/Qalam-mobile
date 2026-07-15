import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/profile/data/mappers/profile_mappers.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_piece.dart';
import 'package:qalam_mobile/features/profile/domain/value_objects/profile_edit.dart';

void main() {
  group('profileFromJson', () {
    test('maps a full (non-restricted) profile', () {
      final Profile p = profileFromJson(<String, dynamic>{
        'id': 'u1',
        'username': 'meera_k',
        'penName': 'Meera',
        'avatarKey': 'a.webp',
        'coverKey': 'c.webp',
        'isPrivate': false,
        'restricted': false,
        'bio': 'hi',
        'websiteUrl': 'https://x.example',
        'location': 'Lahore',
        'socialLinks': <String, dynamic>{'twitter': 'https://x.com/m'},
        'defaultLanguageId': 'lang-uuid',
        'genres': <Json>[
          <String, dynamic>{'id': 'g1', 'slug': 'ghazal', 'name': 'Ghazal'},
        ],
        'counts': <String, dynamic>{
          'followers': 10,
          'following': 2,
          'piecesPublished': 5,
        },
        'viewerRelation': <String, dynamic>{
          'isSelf': true,
          'isFollowing': false,
          'hasPendingRequest': false,
        },
      });

      expect(p.id, 'u1');
      expect(p.displayName, 'Meera');
      expect(p.handle, '@meera_k');
      expect(p.coverKey, 'c.webp');
      expect(p.socialLinks['twitter'], 'https://x.com/m');
      expect(p.genres.single.slug, 'ghazal');
      expect(p.counts.followers, 10);
      expect(p.counts.piecesPublished, 5);
      expect(p.isSelf, isTrue);
    });

    test('tolerates a restricted teaser with missing detail fields', () {
      final Profile p = profileFromJson(<String, dynamic>{
        'id': 'u2',
        'username': 'private_writer',
        'penName': 'PW',
        'avatarKey': null,
        'isPrivate': true,
        'restricted': true,
        'counts': <String, dynamic>{'followers': 1},
        'viewerRelation': <String, dynamic>{},
      });

      expect(p.restricted, isTrue);
      expect(p.isPrivate, isTrue);
      expect(p.bio, isNull);
      expect(p.websiteUrl, isNull);
      expect(p.genres, isEmpty);
      expect(p.socialLinks, isEmpty);
      expect(p.counts.followers, 1);
    });

    test('falls back to the handle when penName is blank', () {
      final Profile p = profileFromJson(<String, dynamic>{
        'id': 'u3',
        'username': 'anon',
        'penName': '',
      });
      expect(p.displayName, '@anon');
    });
  });

  group('profilePieceFromJson', () {
    test('maps a published list item', () {
      final ProfilePiece piece = profilePieceFromJson(<String, dynamic>{
        'id': 'p1',
        'title': 'Barish',
        'slug': 'barish',
        'coverImageKey': 'cover.webp',
        'wordCount': 120,
        'readingTimeSeconds': 90,
        'publishedAt': '2026-01-01T00:00:00.000Z',
      });
      expect(piece.id, 'p1');
      expect(piece.title, 'Barish');
      expect(piece.readingTimeSeconds, 90);
      expect(piece.publishedAt, isNotNull);
    });
  });

  group('profilePatchBody', () {
    test('omits null (unchanged) fields', () {
      final Json body = profilePatchBody(const ProfileEdit(penName: 'New'));
      expect(body, <String, Object?>{'penName': 'New'});
    });

    test('sends empty bio/location (clearable) but omits blank website', () {
      final Json body = profilePatchBody(
        const ProfileEdit(bio: '', location: '', websiteUrl: ''),
      );
      expect(body.containsKey('bio'), isTrue);
      expect(body['bio'], '');
      expect(body.containsKey('location'), isTrue);
      expect(body.containsKey('websiteUrl'), isFalse);
    });

    test('trims website and includes it when present', () {
      final Json body = profilePatchBody(
        const ProfileEdit(websiteUrl: '  https://x.example  '),
      );
      expect(body['websiteUrl'], 'https://x.example');
    });

    test('sends genre slugs and privacy', () {
      final Json body = profilePatchBody(
        const ProfileEdit(
          isPrivate: true,
          genreSlugs: <String>['ghazal', 'nazm'],
        ),
      );
      expect(body['isPrivate'], true);
      expect(body['genres'], <String>['ghazal', 'nazm']);
    });

    test('privacy-only edit sends just isPrivate', () {
      expect(
        profilePatchBody(const ProfileEdit.privacy(true)),
        <String, Object?>{'isPrivate': true},
      );
    });
  });
}

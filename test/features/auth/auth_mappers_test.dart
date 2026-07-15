import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/auth/data/mappers/auth_mappers.dart';

void main() {
  group('authResultFromJson', () {
    test('login/register shape maps user + both tokens', () {
      final result = authResultFromJson(<String, dynamic>{
        'accessToken': 'at',
        'refreshToken': 'rt',
        'user': <String, dynamic>{
          'id': 'u1',
          'email': 'w@q.test',
          'username': 'writer',
          'isEmailVerified': true,
        },
      });
      expect(result.accessToken, 'at');
      expect(result.refreshToken, 'rt');
      expect(result.user?.username, 'writer');
      expect(result.user?.isEmailVerified, isTrue);
    });

    test(
      'Google exchange shape (accessToken only) → null user + null refresh',
      () {
        final result = authResultFromJson(<String, dynamic>{
          'accessToken': 'at',
        });
        expect(result.accessToken, 'at');
        expect(result.refreshToken, isNull);
        expect(result.user, isNull);
      },
    );

    test('missing isEmailVerified defaults to false (forward-compatible)', () {
      final result = authResultFromJson(<String, dynamic>{
        'accessToken': 'at',
        'user': <String, dynamic>{
          'id': 'u1',
          'email': 'w@q.test',
          'username': 'writer',
        },
      });
      expect(result.user?.isEmailVerified, isFalse);
    });

    test('unknown extra fields are ignored', () {
      final result = authResultFromJson(<String, dynamic>{
        'accessToken': 'at',
        'somethingNew': 42,
        'user': <String, dynamic>{
          'id': 'u1',
          'email': 'w@q.test',
          'username': 'writer',
          'isEmailVerified': false,
          'futureField': true,
        },
      });
      expect(result.user?.username, 'writer');
    });
  });
}

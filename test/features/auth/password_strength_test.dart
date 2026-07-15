import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/auth/domain/value_objects/password_strength.dart';

void main() {
  group('estimatePasswordStrength', () {
    test('empty → empty level, score 0', () {
      final PasswordStrength s = estimatePasswordStrength('');
      expect(s.level, PasswordStrengthLevel.empty);
      expect(s.score, 0);
    });

    test('below the length floor never reads above weak', () {
      final PasswordStrength s = estimatePasswordStrength('Ab1!');
      expect(s.level, PasswordStrengthLevel.weak);
      expect(s.score, 1);
    });

    test('at the length floor with low variety is fair', () {
      // 10 lowercase letters: length points only.
      final PasswordStrength s = estimatePasswordStrength('aaaaaaaaaa');
      expect(s.level, PasswordStrengthLevel.fair);
    });

    test('long + varied → strong', () {
      final PasswordStrength s = estimatePasswordStrength(
        'CorrectHorse9!Battery',
      );
      expect(s.level, PasswordStrengthLevel.strong);
      expect(s.score, 4);
    });

    test('score is clamped to 1..4 once non-empty', () {
      final PasswordStrength s = estimatePasswordStrength('a');
      expect(s.score, greaterThanOrEqualTo(1));
      expect(s.score, lessThanOrEqualTo(4));
    });
  });
}

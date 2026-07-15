/// Password-strength estimate (docs/41 §29) — a pure, client-side UX hint shown
/// under the password field on register/reset. It is NOT a validation gate and NOT
/// authoritative: the server enforces the real policy (length 10–128 + a breached-
/// password list + Argon2id — docs/40 §39.1). This only nudges the user toward a
/// stronger secret; the field is still submittable once it meets the length floor.
library;

import '../../../../shared/domain/limits.dart';

enum PasswordStrengthLevel { empty, weak, fair, good, strong }

class PasswordStrength {
  const PasswordStrength(this.score, this.level);

  /// 0–4, aligned with [PasswordStrengthLevel] beyond `empty`.
  final int score;
  final PasswordStrengthLevel level;

  static const PasswordStrength none = PasswordStrength(
    0,
    PasswordStrengthLevel.empty,
  );
}

/// Estimate strength from length and character-class variety. Deliberately simple
/// and deterministic (no external zxcvbn dependency) — it informs, it does not
/// judge. Length is weighted most, matching the NIST length-over-composition
/// stance the backend follows.
PasswordStrength estimatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.none;

  int points = 0;
  final int length = password.length;

  // Length is the dominant signal.
  if (length >= Limits.passwordMin) points += 2;
  if (length >= 14) points += 1;
  if (length >= 20) points += 1;

  // Variety is a secondary nudge.
  int classes = 0;
  if (password.contains(RegExp('[a-z]'))) classes++;
  if (password.contains(RegExp('[A-Z]'))) classes++;
  if (password.contains(RegExp('[0-9]'))) classes++;
  if (password.contains(RegExp(r'[^A-Za-z0-9]'))) classes++;
  if (classes >= 2) points += 1;
  if (classes >= 3) points += 1;

  // Below the length floor can never read above "weak".
  if (length < Limits.passwordMin) {
    return const PasswordStrength(1, PasswordStrengthLevel.weak);
  }

  final int score = points.clamp(1, 4);
  final PasswordStrengthLevel level = switch (score) {
    1 => PasswordStrengthLevel.weak,
    2 => PasswordStrengthLevel.fair,
    3 => PasswordStrengthLevel.good,
    _ => PasswordStrengthLevel.strong,
  };
  return PasswordStrength(score, level);
}

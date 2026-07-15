/// Password-strength meter (docs/41 §29) — a calm four-segment bar plus a small
/// label, driven by the pure [estimatePasswordStrength] heuristic. It is a UX hint,
/// not a gate. Colours come from the neutral + semantic ramps (never ad-hoc), and
/// the whole thing carries a screen-reader label so strength isn't conveyed by
/// colour alone (docs/41 §20).
library;

import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../domain/value_objects/password_strength.dart';
import 'auth_l10n.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final PasswordStrength strength = estimatePasswordStrength(password);

    if (strength.level == PasswordStrengthLevel.empty) {
      return const SizedBox.shrink();
    }

    final Color color = switch (strength.level) {
      PasswordStrengthLevel.empty ||
      PasswordStrengthLevel.weak => tokens.colors.danger,
      PasswordStrengthLevel.fair => tokens.colors.warning,
      PasswordStrengthLevel.good => tokens.colors.info,
      PasswordStrengthLevel.strong => tokens.colors.success,
    };
    final String levelText = passwordStrengthLevelLabel(l10n, strength.level);

    return Semantics(
      label: l10n.pwStrengthLabel(levelText),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              for (int i = 0; i < 4; i++) ...<Widget>[
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < strength.score
                          ? color
                          : tokens.colors.bgRaised,
                      borderRadius: QRadii.controlRadius,
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: QSpacing.s1),
              ],
            ],
          ),
          Gap.v1,
          Text(
            levelText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

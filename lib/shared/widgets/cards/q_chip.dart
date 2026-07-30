/// Chip / tag (docs/41 §11.9). Tones map to the accent + semantic palettes;
/// optional leading icon and remove affordance. Interactive chips are tappable.
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import '../../theme/tokens/color_tokens.dart';
import '../../theme/tokens/radius_tokens.dart';

enum QChipTone { neutral, accent, success, warning, danger, info }

class QChip extends StatelessWidget {
  const QChip({
    required this.label,
    this.tone = QChipTone.neutral,
    this.icon,
    this.onTap,
    this.onRemove,
    super.key,
  });

  final String label;
  final QChipTone tone;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  ({Color bg, Color fg}) _colors(QColorSet c) => switch (tone) {
    QChipTone.neutral => (bg: c.bgRaised, fg: c.textSecondary),
    QChipTone.accent => (bg: c.accentSubtle, fg: c.accent),
    QChipTone.success => (bg: c.successBg, fg: c.successText),
    QChipTone.warning => (bg: c.warningBg, fg: c.warningText),
    QChipTone.danger => (bg: c.dangerBg, fg: c.dangerText),
    QChipTone.info => (bg: c.infoBg, fg: c.infoText),
  };

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ({Color bg, Color fg}) colors = _colors(tokens.colors);

    final Widget body = Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: QRadii.controlRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: colors.fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.fg,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRemove != null) ...<Widget>[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Semantics(
                button: true,
                label: 'Remove $label',
                child: Icon(Icons.close, size: 16, color: colors.fg),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return body;
    return InkWell(
      borderRadius: QRadii.controlRadius,
      onTap: onTap,
      child: body,
    );
  }
}

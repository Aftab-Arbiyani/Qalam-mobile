/// Button primitive (docs/41 §11.1). Variants primary/secondary/ghost/danger,
/// sizes sm/md/lg, loading + disabled states, one accent per screen. Guarantees a
/// ≥48px tap target even for the 32px `sm` control — Android's Material tap-target
/// guideline, which is stricter than Apple's 44px (docs/48 §3.22a, T-10).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import '../../theme/tokens/radius_tokens.dart';

enum QButtonVariant { primary, secondary, ghost, danger }

enum QButtonSize { sm, md, lg }

class QButton extends StatelessWidget {
  const QButton({
    required this.label,
    this.onPressed,
    this.variant = QButtonVariant.secondary,
    this.size = QButtonSize.md,
    this.icon,
    this.iconAtEnd = false,
    this.loading = false,
    this.block = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final QButtonVariant variant;
  final QButtonSize size;
  final IconData? icon;
  final bool iconAtEnd;
  final bool loading;
  final bool block;

  bool get _enabled => onPressed != null && !loading;

  double get _visualHeight => switch (size) {
    QButtonSize.sm => 32,
    QButtonSize.md => 40,
    QButtonSize.lg => 48,
  };

  double get _hPad => switch (size) {
    QButtonSize.sm => 12,
    QButtonSize.md => 16,
    QButtonSize.lg => 24,
  };

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final _Palette p = _palette(tokens);
    final double tapHeight = math.max(_visualHeight, 48);

    final TextStyle textStyle =
        (size == QButtonSize.lg
                ? theme.textTheme.bodyLarge
                : theme.textTheme.labelLarge)!
            .copyWith(color: p.foreground, fontWeight: FontWeight.w500);

    final Widget content = loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: p.foreground,
            ),
          )
        : Row(
            mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null && !iconAtEnd) ...<Widget>[
                Icon(icon, size: 20, color: p.foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null && iconAtEnd) ...<Widget>[
                const SizedBox(width: 8),
                Icon(icon, size: 20, color: p.foreground),
              ],
            ],
          );

    final Widget control = DecoratedBox(
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: QRadii.controlRadius,
        border: p.border == null
            ? null
            : Border.fromBorderSide(BorderSide(color: p.border!)),
      ),
      child: Container(
        height: _visualHeight,
        padding: EdgeInsets.symmetric(horizontal: _hPad),
        alignment: Alignment.center,
        child: content,
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: Opacity(
        opacity: _enabled ? 1 : 0.5,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: QRadii.controlRadius,
            onTap: _enabled ? onPressed : null,
            child: SizedBox(
              width: block ? double.infinity : null,
              height: tapHeight,
              child: Align(
                child: block
                    ? SizedBox(width: double.infinity, child: control)
                    : control,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _Palette _palette(QTokens tokens) {
    final c = tokens.colors;
    return switch (variant) {
      QButtonVariant.primary => _Palette(
        background: c.accent,
        foreground: c.accentContrast,
        border: null,
      ),
      QButtonVariant.secondary => _Palette(
        background: Colors.transparent,
        foreground: c.textPrimary,
        border: c.borderStrong,
      ),
      QButtonVariant.ghost => _Palette(
        background: Colors.transparent,
        foreground: c.textSecondary,
        border: null,
      ),
      QButtonVariant.danger => _Palette(
        background: c.danger,
        foreground: const Color(0xFFFFFFFF),
        border: null,
      ),
    };
  }
}

class _Palette {
  const _Palette({
    required this.background,
    required this.foreground,
    required this.border,
  });
  final Color background;
  final Color foreground;
  final Color? border;
}

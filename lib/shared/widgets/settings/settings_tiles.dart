/// Reusable settings-row primitives (docs/41 §11, §28). Shared so every settings
/// surface — the hub and the per-feature account/appearance/privacy screens —
/// renders the same grouped rows without duplicating layout. Token-driven, ≥44px
/// touch targets, and screen-reader friendly.
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import '../../theme/tokens/color_tokens.dart';
import '../../theme/tokens/radius_tokens.dart';
import '../../theme/tokens/spacing_tokens.dart';

/// A titled group of settings rows on a raised card.
class QSettingsSection extends StatelessWidget {
  const QSettingsSection({required this.children, this.title, super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: QSpacing.s1,
              bottom: QSpacing.s2,
            ),
            child: Text(
              title!.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: tokens.colors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.colors.bgSurface,
            borderRadius: QRadii.cardRadius,
            border: Border.all(color: tokens.colors.border),
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0)
                  Divider(height: 1, thickness: 1, color: tokens.colors.border),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A single tappable settings row (icon · title/subtitle · trailing).
class QSettingsTile extends StatelessWidget {
  const QSettingsTile({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final Color titleColor = destructive
        ? tokens.colors.danger
        : tokens.colors.textPrimary;
    final Widget? resolvedTrailing =
        trailing ??
        (onTap != null
            ? Icon(Icons.chevron_right, color: tokens.colors.textMuted)
            : null);

    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: QRadii.cardRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: QSpacing.s4,
              vertical: QSpacing.s3,
            ),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: 20,
                    color: destructive
                        ? tokens.colors.danger
                        : tokens.colors.textSecondary,
                  ),
                  Gap.h3,
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: titleColor,
                        ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.colors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (resolvedTrailing != null) ...<Widget>[
                  Gap.h2,
                  resolvedTrailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A settings row with a trailing switch (boolean preference).
class QSettingsSwitchTile extends StatelessWidget {
  const QSettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    return MergeSemantics(
      child: QSettingsTile(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: colors.accent,
        ),
      ),
    );
  }
}

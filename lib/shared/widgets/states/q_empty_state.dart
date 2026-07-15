/// Empty state (docs/41 §11.14, §33). Calm icon in a 48px circle, literary title,
/// warm body, at most one action. Copy comes from a catalog — never blames the
/// user, no exclamation marks.
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';
import '../../theme/tokens/spacing_tokens.dart';

class QEmptyState extends StatelessWidget {
  const QEmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.minHeight = 320,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight, maxWidth: 360),
        child: Padding(
          padding: QSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.colors.bgRaised,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: tokens.colors.textMuted),
              ),
              Gap.v4,
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (message != null) ...<Widget>[
                Gap.v2,
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
              ],
              if (action != null) ...<Widget>[Gap.v5, action!],
            ],
          ),
        ),
      ),
    );
  }
}

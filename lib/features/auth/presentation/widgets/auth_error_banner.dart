/// Form-level error banner (docs/41 §29, §32). Renders a domain [Failure] with
/// honest, literary copy resolved from the error catalog (never the raw server
/// message, never a stack trace). A polite live region announces it to screen
/// readers. Colour is paired with an icon and text (never colour alone).
library;

import 'package:flutter/material.dart';

import '../../../../core/error/error_messages.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.failure, super.key});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final ErrorCopy copy = ErrorMessages.of(failure);

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(QSpacing.s3),
        decoration: BoxDecoration(
          color: tokens.colors.dangerBg,
          borderRadius: QRadii.cardRadius,
          border: Border.all(color: tokens.colors.danger),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline, size: 16, color: tokens.colors.danger),
            const SizedBox(width: QSpacing.s2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    copy.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.colors.dangerText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    copy.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.colors.dangerText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

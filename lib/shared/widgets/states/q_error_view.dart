/// Error view (docs/41 §11.16, §32). Renders a [Failure] with honest, literary
/// copy from the error catalog (never a raw exception/message), an optional retry,
/// and a support reference (`requestId`) disclosure for unexpected failures.
library;

import 'package:flutter/material.dart';

import '../../../core/error/error_messages.dart';
import '../../../core/error/failure.dart';
import '../../theme/q_tokens.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../buttons/q_button.dart';

class QErrorView extends StatelessWidget {
  const QErrorView({
    required this.failure,
    this.onRetry,
    this.retryLabel = 'Try again',
    super.key,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final ErrorCopy copy = ErrorMessages.of(failure);
    final String? requestId = switch (failure) {
      UnexpectedFailure(:final String? requestId) => requestId,
      _ => null,
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 320, maxWidth: 360),
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
                child: Icon(
                  Icons.error_outline,
                  size: 24,
                  color: tokens.colors.textMuted,
                ),
              ),
              Gap.v4,
              Text(
                copy.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              Gap.v2,
              Text(
                copy.body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
              if (onRetry != null) ...<Widget>[
                Gap.v5,
                QButton(label: retryLabel, onPressed: onRetry),
              ],
              if (requestId != null) ...<Widget>[
                Gap.v4,
                Text(
                  'Reference: $requestId',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.colors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Snackbar / toast (docs/41 §11.6). Transient, above the bottom bar, with a
/// semantic icon and optional Undo action. Durations: neutral/success 3s,
/// danger 5s. Never carries critical-path information.
library;

import 'package:flutter/material.dart';

import '../../theme/q_tokens.dart';

enum QSnackbarVariant { neutral, success, danger }

abstract final class QSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    QSnackbarVariant variant = QSnackbarVariant.neutral,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final QTokens tokens = QTokens.of(context);
    final ({IconData icon, Color color}) style = switch (variant) {
      QSnackbarVariant.neutral => (
        icon: Icons.check,
        color: tokens.colors.textSecondary,
      ),
      QSnackbarVariant.success => (
        icon: Icons.check_circle_outline,
        color: tokens.colors.success,
      ),
      QSnackbarVariant.danger => (
        icon: Icons.error_outline,
        color: tokens.colors.danger,
      ),
    };
    final Duration duration = variant == QSnackbarVariant.danger
        ? const Duration(seconds: 5)
        : const Duration(seconds: 3);

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          content: Row(
            children: <Widget>[
              Icon(style.icon, size: 16, color: style.color),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }

  /// A danger-styled snackbar with an Undo action that returns its controller, so
  /// the caller can `await controller.closed` and learn whether the user tapped
  /// Undo ([SnackBarClosedReason.action]) or let it time out — the basis of the
  /// undo-able destructive pattern (docs/41 §18). [onUndo] fires immediately on tap.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showUndo(
    BuildContext context, {
    required String message,
    required String undoLabel,
    required VoidCallback onUndo,
  }) {
    final QTokens tokens = QTokens.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Row(
          children: <Widget>[
            Icon(
              Icons.delete_outline,
              size: 16,
              color: tokens.colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        action: SnackBarAction(label: undoLabel, onPressed: onUndo),
      ),
    );
  }
}

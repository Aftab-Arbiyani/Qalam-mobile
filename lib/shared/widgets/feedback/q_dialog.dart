/// Dialog (docs/41 §11.4). Reserved for the irreversible (undo covers the rest).
/// `confirm` returns whether the user confirmed; destructive confirms disable
/// barrier dismissal and color the primary action with danger.
library;

import 'package:flutter/material.dart';

import '../buttons/q_button.dart';

abstract final class QDialog {
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: !destructive,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            QButton(
              label: cancelLabel,
              variant: QButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            QButton(
              label: confirmLabel,
              variant: destructive
                  ? QButtonVariant.danger
                  : QButtonVariant.primary,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

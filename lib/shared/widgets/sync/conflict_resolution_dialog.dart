/// The conflict-resolution dialog (docs/40 §23, §42.1) — shown when a queued
/// operation could not be replayed because the server diverged from its base. The
/// user chooses to keep their local change (retry, overwriting the server) or keep
/// the server's version (discard the queued change). Returns the chosen
/// [ConflictResolution], or null if dismissed.
library;

import 'package:flutter/material.dart';

import '../../../core/sync/sync_engine.dart';
import '../../../core/sync/sync_operation.dart';
import '../buttons/q_button.dart';

Future<ConflictResolution?> showConflictResolutionDialog(
  BuildContext context,
  SyncOperation op,
) => showDialog<ConflictResolution>(
  context: context,
  builder: (BuildContext context) => _ConflictDialog(op: op),
);

class _ConflictDialog extends StatelessWidget {
  const _ConflictDialog({required this.op});

  final SyncOperation op;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String what = op.label ?? op.type;
    return AlertDialog(
      title: const Text('Resolve conflict'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Your change to "$what" could not be applied because it changed on '
            'the server while you were offline.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Keep your version to try again, or keep the server version to '
            'discard your change.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      actions: <Widget>[
        QButton(
          label: 'Keep server',
          variant: QButtonVariant.ghost,
          size: QButtonSize.sm,
          onPressed: () =>
              Navigator.of(context).pop(ConflictResolution.keepServer),
        ),
        QButton(
          label: 'Keep mine',
          size: QButtonSize.sm,
          onPressed: () =>
              Navigator.of(context).pop(ConflictResolution.keepLocal),
        ),
      ],
    );
  }
}

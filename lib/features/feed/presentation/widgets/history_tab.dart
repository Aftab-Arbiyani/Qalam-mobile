/// The Reading History tab (docs/40 §23, docs/41 §35). Reads the local reading
/// timeline (device data; no backend history surface exists) — newest first, with
/// a Continue-Reading progress affordance per entry and a clear-history action.
/// Fully available offline.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/reading_history/reading_history_controller.dart';
import '../../../../core/reading_history/reading_history_entry.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/content/history_card.dart';
import '../../../../shared/widgets/feedback/q_dialog.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ReadingHistoryEntry> entries = ref.watch(
      recentlyReadListProvider,
    );

    if (entries.isEmpty) {
      return const QEmptyState(
        icon: Icons.history,
        title: 'Nothing read yet.',
        message:
            'Pieces you open will gather here so you can pick up where you left off.',
      );
    }

    return Column(
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: QSpacing.s4,
              vertical: QSpacing.s1,
            ),
            child: TextButton.icon(
              onPressed: () => _confirmClear(context, ref),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: QSpacing.s4),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              final ReadingHistoryEntry entry = entries[index];
              return HistoryCard(
                entry: entry,
                onRemove: () => ref
                    .read(readingHistoryControllerProvider.notifier)
                    .remove(entry.pieceId),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final bool ok = await QDialog.confirm(
      context,
      title: 'Clear reading history?',
      message:
          'This removes your local reading history on this device. It cannot be undone.',
      confirmLabel: 'Clear',
      destructive: true,
    );
    if (ok) {
      await ref.read(readingHistoryControllerProvider.notifier).clearAll();
    }
  }
}

/// Prompt Library screen (AF2) — browse and manage reusable prompt STARTERS:
/// built-in presets, favourites, custom presets (add/delete), and prompt history.
/// Tapping a preset copies its instruction for use in the assistant. On-device only
/// (presets are saved user messages, never AI system prompts).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../domain/value_objects/prompt_preset.dart';
import '../controllers/prompt_library_controller.dart';

class PromptLibraryScreen extends ConsumerWidget {
  const PromptLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PromptLibraryState lib = ref.watch(promptLibraryControllerProvider);
    final PromptLibraryController notifier = ref.read(promptLibraryControllerProvider.notifier);

    return Scaffold(
      appBar: QAppBar(
        title: 'Prompt library',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New prompt',
            onPressed: () => unawaited(_addCustom(context, notifier)),
          ),
        ],
      ),
      body: ListView(
        padding: QSpacing.pagePadding,
        children: <Widget>[
          if (lib.favorites.isNotEmpty) ...<Widget>[
            _section(context, 'Favourites'),
            for (final PromptPreset p in lib.favorites)
              _presetTile(context, ref, p, lib.isFavorite(p.id)),
            Gap.v4,
          ],
          _section(context, 'Presets'),
          for (final PromptPreset p in lib.builtIn)
            _presetTile(context, ref, p, lib.isFavorite(p.id)),
          if (lib.custom.isNotEmpty) ...<Widget>[
            Gap.v4,
            _section(context, 'Your prompts'),
            for (final PromptPreset p in lib.custom)
              _presetTile(context, ref, p, lib.isFavorite(p.id)),
          ],
          if (lib.history.isNotEmpty) ...<Widget>[
            Gap.v4,
            Row(
              children: <Widget>[
                Expanded(child: _section(context, 'History')),
                TextButton(
                  onPressed: () => unawaited(notifier.clearHistory()),
                  child: const Text('Clear'),
                ),
              ],
            ),
            for (final String h in lib.history)
              ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 18),
                title: Text(h, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => _copy(context, h),
              ),
          ],
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(bottom: QSpacing.s2),
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _presetTile(BuildContext context, WidgetRef ref, PromptPreset p, bool favorite) {
    final QTokens tokens = QTokens.of(context);
    final PromptLibraryController notifier = ref.read(promptLibraryControllerProvider.notifier);
    return ListTile(
      title: Text(p.title),
      subtitle: Text(p.instruction, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () => _copy(context, p.instruction),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              favorite ? Icons.star : Icons.star_border,
              color: favorite ? tokens.colors.accent : tokens.colors.textMuted,
            ),
            tooltip: favorite ? 'Unfavourite' : 'Favourite',
            onPressed: () => unawaited(notifier.toggleFavorite(p.id)),
          ),
          if (!p.isBuiltIn)
            IconButton(
              icon: Icon(Icons.delete_outline, color: tokens.colors.textMuted),
              tooltip: 'Delete',
              onPressed: () => unawaited(notifier.deleteCustom(p.id)),
            ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    unawaited(Clipboard.setData(ClipboardData(text: text)));
    QSnackbar.show(context, message: 'Prompt copied.', variant: QSnackbarVariant.success);
  }

  Future<void> _addCustom(BuildContext context, PromptLibraryController notifier) async {
    final TextEditingController title = TextEditingController();
    final TextEditingController instruction = TextEditingController();
    final bool? save = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('New prompt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            const SizedBox(height: QSpacing.s2),
            TextField(
              controller: instruction,
              decoration: const InputDecoration(labelText: 'Instruction'),
              minLines: 2,
              maxLines: 5,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save == true && instruction.text.trim().isNotEmpty) {
      await notifier.addCustom(title: title.text, instruction: instruction.text);
    }
  }
}

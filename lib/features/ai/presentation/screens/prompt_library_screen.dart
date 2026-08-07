/// Prompt Library screen (AF2) — browse and manage reusable prompt STARTERS:
/// built-in presets, favourites, custom presets (add/delete), and prompt history.
/// Tapping a preset copies its instruction. Each preset also offers **Use in
/// assistant** (docs/48 §3.12), which hands the instruction to the Writing
/// Assistant's Ask AI field directly — for when the clipboard is blocked or
/// unavailable, Copy's dead end. On-device only (presets are saved user messages,
/// never AI system prompts).
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
  const PromptLibraryScreen({this.routeId, super.key});

  /// The draft this screen was opened from, if any (docs/48 §3.12). Only the
  /// editor overflow pushes this route today, always carrying its draft's local
  /// route id, so **Use in assistant** is offered whenever it's set and hidden
  /// otherwise — there is no editor to hand a preset to without it.
  final String? routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PromptLibraryState lib = ref.watch(promptLibraryControllerProvider);
    final PromptLibraryController notifier = ref.read(
      promptLibraryControllerProvider.notifier,
    );

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
                trailing: routeId == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        tooltip: 'Use in assistant',
                        onPressed: () => _useInAssistant(context, ref, h),
                      ),
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

  Widget _presetTile(
    BuildContext context,
    WidgetRef ref,
    PromptPreset p,
    bool favorite,
  ) {
    final QTokens tokens = QTokens.of(context);
    final PromptLibraryController notifier = ref.read(
      promptLibraryControllerProvider.notifier,
    );
    return ListTile(
      title: Text(p.title),
      subtitle: Text(
        p.instruction,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
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
          if (routeId != null)
            IconButton(
              icon: Icon(Icons.auto_awesome, color: tokens.colors.accent),
              tooltip: 'Use in assistant',
              onPressed: () => _useInAssistant(context, ref, p.instruction),
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
    QSnackbar.show(
      context,
      message: 'Prompt copied.',
      variant: QSnackbarVariant.success,
    );
  }

  /// Hand the instruction to the Writing Assistant instead of the clipboard
  /// (docs/48 §3.12). Pops this screen back to the editor it was opened from,
  /// returning the instruction — the editor opens the panel pre-filled with it.
  void _useInAssistant(BuildContext context, WidgetRef ref, String text) {
    unawaited(
      ref.read(promptLibraryControllerProvider.notifier).recordUse(text),
    );
    Navigator.of(context).pop(text);
  }

  Future<void> _addCustom(
    BuildContext context,
    PromptLibraryController notifier,
  ) async {
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
      await notifier.addCustom(
        title: title.text,
        instruction: instruction.text,
      );
    }
  }
}

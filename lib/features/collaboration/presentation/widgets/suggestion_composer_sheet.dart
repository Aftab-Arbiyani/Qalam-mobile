/// The "propose an edit" composer (AF6, docs/48 §3.22a). `addSuggestion` has
/// existed end-to-end in the data layer since C-3/C-4 with zero UI callers — this
/// is the first one. v1 is whole-block granularity: the caller already resolved a
/// tapped paragraph/heading into a [TextAnchor] + its exact original text (see
/// `ContentRenderer`'s `blockAnchors`/`onBlockTap` and
/// `parseContentWithAnchors` in the reading feature); this widget only composes
/// the replacement and submits it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../domain/entities/edit_suggestion.dart';
import '../../domain/entities/text_anchor.dart';
import '../controllers/collaboration_controller.dart';

abstract final class SuggestionComposerSheet {
  /// Opens the composer for a single block. Resolves to `true` once a suggestion
  /// was sent, or `null` if the sheet was dismissed without submitting.
  static Future<bool?> show(
    BuildContext context, {
    required String storyId,
    required TextAnchor anchor,
    required String originalText,
  }) {
    return QBottomSheet.show<bool>(
      context,
      builder: (_) => _SuggestionComposer(
        storyId: storyId,
        anchor: anchor,
        originalText: originalText,
      ),
    );
  }
}

class _SuggestionComposer extends ConsumerStatefulWidget {
  const _SuggestionComposer({
    required this.storyId,
    required this.anchor,
    required this.originalText,
  });

  final String storyId;
  final TextAnchor anchor;
  final String originalText;

  @override
  ConsumerState<_SuggestionComposer> createState() =>
      _SuggestionComposerState();
}

class _SuggestionComposerState extends ConsumerState<_SuggestionComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _overLimit => _controller.text.length > Limits.storySuggestionMax;

  Future<void> _submit() async {
    final String suggested = _controller.text.trim();
    if (suggested.isEmpty || suggested.length > Limits.storySuggestionMax) {
      return;
    }
    final EditSuggestion? added = await ref
        .read(collaborationControllerProvider.notifier)
        .addSuggestion(
          storyId: widget.storyId,
          anchor: widget.anchor,
          originalText: widget.originalText,
          suggestedText: suggested,
        );
    if (!mounted) return;
    if (added != null) {
      Navigator.of(context).pop(true);
      QSnackbar.show(
        context,
        message: 'Suggestion sent.',
        variant: QSnackbarVariant.success,
      );
    } else {
      QSnackbar.show(
        context,
        message: _errorMessage(ref),
        variant: QSnackbarVariant.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool busy = ref.watch(collaborationControllerProvider).isLoading;
    return Padding(
      padding: const EdgeInsets.all(QSpacing.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Suggest an edit', style: theme.textTheme.titleMedium),
          Gap.v3,
          Text('Original', style: theme.textTheme.labelSmall),
          Gap.v1,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(QSpacing.s2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.originalText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Gap.v3,
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Your suggested wording',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Gap.v1,
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext context, TextEditingValue value, _) => Text(
              '${value.text.length} / ${Limits.storySuggestionMax}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: _overLimit ? theme.colorScheme.error : null,
              ),
            ),
          ),
          Gap.v4,
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              Gap.h2,
              Expanded(
                child: FilledButton(
                  onPressed:
                      busy || _controller.text.trim().isEmpty || _overLimit
                      ? null
                      : _submit,
                  child: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _errorMessage(WidgetRef ref) {
  final Object? err = ref.read(collaborationControllerProvider).error;
  return err is Failure ? err.message : 'Something went wrong.';
}

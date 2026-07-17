/// The floating Writing Assistant panel (AF2) — the in-editor AI surface, shown as a
/// bottom sheet over the editor. It offers quick actions (continue/rewrite/expand/
/// condense/simplify) plus Improve·{aspect}, Tone·{tone}, and a free-form "Ask AI"
/// with the Prompt Library. It STREAMS the result (typing animation, cancel), then
/// presents an immutable suggestion with Preview/Compare and Apply/Replace/Insert/
/// Append/Copy/Save-as-draft/Discard/Undo — every write routing through the editor's
/// own commands via [AiEditorTarget]. The AI never touches the document itself.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/value_objects/prompt_preset.dart';
import '../../domain/value_objects/writing_action.dart';
import '../controllers/ai_stream_controller.dart';
import '../controllers/assistant_session_controller.dart';
import '../controllers/prompt_library_controller.dart';
import '../editor/ai_editor_target.dart';
import '../support/ai_error_copy.dart';
import '../widgets/ai_markdown.dart';
import '../widgets/ai_streaming_text.dart';
import '../widgets/suggestion_diff_view.dart';
import '../widgets/token_usage_line.dart';

class WritingAssistantPanel extends ConsumerStatefulWidget {
  const WritingAssistantPanel({required this.target, super.key});

  final AiEditorTarget target;

  static Future<void> show(BuildContext context, {required AiEditorTarget target}) =>
      QBottomSheet.show<void>(context, builder: (_) => WritingAssistantPanel(target: target));

  @override
  ConsumerState<WritingAssistantPanel> createState() => _WritingAssistantPanelState();
}

class _WritingAssistantPanelState extends ConsumerState<WritingAssistantPanel> {
  final TextEditingController _ask = TextEditingController();
  bool _showDiff = false;
  AiApplyHandle? _applied;

  @override
  void initState() {
    super.initState();
    // Fresh session per open.
    Future<void>.microtask(
      () => ref.read(assistantSessionControllerProvider.notifier).reset(),
    );
  }

  @override
  void dispose() {
    _ask.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final AssistantSessionState session = ref.watch(assistantSessionControllerProvider);
    final Size screen = MediaQuery.sizeOf(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screen.height * 0.82),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(QSpacing.s4, 0, QSpacing.s4, QSpacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header(tokens),
            Gap.v2,
            _contextChip(tokens),
            Gap.v3,
            Flexible(child: _body(session)),
          ],
        ),
      ),
    );
  }

  Widget _header(QTokens tokens) => Row(
        children: <Widget>[
          Icon(Icons.auto_awesome, size: 20, color: tokens.colors.accent),
          const SizedBox(width: QSpacing.s2),
          Text('Writing assistant', style: Theme.of(context).textTheme.titleMedium),
        ],
      );

  Widget _contextChip(QTokens tokens) {
    final bool sel = widget.target.canReplaceSelection;
    final int words = widget.target.context.hasSelection
        ? widget.target.context.selectionText.trim().split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length
        : widget.target.context.wordCount;
    return QChip(
      label: sel ? 'Selection · $words words' : 'Whole chapter · $words words',
      tone: sel ? QChipTone.accent : QChipTone.neutral,
      icon: sel ? Icons.text_fields : Icons.article_outlined,
    );
  }

  Widget _body(AssistantSessionState session) {
    if (_applied != null) return _appliedView();
    return switch (session.phase) {
      AssistantPhase.streaming => _streamingView(),
      AssistantPhase.ready => _resultView(session.suggestion!),
      AssistantPhase.error => _errorView(session.errorCode),
      AssistantPhase.idle => _actionsView(),
    };
  }

  // ── Actions view ───────────────────────────────────────────────────────────

  Widget _actionsView() {
    final QTokens tokens = QTokens.of(context);
    final bool hasOperand = widget.target.context.hasOperand;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!hasOperand)
            Padding(
              padding: const EdgeInsets.only(bottom: QSpacing.s3),
              child: Text(
                'Write or select some text, then pick an action.',
                style: TextStyle(color: tokens.colors.textSecondary),
              ),
            ),
          Wrap(
            spacing: QSpacing.s2,
            runSpacing: QSpacing.s2,
            children: <Widget>[
              _quickAction('Continue', Icons.arrow_forward, AssistantActionKind.continueWriting),
              _quickAction('Rewrite', Icons.autorenew, AssistantActionKind.rewrite),
              _quickAction('Expand', Icons.unfold_more, AssistantActionKind.expand),
              _quickAction('Condense', Icons.unfold_less, AssistantActionKind.condense),
              _quickAction('Simplify', Icons.spellcheck, AssistantActionKind.simplify),
              _menuChip('Improve…', Icons.tune, _pickImprove),
              _menuChip('Tone…', Icons.palette_outlined, _pickTone),
            ],
          ),
          Gap.v4,
          _askField(),
          Gap.v3,
          _historyRow(),
        ],
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, AssistantActionKind kind) => QChip(
        label: label,
        icon: icon,
        onTap: widget.target.context.hasOperand ? () => _run(WritingAction.of(kind)) : null,
      );

  Widget _menuChip(String label, IconData icon, Future<void> Function() onTap) => QChip(
        label: label,
        icon: icon,
        onTap: widget.target.context.hasOperand ? () => unawaited(onTap()) : null,
      );

  Widget _askField() {
    final QTokens tokens = QTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Ask the assistant', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            TextButton.icon(
              onPressed: () => unawaited(_openPromptLibrary()),
              icon: const Icon(Icons.library_books_outlined, size: 16),
              label: const Text('Prompts'),
            ),
          ],
        ),
        Gap.v1,
        TextField(
          controller: _ask,
          minLines: 1,
          maxLines: 4,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'e.g. Make this more vivid…',
            filled: true,
            fillColor: tokens.colors.bgRaised,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.send, color: tokens.colors.accent),
              tooltip: 'Ask AI',
              onPressed: _ask.text.trim().isEmpty ? null : _runFreeform,
            ),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _ask.text.trim().isEmpty ? null : _runFreeform(),
        ),
      ],
    );
  }

  Widget _historyRow() {
    final PromptLibraryState lib = ref.watch(promptLibraryControllerProvider);
    if (lib.history.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Recent', style: Theme.of(context).textTheme.labelMedium),
        Gap.v1,
        Wrap(
          spacing: QSpacing.s2,
          runSpacing: QSpacing.s1,
          children: <Widget>[
            for (final String h in lib.history.take(4))
              QChip(
                label: h.length > 28 ? '${h.substring(0, 28)}…' : h,
                onTap: () {
                  _ask.text = h;
                  setState(() {});
                },
              ),
          ],
        ),
      ],
    );
  }

  // ── Streaming view ───────────────────────────────────────────────────────────

  Widget _streamingView() {
    final AiStreamState stream = ref.watch(aiStreamControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: SingleChildScrollView(
            reverse: true,
            child: stream.text.isEmpty
                ? const _ThinkingIndicator()
                : AiStreamingText(text: stream.text),
          ),
        ),
        Gap.v3,
        Align(
          alignment: Alignment.centerRight,
          child: QButton(
            label: 'Stop',
            icon: Icons.stop_circle_outlined,
            variant: QButtonVariant.ghost,
            onPressed: () => ref.read(assistantSessionControllerProvider.notifier).cancel(),
          ),
        ),
      ],
    );
  }

  // ── Result view ────────────────────────────────────────────────────────────

  Widget _resultView(AiSuggestion suggestion) {
    final QTokens tokens = QTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(suggestion.sourceLabel, style: Theme.of(context).textTheme.labelLarge),
            ),
            if (!suggestion.diff.isNoChange && suggestion.originalText.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() => _showDiff = !_showDiff),
                icon: Icon(_showDiff ? Icons.notes : Icons.difference_outlined, size: 16),
                label: Text(_showDiff ? 'Preview' : 'Compare'),
              ),
          ],
        ),
        Gap.v1,
        Flexible(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(QSpacing.s3),
            decoration: BoxDecoration(
              color: tokens.colors.bgRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tokens.colors.border),
            ),
            child: SingleChildScrollView(
              child: _showDiff
                  ? SuggestionDiffView(diff: suggestion.diff)
                  : AiMarkdown(suggestion.content),
            ),
          ),
        ),
        TokenUsageLine(
          usage: suggestion.usage,
          provider: suggestion.provider,
          model: suggestion.model,
        ),
        Gap.v3,
        _actionBar(suggestion),
      ],
    );
  }

  Widget _actionBar(AiSuggestion suggestion) {
    final bool canReplace = widget.target.canReplaceSelection;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        QButton(
          label: switch (suggestion.placement) {
            AiSuggestionPlacement.replaceSelection => 'Apply (replace selection)',
            AiSuggestionPlacement.insertBelow => 'Apply (insert below)',
            AiSuggestionPlacement.append => 'Apply (append)',
          },
          icon: Icons.check,
          variant: QButtonVariant.primary,
          block: true,
          onPressed: () => _apply(suggestion, suggestion.placement),
        ),
        Gap.v2,
        Wrap(
          spacing: QSpacing.s2,
          runSpacing: QSpacing.s2,
          children: <Widget>[
            if (canReplace)
              _barChip('Replace selection', Icons.find_replace,
                  () => _apply(suggestion, AiSuggestionPlacement.replaceSelection)),
            _barChip('Insert below', Icons.subdirectory_arrow_right,
                () => _apply(suggestion, AiSuggestionPlacement.insertBelow)),
            _barChip('Append', Icons.vertical_align_bottom,
                () => _apply(suggestion, AiSuggestionPlacement.append)),
            _barChip('Copy', Icons.copy, () => _copy(suggestion.content)),
            _barChip('Save as draft', Icons.note_add_outlined, () => unawaited(_saveDraft(suggestion))),
            _barChip('Regenerate', Icons.refresh,
                () => unawaited(ref.read(assistantSessionControllerProvider.notifier).regenerate())),
            _barChip('Discard', Icons.close, _discard),
          ],
        ),
      ],
    );
  }

  Widget _barChip(String label, IconData icon, VoidCallback onTap) =>
      QChip(label: label, icon: icon, onTap: onTap);

  // ── Applied / error views ────────────────────────────────────────────────────

  Widget _appliedView() {
    final QTokens tokens = QTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Gap.v3,
        Icon(Icons.check_circle_outline, size: 40, color: tokens.colors.success),
        Gap.v2,
        Center(
          child: Text('Applied to your draft', style: Theme.of(context).textTheme.titleMedium),
        ),
        Gap.v1,
        Center(
          child: Text(
            'Your editor, autosave, and version history updated as if you typed it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.colors.textSecondary),
          ),
        ),
        Gap.v4,
        Row(
          children: <Widget>[
            Expanded(
              child: QButton(
                label: 'Undo',
                icon: Icons.undo,
                onPressed: _undo,
              ),
            ),
            const SizedBox(width: QSpacing.s2),
            Expanded(
              child: QButton(
                label: 'Done',
                variant: QButtonVariant.primary,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _errorView(String? code) {
    final QTokens tokens = QTokens.of(context);
    final AiErrorCopy copy = AiErrorCopy.forCode(code);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Gap.v2,
        Icon(Icons.error_outline, size: 36, color: tokens.colors.danger),
        Gap.v2,
        Center(child: Text(copy.title, style: Theme.of(context).textTheme.titleMedium)),
        Gap.v1,
        Center(
          child: Text(copy.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.colors.textSecondary)),
        ),
        Gap.v4,
        Row(
          children: <Widget>[
            Expanded(
              child: QButton(
                label: 'Back',
                onPressed: () => ref.read(assistantSessionControllerProvider.notifier).reset(),
              ),
            ),
            if (copy.canRetry) ...<Widget>[
              const SizedBox(width: QSpacing.s2),
              Expanded(
                child: QButton(
                  label: 'Try again',
                  variant: QButtonVariant.primary,
                  onPressed: () =>
                      unawaited(ref.read(assistantSessionControllerProvider.notifier).regenerate()),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _run(WritingAction action) {
    unawaited(
      ref.read(assistantSessionControllerProvider.notifier).runAction(action, widget.target.context),
    );
  }

  void _runFreeform() {
    final String instruction = _ask.text.trim();
    if (instruction.isEmpty) return;
    unawaited(ref.read(promptLibraryControllerProvider.notifier).recordUse(instruction));
    unawaited(
      ref.read(assistantSessionControllerProvider.notifier).runAction(
            WritingAction.of(AssistantActionKind.freeform),
            widget.target.context,
            instruction: instruction,
          ),
    );
  }

  Future<void> _pickImprove() async {
    final ImproveAspect? aspect = await _pickOption<ImproveAspect>(
      title: 'Improve…',
      options: ImproveAspect.values,
      label: (ImproveAspect a) => a.label,
    );
    if (aspect != null) _run(WritingAction.improve(aspect));
  }

  Future<void> _pickTone() async {
    final WritingTone? tone = await _pickOption<WritingTone>(
      title: 'Adjust tone…',
      options: WritingTone.values,
      label: (WritingTone t) => t.label,
    );
    if (tone != null) _run(WritingAction.tone(tone));
  }

  Future<T?> _pickOption<T>({
    required String title,
    required List<T> options,
    required String Function(T) label,
  }) =>
      QBottomSheet.show<T>(
        context,
        builder: (BuildContext sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(QSpacing.s4),
                child: Text(title, style: Theme.of(sheetContext).textTheme.titleMedium),
              ),
              for (final T option in options)
                ListTile(
                  title: Text(label(option)),
                  onTap: () => Navigator.of(sheetContext).pop(option),
                ),
              Gap.v2,
            ],
          ),
        ),
      );

  Future<void> _openPromptLibrary() async {
    final PromptPreset? preset = await QBottomSheet.show<PromptPreset>(
      context,
      builder: (BuildContext sheetContext) {
        final PromptLibraryState lib = ref.read(promptLibraryControllerProvider);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(QSpacing.s4),
                child: Text('Prompt library', style: Theme.of(sheetContext).textTheme.titleMedium),
              ),
              for (final PromptPreset p in lib.presets)
                ListTile(
                  leading: Icon(p.isBuiltIn ? Icons.star_border : Icons.edit_note),
                  title: Text(p.title),
                  subtitle: Text(p.instruction, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.of(sheetContext).pop(p),
                ),
            ],
          ),
        );
      },
    );
    if (preset != null) {
      _ask.text = preset.instruction;
      setState(() {});
    }
  }

  void _apply(AiSuggestion suggestion, AiSuggestionPlacement placement) {
    final AiApplyHandle? handle = switch (placement) {
      AiSuggestionPlacement.replaceSelection => widget.target.replaceSelection(suggestion.content),
      AiSuggestionPlacement.insertBelow => widget.target.insertBelow(suggestion.content),
      AiSuggestionPlacement.append => widget.target.append(suggestion.content),
    };
    if (handle == null) {
      QSnackbar.show(context, message: 'Nothing to apply here.', variant: QSnackbarVariant.danger);
      return;
    }
    ref.read(assistantSessionControllerProvider.notifier).markApplied();
    setState(() => _applied = handle);
  }

  void _undo() {
    _applied?.undo();
    setState(() => _applied = null);
    QSnackbar.show(context, message: 'AI change undone.');
  }

  void _copy(String content) {
    unawaited(Clipboard.setData(ClipboardData(text: content)));
    QSnackbar.show(context, message: 'Copied.', variant: QSnackbarVariant.success);
  }

  Future<void> _saveDraft(AiSuggestion suggestion) async {
    final String? id = await widget.target.saveAsNewDraft(suggestion.content);
    if (!mounted) return;
    QSnackbar.show(
      context,
      message: id != null ? 'Saved as a new draft.' : 'Could not save the draft.',
      variant: id != null ? QSnackbarVariant.success : QSnackbarVariant.danger,
    );
  }

  void _discard() {
    ref.read(assistantSessionControllerProvider.notifier).discard();
    Navigator.of(context).maybePop();
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Row(
      children: <Widget>[
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: tokens.colors.accent),
        ),
        const SizedBox(width: QSpacing.s2),
        Text('Thinking…', style: TextStyle(color: tokens.colors.textSecondary)),
      ],
    );
  }
}

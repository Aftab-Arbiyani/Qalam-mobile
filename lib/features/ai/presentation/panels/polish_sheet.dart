/// **Polish** — the in-editor writing tool, shown as a bottom sheet over the editor.
///
/// This is what `writing_assistant_panel.dart` became at **D5** (owner, 2026-09-02).
/// The mechanism is unchanged — it streams a suggestion through the AF1 orchestrator
/// and never touches the document itself, every write routing through the editor's own
/// commands via [AiEditorTarget] — but the *offer* is deliberately much smaller.
///
/// **What left, and why it is not a trim.** The panel used to offer Continue writing,
/// Rewrite, Expand, a tone picker and a free-form "Ask AI" box: that is prose
/// *generation*, and Umberleaf's audience — literary writers and poets — rejects being sold
/// it. What survives are the three actions that work on text the writer has already
/// written: Simplify, Condense, and Improve·{aspect}. The word "AI" appears nowhere a
/// writer can see; what the tool actually does is stated once, plainly, in
/// [ModelDisclosureNote] at the foot.
///
/// The Prompt Library and the "Keep history" conversation binding went with them
/// (D5 removed the conversation layer server-side, B2), so this sheet holds no
/// per-draft state and needs no `routeId`.
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
import '../../../monetization/domain/entities/monetization_enums.dart';
import '../../../monetization/presentation/widgets/premium_gate.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/value_objects/ai_feature_ids.dart';
import '../../domain/value_objects/writing_action.dart';
import '../controllers/ai_stream_controller.dart';
import '../controllers/assistant_session_controller.dart';
import '../editor/ai_editor_target.dart';
import '../support/ai_error_copy.dart';
import '../support/ai_plans_link.dart';
import '../widgets/ai_markdown.dart';
import '../widgets/ai_streaming_text.dart';
import '../widgets/ai_writing_lock_card.dart';
import '../widgets/model_disclosure_note.dart';
import '../widgets/suggestion_diff_view.dart';

class PolishSheet extends ConsumerStatefulWidget {
  const PolishSheet({required this.target, super.key});

  final AiEditorTarget target;

  static Future<void> show(
    BuildContext context, {
    required AiEditorTarget target,
  }) => QBottomSheet.show<void>(
    context,
    builder: (_) => PolishSheet(target: target),
  );

  @override
  ConsumerState<PolishSheet> createState() => _PolishSheetState();
}

class _PolishSheetState extends ConsumerState<PolishSheet> {
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
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final AssistantSessionState session = ref.watch(
      assistantSessionControllerProvider,
    );
    final Size screen = MediaQuery.sizeOf(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screen.height * 0.82),
      // D3: Polish is a paid capability, so the whole sheet body is withheld from a writer
      // whose plan excludes it rather than letting them pick an action and lose it to a 402.
      // The gate fails closed (see `PremiumGate`), and the server re-checks regardless —
      // this is UX, never the security boundary.
      child: PremiumGate(
        feature: PremiumFeature.aiWriting,
        locked: const AiWritingLockCard(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s4,
            0,
            QSpacing.s4,
            QSpacing.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _header(tokens),
              Gap.v2,
              _contextChip(),
              Gap.v3,
              Flexible(child: _body(session)),
              const ModelDisclosureNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(QTokens tokens) => Row(
    children: <Widget>[
      Icon(Icons.brush_outlined, size: 20, color: tokens.colors.accent),
      const SizedBox(width: QSpacing.s2),
      Text('Polish', style: Theme.of(context).textTheme.titleMedium),
    ],
  );

  Widget _contextChip() {
    final bool sel = widget.target.canReplaceSelection;
    final int words = widget.target.context.hasSelection
        ? widget.target.context.selectionText
              .trim()
              .split(RegExp(r'\s+'))
              .where((String w) => w.isNotEmpty)
              .length
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

  /// Every action is one tap. There is no menu chip and no free-text field: the
  /// eight [ImproveAspect]s are laid out flat rather than hidden behind "Improve…",
  /// because with generation gone they are most of what the tool does.
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
              _action(
                'Simplify',
                Icons.spellcheck,
                WritingAction.of(AssistantActionKind.simplify),
              ),
              _action(
                'Condense',
                Icons.unfold_less,
                WritingAction.of(AssistantActionKind.condense),
              ),
            ],
          ),
          Gap.v4,
          Text('Improve', style: Theme.of(context).textTheme.labelLarge),
          Gap.v2,
          Wrap(
            spacing: QSpacing.s2,
            runSpacing: QSpacing.s2,
            children: <Widget>[
              for (final ImproveAspect aspect in ImproveAspect.values)
                _action(
                  aspect.label,
                  Icons.tune,
                  WritingAction.improve(aspect),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(String label, IconData icon, WritingAction action) => QChip(
    label: label,
    icon: icon,
    onTap: widget.target.context.hasOperand ? () => _run(action) : null,
  );

  // ── Streaming view ─────────────────────────────────────────────────────────

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
            onPressed: () =>
                ref.read(assistantSessionControllerProvider.notifier).cancel(),
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
              child: Text(
                suggestion.sourceLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (!suggestion.diff.isNoChange &&
                suggestion.originalText.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() => _showDiff = !_showDiff),
                icon: Icon(
                  _showDiff ? Icons.notes : Icons.difference_outlined,
                  size: 16,
                ),
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
            AiSuggestionPlacement.replaceSelection =>
              'Apply (replace selection)',
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
              _barChip(
                'Replace selection',
                Icons.find_replace,
                () =>
                    _apply(suggestion, AiSuggestionPlacement.replaceSelection),
              ),
            _barChip(
              'Insert below',
              Icons.subdirectory_arrow_right,
              () => _apply(suggestion, AiSuggestionPlacement.insertBelow),
            ),
            _barChip(
              'Append',
              Icons.vertical_align_bottom,
              () => _apply(suggestion, AiSuggestionPlacement.append),
            ),
            _barChip('Copy', Icons.copy, () => _copy(suggestion.content)),
            _barChip(
              'Save as draft',
              Icons.note_add_outlined,
              () => unawaited(_saveDraft(suggestion)),
            ),
            _barChip(
              'Try again',
              Icons.refresh,
              () => unawaited(
                ref
                    .read(assistantSessionControllerProvider.notifier)
                    .regenerate(),
              ),
            ),
            _barChip('Discard', Icons.close, _discard),
          ],
        ),
      ],
    );
  }

  Widget _barChip(String label, IconData icon, VoidCallback onTap) =>
      QChip(label: label, icon: icon, onTap: onTap);

  // ── Applied / error views ──────────────────────────────────────────────────

  Widget _appliedView() {
    final QTokens tokens = QTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Gap.v3,
        Icon(
          Icons.check_circle_outline,
          size: 40,
          color: tokens.colors.success,
        ),
        Gap.v2,
        Center(
          child: Text(
            'Applied to your draft',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
              child: QButton(label: 'Undo', icon: Icons.undo, onPressed: _undo),
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
    // D3: naming the feature is what selects the Polish remedy over a generic one when a
    // 402 or a 429 arrives mid-STREAM — the gate cannot cover that window.
    final AiErrorCopy copy = AiErrorCopy.forCode(
      code,
      feature: AiFeatureIds.writingAssistant,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Gap.v2,
        Icon(Icons.error_outline, size: 36, color: tokens.colors.danger),
        Gap.v2,
        Center(
          child: Text(
            copy.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Gap.v1,
        Center(
          child: Text(
            copy.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.colors.textSecondary),
          ),
        ),
        Gap.v4,
        Row(
          children: <Widget>[
            Expanded(
              child: QButton(
                label: 'Back',
                onPressed: () => ref
                    .read(assistantSessionControllerProvider.notifier)
                    .reset(),
              ),
            ),
            if (copy.canRetry) ...<Widget>[
              const SizedBox(width: QSpacing.s2),
              Expanded(
                child: QButton(
                  label: 'Try again',
                  variant: QButtonVariant.primary,
                  onPressed: () => unawaited(
                    ref
                        .read(assistantSessionControllerProvider.notifier)
                        .regenerate(),
                  ),
                ),
              ),
            ],
            // An entitlement denial is the one blocked state the writer can resolve
            // themselves. The router is read before the sheet closes — `context` is
            // defunct once the pop completes.
            if (copy.canUpgrade) ...<Widget>[
              const SizedBox(width: QSpacing.s2),
              Expanded(
                child: QButton(
                  label: 'See plans',
                  icon: Icons.workspace_premium_outlined,
                  variant: QButtonVariant.primary,
                  onPressed: () => openPlansFromSheet(context),
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
      ref
          .read(assistantSessionControllerProvider.notifier)
          .runAction(action, widget.target.context),
    );
  }

  void _apply(AiSuggestion suggestion, AiSuggestionPlacement placement) {
    final AiApplyHandle? handle = switch (placement) {
      AiSuggestionPlacement.replaceSelection => widget.target.replaceSelection(
        suggestion.content,
      ),
      AiSuggestionPlacement.insertBelow => widget.target.insertBelow(
        suggestion.content,
      ),
      AiSuggestionPlacement.append => widget.target.append(suggestion.content),
    };
    if (handle == null) {
      QSnackbar.show(
        context,
        message: 'Nothing to apply here.',
        variant: QSnackbarVariant.danger,
      );
      return;
    }
    ref.read(assistantSessionControllerProvider.notifier).markApplied();
    setState(() => _applied = handle);
  }

  void _undo() {
    _applied?.undo();
    setState(() => _applied = null);
    QSnackbar.show(context, message: 'Change undone.');
  }

  void _copy(String content) {
    unawaited(Clipboard.setData(ClipboardData(text: content)));
    QSnackbar.show(
      context,
      message: 'Copied.',
      variant: QSnackbarVariant.success,
    );
  }

  Future<void> _saveDraft(AiSuggestion suggestion) async {
    final String? id = await widget.target.saveAsNewDraft(suggestion.content);
    if (!mounted) return;
    QSnackbar.show(
      context,
      message: id != null
          ? 'Saved as a new draft.'
          : 'Could not save the draft.',
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
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: tokens.colors.accent,
          ),
        ),
        const SizedBox(width: QSpacing.s2),
        Text('Working…', style: TextStyle(color: tokens.colors.textSecondary)),
      ],
    );
  }
}

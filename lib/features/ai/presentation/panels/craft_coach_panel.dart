/// The Craft Coach panel (AF2) — a bottom sheet over the editor that runs a coaching
/// lens over the chapter (or a selected scene) through the reused AF1 orchestrator and
/// renders the structured [CoachReport] (score, strengths, weaknesses, suggestions,
/// recommendations, sections). Coaching NEVER edits the document — it only reports.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../domain/value_objects/ai_writing_context.dart';
import '../../domain/value_objects/coach_tool.dart';
import '../controllers/craft_coach_controller.dart';
import '../support/ai_error_copy.dart';
import '../widgets/ai_markdown.dart';
import '../widgets/coach_report_view.dart';
import '../widgets/token_usage_line.dart';

class CraftCoachPanel extends ConsumerWidget {
  const CraftCoachPanel({required this.writingContext, super.key});

  final AiWritingContext writingContext;

  static Future<void> show(BuildContext context, {required AiWritingContext writingContext}) =>
      QBottomSheet.show<void>(
        context,
        builder: (_) => CraftCoachPanel(writingContext: writingContext),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final CraftCoachState state = ref.watch(craftCoachControllerProvider);
    final Size screen = MediaQuery.sizeOf(context);
    final int words = writingContext.hasSelection
        ? writingContext.selectionText.trim().split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length
        : writingContext.wordCount;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screen.height * 0.85),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(QSpacing.s4, 0, QSpacing.s4, QSpacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.school_outlined, size: 20, color: tokens.colors.accent),
                const SizedBox(width: QSpacing.s2),
                Text('Craft coach', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            Gap.v2,
            QChip(
              label: writingContext.hasSelection
                  ? 'Scene selection · $words words'
                  : 'Whole chapter · $words words',
              tone: writingContext.hasSelection ? QChipTone.accent : QChipTone.neutral,
              icon: writingContext.hasSelection ? Icons.text_fields : Icons.article_outlined,
            ),
            Gap.v3,
            Flexible(child: _body(context, ref, state)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, CraftCoachState state) {
    if (!writingContext.hasOperand) {
      return Text(
        'Write some text first, then choose a coaching lens.',
        style: TextStyle(color: QTokens.of(context).colors.textSecondary),
      );
    }
    return switch (state.phase) {
      CoachPhase.idle => _chooser(context, ref),
      CoachPhase.loading => const _CoachProgress(),
      CoachPhase.ready => _report(context, ref, state),
      CoachPhase.rawOnly => _raw(context, ref, state),
      CoachPhase.error => _error(context, ref, state),
    };
  }

  Widget _chooser(BuildContext context, WidgetRef ref) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Choose a lens', style: Theme.of(context).textTheme.labelLarge),
            Gap.v2,
            for (final CraftCoachTool tool in CraftCoachTool.values)
              Padding(
                padding: const EdgeInsets.only(bottom: QSpacing.s2),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tool.label),
                  subtitle: Text(tool.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => unawaited(
                    ref.read(craftCoachControllerProvider.notifier).run(tool, writingContext),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _report(BuildContext context, WidgetRef ref, CraftCoachState state) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(state.tool?.label ?? 'Coaching', style: Theme.of(context).textTheme.labelLarge),
          Gap.v2,
          Flexible(
            child: SingleChildScrollView(child: CoachReportView(report: state.report!)),
          ),
          TokenUsageLine(usage: state.usage, provider: state.provider, model: state.model),
          Gap.v2,
          _footerActions(context, ref),
        ],
      );

  Widget _raw(BuildContext context, WidgetRef ref, CraftCoachState state) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(child: SingleChildScrollView(child: AiMarkdown(state.rawText ?? ''))),
          TokenUsageLine(usage: state.usage, provider: state.provider, model: state.model),
          Gap.v2,
          _footerActions(context, ref),
        ],
      );

  Widget _footerActions(BuildContext context, WidgetRef ref) => Row(
        children: <Widget>[
          Expanded(
            child: QButton(
              label: 'New analysis',
              icon: Icons.refresh,
              onPressed: () => ref.read(craftCoachControllerProvider.notifier).reset(),
            ),
          ),
        ],
      );

  Widget _error(BuildContext context, WidgetRef ref, CraftCoachState state) {
    final QTokens tokens = QTokens.of(context);
    final AiErrorCopy copy = AiErrorCopy.forCode(state.errorCode);
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
                onPressed: () => ref.read(craftCoachControllerProvider.notifier).reset(),
              ),
            ),
            if (copy.canRetry) ...<Widget>[
              const SizedBox(width: QSpacing.s2),
              Expanded(
                child: QButton(
                  label: 'Try again',
                  variant: QButtonVariant.primary,
                  onPressed: () => unawaited(ref.read(craftCoachControllerProvider.notifier).retry()),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CoachProgress extends StatelessWidget {
  const _CoachProgress();

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: QSpacing.s6),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3, color: tokens.colors.accent),
          ),
          Gap.v3,
          Text('Reading your writing…', style: TextStyle(color: tokens.colors.textSecondary)),
        ],
      ),
    );
  }
}

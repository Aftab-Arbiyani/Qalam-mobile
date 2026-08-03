/// Ask My Book / Ask Chapter (AF4) — grounded Q&A over one story's knowledge graph.
/// Streams the answer token-by-token (reusing the shared streaming engine), shows the
/// cited sources, and supports stop + retry. Scope chips cover book/chapter/scene/
/// character/timeline/relationship/world/theme/lore. The answer is grounded in retrieved
/// evidence — never the raw question alone (the backend assembles context).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../domain/entities/ask_answer.dart';
import '../../domain/value_objects/retrieval_requests.dart';
import '../../domain/value_objects/retrieval_vocab.dart';
import '../controllers/ask_book_controller.dart';
import '../support/ai_error_copy.dart';
import '../widgets/ai_markdown.dart' show AiMarkdown;
import '../widgets/ai_streaming_text.dart' show AiStreamingText;

class AskBookScreen extends ConsumerStatefulWidget {
  const AskBookScreen({required this.storyId, super.key});

  final String storyId;

  @override
  ConsumerState<AskBookScreen> createState() => _AskBookScreenState();
}

class _AskBookScreenState extends ConsumerState<AskBookScreen> {
  final TextEditingController _question = TextEditingController();
  AskScope _scope = AskScope.book;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  void _ask() {
    final String q = _question.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    ref
        .read(askBookControllerProvider.notifier)
        .ask(
          AskBookRequest(storyId: widget.storyId, question: q, scope: _scope),
        );
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = ref.watch(appConfigProvider).enableAi;
    final AskBookState state = ref.watch(askBookControllerProvider);

    return QScaffold(
      appBar: const QAppBar(title: 'Ask My Book'),
      body: !enabled
          ? const QEmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'Ask is off',
              message:
                  'Enable AI in settings to ask questions about your story.',
            )
          : ListView(
              padding: const EdgeInsets.all(QSpacing.s4),
              children: <Widget>[
                _ScopeSelector(
                  scope: _scope,
                  onSelect: (AskScope s) => setState(() => _scope = s),
                ),
                Gap.v3,
                QTextField(
                  label: 'Your question',
                  controller: _question,
                  hint: 'e.g. How does Aria change by the end?',
                  minLines: 2,
                  maxLines: 4,
                  contentDirectionAuto: true,
                  onSubmitted: (_) => _ask(),
                ),
                Gap.v3,
                Row(
                  children: <Widget>[
                    Expanded(
                      child: QButton(
                        label: state.isStreaming ? 'Answering…' : 'Ask',
                        icon: Icons.auto_awesome,
                        variant: QButtonVariant.primary,
                        loading: state.isStreaming,
                        onPressed: state.isStreaming ? null : _ask,
                      ),
                    ),
                    if (state.isStreaming) ...<Widget>[
                      Gap.h2,
                      QButton(
                        label: 'Stop',
                        variant: QButtonVariant.ghost,
                        onPressed: () => ref
                            .read(askBookControllerProvider.notifier)
                            .cancel(),
                      ),
                    ],
                  ],
                ),
                Gap.v5,
                _AnswerView(state: state, onRetry: _ask),
              ],
            ),
    );
  }
}

class _ScopeSelector extends StatelessWidget {
  const _ScopeSelector({required this.scope, required this.onSelect});

  final AskScope scope;
  final void Function(AskScope) onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Question scope',
      child: Wrap(
        spacing: QSpacing.s2,
        runSpacing: QSpacing.s2,
        children: <Widget>[
          for (final AskScope s in AskScope.values)
            QChip(
              label: s.label,
              tone: s == scope ? QChipTone.accent : QChipTone.neutral,
              onTap: () => onSelect(s),
            ),
        ],
      ),
    );
  }
}

class _AnswerView extends StatelessWidget {
  const _AnswerView({required this.state, required this.onRetry});

  final AskBookState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;

    switch (state.status) {
      case AskStatus.idle:
        return const QEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'Ask about your story',
          message:
              'Answers are grounded in your story’s knowledge graph and cite their sources.',
          minHeight: 220,
        );
      case AskStatus.error:
        final AiErrorCopy copy = AiErrorCopy.forCode(state.errorCode);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(copy.title, style: text.titleMedium),
            Gap.v1,
            Text(
              copy.message,
              style: text.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
            if (copy.canRetry) ...<Widget>[
              Gap.v3,
              QButton(
                label: 'Try again',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
            // An entitlement denial (as opposed to a spent allowance) is resolved by a
            // plan, not by waiting or retrying — so it is the one blocked state that
            // carries an action.
            if (copy.canUpgrade) ...<Widget>[
              Gap.v3,
              QButton(
                label: 'See plans',
                icon: Icons.workspace_premium_outlined,
                variant: QButtonVariant.primary,
                onPressed: () => context.push(Routes.billingPlans),
              ),
            ],
          ],
        );
      case AskStatus.streaming:
      case AskStatus.done:
      case AskStatus.cancelled:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (state.isStreaming)
              AiStreamingText(
                text: state.answer,
                semanticsLabel: 'Answer, in progress',
              )
            else if (state.answer.isNotEmpty)
              AiMarkdown(state.answer)
            else
              Text(
                'No answer was produced.',
                style: text.bodyMedium?.copyWith(color: colors.textSecondary),
              ),
            if (state.citations.isNotEmpty) ...<Widget>[
              Gap.v4,
              _CitationsList(citations: state.citations),
            ],
          ],
        );
    }
  }
}

class _CitationsList extends StatelessWidget {
  const _CitationsList({required this.citations});

  final List<AskCitation> citations;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: 'Sources, ${citations.length} references',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Sources (${citations.length})', style: text.labelLarge),
          Gap.v2,
          for (final AskCitation c in citations)
            Padding(
              padding: const EdgeInsets.only(bottom: QSpacing.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (c.quote.isNotEmpty)
                    Text(
                      '“${c.quote}”',
                      style: text.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  Gap.v1,
                  Text(
                    c.label,
                    style: text.bodySmall?.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

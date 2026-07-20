/// Suggestions screen (AF6) — the edit-suggestion queue for a story. Renders each
/// suggestion as an original → suggested diff with its rationale, and drives the
/// capability-gated accept / reject (resolver) and withdraw (author) actions. The
/// server applies an accepted suggestion; the client only requests the transition.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/collaboration_enums.dart';
import '../../domain/entities/edit_suggestion.dart';
import '../controllers/collaboration_controller.dart';
import '../domain_labels.dart';
import '../providers/collaboration_providers.dart';
import '../widgets/capability_gate.dart';

class SuggestionsScreen extends ConsumerWidget {
  const SuggestionsScreen({required this.storyId, super.key});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool enabled = ref.watch(appConfigProvider).enableCollaboration;
    return Scaffold(
      appBar: const QAppBar(title: 'Suggestions'),
      body: enabled
          ? _body(context, ref)
          : const QEmptyState(
              icon: Icons.edit_note_outlined,
              title: 'Collaboration is off',
              message: 'Enable collaboration to review proposed edits.',
            ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<EditSuggestion>> async = ref.watch(
      storySuggestionsProvider(storyId),
    );
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => QErrorView(
        failure: _failureOf(error),
        onRetry: () => ref.invalidate(storySuggestionsProvider(storyId)),
      ),
      data: (List<EditSuggestion> suggestions) {
        if (suggestions.isEmpty) {
          return const QEmptyState(
            icon: Icons.edit_note_outlined,
            title: 'No suggestions',
            message: 'Proposed edits from your collaborators will appear here.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(storySuggestionsProvider(storyId)),
          child: ListView.separated(
            padding: QSpacing.pagePadding,
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => Gap.v3,
            itemBuilder: (BuildContext context, int index) => _SuggestionCard(
              storyId: storyId,
              suggestion: suggestions[index],
            ),
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends ConsumerWidget {
  const _SuggestionCard({required this.storyId, required this.suggestion});

  final String storyId;
  final EditSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return QCard(
      padding: QCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  suggestion.authorName ?? suggestion.authorId,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Chip(
                label: Text(suggestionStatusLabel(suggestion.status)),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Gap.v2,
          _DiffLine(
            text: suggestion.originalText,
            color: theme.colorScheme.errorContainer,
            icon: Icons.remove,
          ),
          Gap.v1,
          _DiffLine(
            text: suggestion.suggestedText,
            color: theme.colorScheme.primaryContainer,
            icon: Icons.add,
          ),
          if (suggestion.rationale != null &&
              suggestion.rationale!.isNotEmpty) ...<Widget>[
            Gap.v2,
            Text(suggestion.rationale!, style: theme.textTheme.bodySmall),
          ],
          if (suggestion.isPending) ...<Widget>[
            Gap.v3,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CapabilityGate(
                  storyId: storyId,
                  action: PolicyAction.storySuggest,
                  child: TextButton(
                    onPressed: () => _act(
                      context,
                      ref,
                      () => ref
                          .read(collaborationControllerProvider.notifier)
                          .withdrawSuggestion(suggestion.id),
                      'Suggestion withdrawn.',
                    ),
                    child: const Text('Withdraw'),
                  ),
                ),
                CapabilityGate(
                  storyId: storyId,
                  action: PolicyAction.suggestionResolve,
                  child: Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: () => _act(
                          context,
                          ref,
                          () => ref
                              .read(collaborationControllerProvider.notifier)
                              .rejectSuggestion(suggestion.id),
                          'Suggestion rejected.',
                        ),
                        child: const Text('Reject'),
                      ),
                      Gap.h2,
                      FilledButton(
                        onPressed: () => _act(
                          context,
                          ref,
                          () => ref
                              .read(collaborationControllerProvider.notifier)
                              .acceptSuggestion(suggestion.id),
                          'Suggestion accepted.',
                        ),
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    Future<EditSuggestion?> Function() op,
    String okMessage,
  ) async {
    final EditSuggestion? result = await op();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result == null ? _errorMessage(ref) : okMessage)),
    );
  }
}

class _DiffLine extends StatelessWidget {
  const _DiffLine({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(QSpacing.s2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16),
          Gap.h2,
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

Failure _failureOf(Object error) => error is Failure
    ? error
    : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error');

String _errorMessage(WidgetRef ref) {
  final Object? err = ref.read(collaborationControllerProvider).error;
  return err is Failure ? err.message : 'Something went wrong.';
}

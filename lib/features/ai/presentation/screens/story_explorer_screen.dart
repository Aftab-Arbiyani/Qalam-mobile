/// Story Explorer (AF4) — structured views over the story knowledge graph: Characters,
/// Relationships, Timeline, Locations, Events, Objects, Concepts, and the full Map.
/// Renders directly from graph node/edge objects; tapping a node opens a detail sheet
/// whose neighbours are tappable (interactive navigation between linked entities). An
/// "Ask" action jumps to grounded Q&A for the same story. Cache-backed for offline.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/loading/feed_skeleton_list.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/story_graph.dart';
import '../../domain/value_objects/ai_feature_ids.dart';
import '../../domain/value_objects/retrieval_vocab.dart';
import '../controllers/story_explorer_controller.dart';
import '../providers/ai_providers.dart';
import '../widgets/retrieval_cards.dart';
import '../widgets/story_node_sheet.dart';

class StoryExplorerScreen extends ConsumerStatefulWidget {
  const StoryExplorerScreen({required this.storyId, super.key});

  final String storyId;

  @override
  ConsumerState<StoryExplorerScreen> createState() =>
      _StoryExplorerScreenState();
}

class _StoryExplorerScreenState extends ConsumerState<StoryExplorerScreen> {
  ExplorerView _view = ExplorerView.characters;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ExplorerViewResult> async = ref.watch(
      explorerViewProvider((storyId: widget.storyId, view: _view)),
    );

    // Defect **W9-2**: this action pushed to Ask My Book unconditionally, while the
    // editor's overflow — the only other door — gated the same route on `feature.ai
    // .askBook`. With the flag down (which is every deployment until an admin raises it)
    // it handed the writer a fully-armed Ask screen whose first request 403s.
    //
    // Offered unless the flags say otherwise: an unresolved read leaves the action in
    // place rather than popping it in a frame later, and `AskBookScreen` now resolves the
    // gate itself, so this is the affordance, not the enforcement.
    final AiFeatures? flags = ref.watch(aiFeaturesProvider).asData?.value;
    final bool askOn = flags == null || flags.isEnabled(AiFeatureIds.askBook);

    return QScaffold(
      appBar: QAppBar(
        title: 'Story Explorer',
        actions: <Widget>[
          if (askOn)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Ask about this story',
              onPressed: () => context.push(Routes.aiAskPath(widget.storyId)),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _ViewSelector(
            selected: _view,
            onSelect: (ExplorerView v) => setState(() => _view = v),
          ),
          Expanded(
            child: async.when(
              skipLoadingOnRefresh: true,
              loading: () => const FeedSkeletonList(),
              error: (Object e, _) => QErrorView(
                failure: e is Failure
                    ? e
                    : Failure.unexpected(
                        code: ErrorCodes.apiUnexpected,
                        message: '$e',
                      ),
                onRetry: () => ref.invalidate(
                  explorerViewProvider((storyId: widget.storyId, view: _view)),
                ),
              ),
              data: (ExplorerViewResult result) =>
                  _ExplorerBody(view: _view, result: result),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewSelector extends StatelessWidget {
  const _ViewSelector({required this.selected, required this.onSelect});

  final ExplorerView selected;
  final void Function(ExplorerView) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: QSpacing.s4,
          vertical: QSpacing.s2,
        ),
        children: <Widget>[
          for (final ExplorerView v in ExplorerView.values)
            Padding(
              padding: const EdgeInsets.only(right: QSpacing.s2),
              child: QChip(
                label: v.label,
                tone: v == selected ? QChipTone.accent : QChipTone.neutral,
                onTap: () => onSelect(v),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExplorerBody extends StatelessWidget {
  const _ExplorerBody({required this.view, required this.result});

  final ExplorerView view;
  final ExplorerViewResult result;

  @override
  Widget build(BuildContext context) {
    if (result.nodes.isEmpty) {
      return QEmptyState(
        icon: Icons.hub_outlined,
        title: 'Nothing here yet',
        message: view == ExplorerView.map
            ? 'Analyse this story to build its knowledge graph.'
            : 'No ${view.label.toLowerCase()} found in this story yet.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s4,
        QSpacing.s2,
        QSpacing.s4,
        QSpacing.s6,
      ),
      itemCount: result.nodes.length,
      separatorBuilder: (_, _) => Gap.v3,
      itemBuilder: (BuildContext context, int i) {
        final StoryGraphNode node = result.nodes[i];
        return _NodeTile(
          node: node,
          onTap: () => showStoryNodeSheet(context, node: node, graph: result),
        );
      },
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({required this.node, required this.onTap});

  final StoryGraphNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '${entityTypeLabel(node.type)}: ${node.name}',
      child: QCard(
        padding: QCardPadding.md,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(node.name, style: text.titleSmall),
                  if (node.summary.isNotEmpty) ...<Widget>[
                    Gap.v1,
                    Text(
                      node.summary,
                      style: text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Gap.h2,
            QChip(label: entityTypeLabel(node.type)),
          ],
        ),
      ),
    );
  }
}

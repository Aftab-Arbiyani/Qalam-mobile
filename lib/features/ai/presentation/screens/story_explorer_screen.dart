/// **Story Map** (AF3/AF4) — structured views over the story knowledge graph:
/// Characters, Relationships, Timeline, Locations, Events, Objects, Concepts, and the
/// Overview. Renders directly from graph node/edge objects; tapping a node opens a
/// detail sheet whose neighbours are tappable. Cache-backed for offline.
///
/// **D5 made this screen do something it never could.** It was the Story Explorer, and
/// it was hollow: the graph could only be filled by `POST /story-intelligence/:id/
/// analyze`, which no client anywhere could reach (`platfrom/docs/48` §3.22d), so every
/// view said "nothing here yet" forever. The **"Map this story"** action is the trigger
/// that fills it, and it is why Story Map can headline the Pro tier.
///
/// It needs the story's TEXT, not just its id — the endpoint takes the content so a
/// writer can map an unsaved draft. The editor hands it over as [content] when it
/// pushes this route. Arriving by deep link there is no text, so the action explains
/// itself rather than appearing and failing.
///
/// The "Ask" action went with Ask My Book (D5 decision 4).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/retrieval/domain/retrieval_vocab.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/loading/feed_skeleton_list.dart';
import '../../../../shared/widgets/retrieval/retrieval_cards.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../../monetization/domain/entities/monetization_enums.dart';
import '../../../monetization/presentation/widgets/premium_gate.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/story_graph.dart';
import '../../domain/value_objects/ai_feature_ids.dart';
import '../controllers/story_explorer_controller.dart';
import '../controllers/story_map_controller.dart';
import '../providers/ai_providers.dart';
import '../support/ai_error_copy.dart';
import '../widgets/model_disclosure_note.dart';
import '../widgets/story_node_sheet.dart';

class StoryExplorerScreen extends ConsumerStatefulWidget {
  const StoryExplorerScreen({
    required this.storyId,
    this.content,
    this.storyTitle,
    super.key,
  });

  final String storyId;

  /// The story's full text, handed over by the editor. `null` on a deep link — see the
  /// library docblock; without it "Map this story" has nothing to send.
  final String? content;
  final String? storyTitle;

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

    // **B5 (`platfrom/docs/45` §4.10).** This route carries no feature flag of its own,
    // so the screen consulted the flags only for its Ask action and never for AI itself
    // — a writer who turned AI off could still open it (from a deep link, or a menu
    // rendered before the switch was flipped) onto a screen whose every read 403s.
    // Unresolved reads stay usable, as everywhere else here: the request is authoritative.
    final AiFeatures? flags = ref.watch(aiFeaturesProvider).asData?.value;
    final bool aiOn = flags?.aiEnabled ?? true;
    if (!aiOn) {
      // **D5** merged two states into one. The old copy split "the platform turned AI
      // off" from "you turned AI off", and the second told the writer to turn it back on
      // in Settings \u203A AI — a screen D5 deleted. Copy that names a remedy which no
      // longer exists is worse than copy that names none, so this blames nobody and
      // promises nothing. (The writer really is stuck; that is a recorded residue, not
      // something this sentence can fix.)
      return const QScaffold(
        appBar: QAppBar(title: 'Story Map'),
        body: QEmptyState(
          icon: Icons.hub_outlined,
          title: 'Writing tools aren\u2019t available',
          message: 'They aren\u2019t enabled for this account right now.',
        ),
      );
    }

    // D4 (docs/48 \u00A75.2, decided 2026-08-21): `story_intelligence` is entitlement-gated.
    // With payments dark the entitlement snapshot degrades to deny-everything (no
    // subscription can exist), so an unguarded `PremiumGate` below would read as "needs a
    // paid plan" on a feature that has not shipped yet. Only the BODY is swapped, not the
    // whole screen.
    final bool monetizationOn = ref.watch(appConfigProvider).enableMonetization;

    return QScaffold(
      appBar: const QAppBar(title: 'Story Map'),
      body: !monetizationOn
          ? const QEmptyState(
              icon: Icons.hub_outlined,
              title: 'Story Map isn\u2019t available yet',
              message: 'The story knowledge graph arrives with subscriptions.',
            )
          : PremiumGate(
              feature: PremiumFeature.storyIntelligence,
              child: Column(
                children: <Widget>[
                  _MapRunBar(
                    storyId: widget.storyId,
                    content: widget.content,
                    storyTitle: widget.storyTitle,
                    onMapped: () => ref.invalidate(explorerViewProvider),
                  ),
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
                          explorerViewProvider((
                            storyId: widget.storyId,
                            view: _view,
                          )),
                        ),
                      ),
                      data: (ExplorerViewResult result) =>
                          _ExplorerBody(view: _view, result: result),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// The "Map this story" control, and the run's progress.
///
/// It is the only thing on this screen that WRITES. Everything below it renders a graph
/// that, before D5, nothing could fill.
class _MapRunBar extends ConsumerWidget {
  const _MapRunBar({
    required this.storyId,
    required this.content,
    required this.storyTitle,
    required this.onMapped,
  });

  final String storyId;
  final String? content;
  final String? storyTitle;
  final VoidCallback onMapped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final StoryMapState state = ref.watch(storyMapControllerProvider);

    // A finished run means the graph changed under every view; refetch them all rather
    // than only the one on screen, since the writer is about to page through the others.
    ref.listen<StoryMapState>(storyMapControllerProvider, (
      StoryMapState? previous,
      StoryMapState next,
    ) {
      if (previous?.phase != StoryMapPhase.done &&
          next.phase == StoryMapPhase.done) {
        onMapped();
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s4,
        QSpacing.s3,
        QSpacing.s4,
        0,
      ),
      child: switch (state.phase) {
        StoryMapPhase.running => _running(context, ref, state, tokens),
        StoryMapPhase.error => _error(context, ref, state, tokens),
        StoryMapPhase.idle || StoryMapPhase.done => _trigger(context, ref),
      },
    );
  }

  Widget _trigger(BuildContext context, WidgetRef ref) {
    final String? text = content?.trim();
    // No text means a deep link, not a permission problem — say which, because "Map
    // this story" simply greyed out reads as "you can't", and the writer can.
    if (text == null || text.isEmpty) {
      return Text(
        'Open this story in the editor to map it.',
        style: TextStyle(color: QTokens.of(context).colors.textSecondary),
      );
    }
    return QButton(
      label: 'Map this story',
      icon: Icons.hub_outlined,
      variant: QButtonVariant.primary,
      block: true,
      onPressed: () => unawaited(
        ref
            .read(storyMapControllerProvider.notifier)
            .run(storyId, content: text, storyTitle: storyTitle),
      ),
    );
  }

  Widget _running(
    BuildContext context,
    WidgetRef ref,
    StoryMapState state,
    QTokens tokens,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Mapping\u2026 step ${state.step} of ${state.total}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(storyMapControllerProvider.notifier).cancel(),
            child: const Text('Stop'),
          ),
        ],
      ),
      Gap.v1,
      LinearProgressIndicator(
        value: state.total == 0 ? null : state.step / state.total,
        semanticsLabel: 'Mapping progress',
      ),
      const ModelDisclosureNote(),
    ],
  );

  Widget _error(
    BuildContext context,
    WidgetRef ref,
    StoryMapState state,
    QTokens tokens,
  ) {
    // The quota case is the one worth getting right: the server reserves all five
    // analyses BEFORE the first call, so this is a refusal up front, not a half-built
    // graph. `AiErrorCopy` maps the code to the allowance remedy.
    final AiErrorCopy copy = AiErrorCopy.forCode(
      state.errorCode,
      feature: AiFeatureIds.writingAssistant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          copy.title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: tokens.colors.dangerText),
        ),
        Gap.v1,
        Text(
          copy.message,
          style: TextStyle(color: tokens.colors.textSecondary),
        ),
        if (state.foldedIn > 0) ...<Widget>[
          Gap.v1,
          Text(
            '${state.foldedIn} of ${state.total} finished before it '
            'stopped \u2014 those stayed in your map.',
            style: TextStyle(fontSize: 12, color: tokens.colors.textSecondary),
          ),
        ],
        Gap.v2,
        QButton(
          label: 'Back',
          onPressed: () =>
              ref.read(storyMapControllerProvider.notifier).reset(),
        ),
      ],
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
            ? 'This story hasn\u2019t been mapped yet.'
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

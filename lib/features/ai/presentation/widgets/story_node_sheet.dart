/// Story-node detail sheet (AF4) — renders one knowledge-graph node's structured data
/// + evidence, and its neighbours as tappable chips so the reader can walk the graph
/// (interactive navigation between linked entities, docs 36). Pure presentation over the
/// already-loaded [ExplorerViewResult]; no extra network calls.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../domain/entities/story_graph.dart';
import 'retrieval_cards.dart';

/// Open the detail sheet for [node]. Tapping a neighbour re-opens the sheet for it.
Future<void> showStoryNodeSheet(
  BuildContext context, {
  required StoryGraphNode node,
  required ExplorerViewResult graph,
}) => QBottomSheet.show<void>(
  context,
  builder: (BuildContext context) => _StoryNodeSheet(node: node, graph: graph),
);

class _Neighbour {
  const _Neighbour(this.node, this.relation);
  final StoryGraphNode node;
  final String relation;
}

class _StoryNodeSheet extends StatelessWidget {
  const _StoryNodeSheet({required this.node, required this.graph});

  final StoryGraphNode node;
  final ExplorerViewResult graph;

  List<_Neighbour> _neighbours() {
    final List<_Neighbour> out = <_Neighbour>[];
    final Set<String> seen = <String>{};
    for (final StoryGraphEdge e in graph.edges) {
      final String? otherId = e.sourceId == node.id
          ? e.targetId
          : (e.targetId == node.id ? e.sourceId : null);
      if (otherId == null || !seen.add(otherId)) continue;
      final StoryGraphNode? other = graph.nodeById(otherId);
      if (other != null) {
        out.add(_Neighbour(other, e.label.isEmpty ? e.type : e.label));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    final List<_Neighbour> neighbours = _neighbours();
    final List<MapEntry<String, Object?>> facts = node.data.entries
        .where(
          (MapEntry<String, Object?> e) =>
              e.value != null && '${e.value}'.trim().isNotEmpty,
        )
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(node.name, style: text.titleLarge)),
              Gap.h2,
              QChip(label: entityTypeLabel(node.type), tone: QChipTone.accent),
            ],
          ),
          if (node.aliases.isNotEmpty) ...<Widget>[
            Gap.v1,
            Text(
              'Also: ${node.aliases.join(', ')}',
              style: text.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ],
          if (node.summary.isNotEmpty) ...<Widget>[
            Gap.v3,
            Text(
              node.summary,
              style: text.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ],
          if (facts.isNotEmpty) ...<Widget>[
            Gap.v4,
            Text('Details', style: text.labelLarge),
            Gap.v2,
            for (final MapEntry<String, Object?> f in facts)
              Padding(
                padding: const EdgeInsets.only(bottom: QSpacing.s2),
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: '${entityTypeLabel(f.key)}: ',
                        style: text.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      TextSpan(text: _fmt(f.value), style: text.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
          if (node.evidence.isNotEmpty) ...<Widget>[
            Gap.v4,
            Text('Evidence', style: text.labelLarge),
            Gap.v2,
            for (final StoryGraphEvidence e in node.evidence.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: QSpacing.s2),
                child: Text(
                  '“${e.quote}”${e.chapterRef == null ? '' : ' — ${e.chapterRef}'}',
                  style: text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          if (neighbours.isNotEmpty) ...<Widget>[
            Gap.v4,
            Text('Connected', style: text.labelLarge),
            Gap.v2,
            Wrap(
              spacing: QSpacing.s2,
              runSpacing: QSpacing.s2,
              children: <Widget>[
                for (final _Neighbour n in neighbours.take(20))
                  QChip(
                    label: n.node.name,
                    icon: Icons.link,
                    onTap: () {
                      Navigator.of(context).pop();
                      showStoryNodeSheet(context, node: n.node, graph: graph);
                    },
                  ),
              ],
            ),
          ],
          Gap.v3,
        ],
      ),
    );
  }

  String _fmt(Object? value) {
    if (value is List) return value.map((Object? e) => '$e').join(', ');
    return '$value';
  }
}

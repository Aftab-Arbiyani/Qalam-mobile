/// Shared AF4 presentation bits (docs 36): evidence references (expandable sources),
/// related-entity chips (interactive navigation), and a ranking/score line. Every
/// result/answer surfaces its grounding — the "reference retrieved evidence" contract.
/// Tokens only; accessible (semantic labels, ≥44px targets via QChip).
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../domain/entities/retrieval.dart';

/// Expandable "Sources" list showing the evidence a result/answer is grounded in.
class EvidenceList extends StatelessWidget {
  const EvidenceList({
    required this.evidence,
    this.title = 'Sources',
    super.key,
  });

  final List<RetrievalEvidence> evidence;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (evidence.isEmpty) return const SizedBox.shrink();
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '$title, ${evidence.length} references',
      // Transparent Material so the inner ExpansionTile's ListTile has a valid Material
      // ancestor even though QCard wraps this in a DecoratedBox.
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: QSpacing.s2),
            title: Text('$title (${evidence.length})', style: text.labelLarge),
            children: <Widget>[
              for (final RetrievalEvidence e in evidence)
                Padding(
                  padding: const EdgeInsets.only(bottom: QSpacing.s3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (e.quote.isNotEmpty)
                        Text(
                          '“${e.quote}”',
                          style: text.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      Gap.v1,
                      Text(
                        e.label.isEmpty ? e.source : '${e.label} · ${e.source}',
                        style: text.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Related-entity chips. Tapping a chip navigates to that linked entity.
class RelatedEntitiesRow extends StatelessWidget {
  const RelatedEntitiesRow({
    required this.entities,
    required this.onTap,
    super.key,
  });

  final List<RelatedEntity> entities;
  final void Function(RelatedEntity entity) onTap;

  @override
  Widget build(BuildContext context) {
    if (entities.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: QSpacing.s2,
      runSpacing: QSpacing.s2,
      children: <Widget>[
        for (final RelatedEntity e in entities)
          QChip(
            label: e.relation.isEmpty ? e.name : '${e.name} · ${e.relation}',
            icon: Icons.link,
            onTap: () => onTap(e),
          ),
      ],
    );
  }
}

/// A one-line ranking explanation + relevance meter (why this ranked here).
class RankingLine extends StatelessWidget {
  const RankingLine({required this.summary, required this.score, super.key});

  final String summary;

  /// 0..1 relevance.
  final double score;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    final int pct = (score.clamp(0, 1) * 100).round();
    return Semantics(
      label: 'Relevance $pct percent. ${summary.isEmpty ? '' : summary}',
      child: Row(
        children: <Widget>[
          Icon(Icons.insights, size: 16, color: colors.textMuted),
          Gap.h1,
          Expanded(
            child: Text(
              summary.isEmpty ? 'Relevance $pct%' : '$summary · $pct%',
              style: text.bodySmall?.copyWith(color: colors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

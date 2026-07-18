/// AF4 result + recommendation cards (docs 36 / docs 41). Each renders a structured
/// domain object with its grounding — summary, why-surfaced reason, ranking, evidence,
/// related entities — using Qalam tokens/components. Tapping opens the result; related
/// chips navigate to linked entities. The client only renders; the backend ranks.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../domain/entities/retrieval.dart';
import 'retrieval_widgets.dart';

/// Friendly label for an entity/facet type wire value.
String entityTypeLabel(String type) => switch (type) {
  'piece' => 'Story',
  'author' => 'Author',
  'genre' => 'Genre',
  'tag' => 'Topic',
  'topic' => 'Topic',
  'chapter' => 'Chapter',
  'character' => 'Character',
  'location' => 'Location',
  'event' => 'Event',
  'concept' => 'Concept',
  'object' => 'Object',
  'organization' => 'Organization',
  _ => type.isEmpty ? 'Result' : '${type[0].toUpperCase()}${type.substring(1)}',
};

/// One ranked, grounded search result.
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    required this.item,
    required this.onOpen,
    required this.onRelatedTap,
    super.key,
  });

  final SearchResultItem item;
  final VoidCallback onOpen;
  final void Function(RelatedEntity entity) onRelatedTap;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '${entityTypeLabel(item.type)}: ${item.title}',
      child: QCard(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: Text(item.title, style: text.titleMedium)),
                Gap.h2,
                QChip(
                  label: entityTypeLabel(item.type),
                  tone: QChipTone.accent,
                ),
              ],
            ),
            if (item.summary.isNotEmpty) ...<Widget>[
              Gap.v2,
              Text(
                item.summary,
                style: text.bodyMedium?.copyWith(color: colors.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (item.reason.isNotEmpty) ...<Widget>[
              Gap.v2,
              RankingLine(summary: item.reason, score: item.relevanceScore),
            ],
            if (item.relatedEntities.isNotEmpty) ...<Widget>[
              Gap.v3,
              RelatedEntitiesRow(
                entities: item.relatedEntities,
                onTap: onRelatedTap,
              ),
            ],
            if (item.evidence.isNotEmpty) ...<Widget>[
              Gap.v2,
              EvidenceList(evidence: item.evidence),
            ],
          ],
        ),
      ),
    );
  }
}

/// One explainable recommendation. `compact` fits a horizontal discovery shelf.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    required this.item,
    required this.onOpen,
    this.onRelatedTap,
    this.compact = false,
    super.key,
  });

  final RecommendationItem item;
  final VoidCallback onOpen;
  final void Function(RelatedEntity entity)? onRelatedTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label:
          '${entityTypeLabel(item.targetType)}: ${item.title}. ${item.reason}',
      child: QCard(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.title,
                    style: text.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap.h2,
                QChip(label: entityTypeLabel(item.targetType)),
              ],
            ),
            if (item.summary.isNotEmpty) ...<Widget>[
              Gap.v2,
              Text(
                item.summary,
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (item.reason.isNotEmpty) ...<Widget>[
              Gap.v2,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.auto_awesome, size: 14, color: colors.accent),
                  Gap.h1,
                  Expanded(
                    child: Text(
                      item.reason,
                      style: text.bodySmall?.copyWith(color: colors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (!compact &&
                item.influencedBy.isNotEmpty &&
                onRelatedTap != null) ...<Widget>[
              Gap.v3,
              RelatedEntitiesRow(
                entities: item.influencedBy,
                onTap: onRelatedTap!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

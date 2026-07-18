/// Detail sheet for a search result that has no external route (e.g. a graph node).
/// Renders the result's structured object + evidence + related entities in place, so
/// every result is inspectable even when it isn't a navigable page (AF4, docs 36).
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../domain/entities/retrieval.dart';
import 'retrieval_cards.dart';
import 'retrieval_widgets.dart';

Future<void> showSearchResultSheet(
  BuildContext context,
  SearchResultItem item,
) => QBottomSheet.show<void>(
  context,
  builder: (BuildContext context) => _SearchResultSheet(item: item),
);

class _SearchResultSheet extends StatelessWidget {
  const _SearchResultSheet({required this.item});

  final SearchResultItem item;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(item.title, style: text.titleLarge)),
              Gap.h2,
              QChip(label: entityTypeLabel(item.type), tone: QChipTone.accent),
            ],
          ),
          if (item.summary.isNotEmpty) ...<Widget>[
            Gap.v3,
            Text(
              item.summary,
              style: text.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ],
          if (item.reason.isNotEmpty) ...<Widget>[
            Gap.v3,
            RankingLine(summary: item.reason, score: item.relevanceScore),
          ],
          if (item.relatedEntities.isNotEmpty) ...<Widget>[
            Gap.v4,
            Text('Related', style: text.labelLarge),
            Gap.v2,
            RelatedEntitiesRow(entities: item.relatedEntities, onTap: (_) {}),
          ],
          if (item.evidence.isNotEmpty) ...<Widget>[
            Gap.v3,
            EvidenceList(evidence: item.evidence),
          ],
          Gap.v3,
        ],
      ),
    );
  }
}

/// A response row (docs/40 E7) — title + author + relative time; tapping opens
/// the reader for the response piece. Reused by the responses screen and any
/// response preview. A response is a piece, so navigation is by piece id.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../social/domain/entities/response_item.dart';
import '../../theme/q_tokens.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../../util/relative_time.dart';
import '../cards/q_card.dart';

class ResponseTile extends StatelessWidget {
  const ResponseTile({required this.response, super.key});

  final ResponseItem response;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final String meta = response.respondedAt == null
        ? response.author.displayName
        : '${response.author.displayName} · ${relativeTime(response.respondedAt!)}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QSpacing.s4,
        vertical: QSpacing.s1,
      ),
      child: QCard(
        padding: QCardPadding.md,
        onTap: () => context.push(Routes.piecePath(response.pieceId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              response.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            if (response.subtitle != null && response.subtitle!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                response.subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ],
            Gap.v1,
            Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

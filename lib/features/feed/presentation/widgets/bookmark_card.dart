/// A bookmark row (docs/41 §11.2 compact). The private bookmark feed is
/// lightweight (title + saved-time only), so the card is compact and opens the
/// reader by piece id. Const-friendly, RTL-safe title.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../domain/entities/bookmark_item.dart';

class BookmarkCard extends StatelessWidget {
  const BookmarkCard({required this.item, super.key});

  final BookmarkItem item;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QSpacing.s4,
        vertical: QSpacing.s1,
      ),
      child: Semantics(
        button: true,
        label: 'Bookmarked: ${item.title}',
        child: QCard(
          padding: QCardPadding.md,
          onTap: () => context.push(Routes.piecePath(item.pieceId)),
          child: Row(
            children: <Widget>[
              Icon(Icons.bookmark, size: 20, color: tokens.colors.accent),
              Gap.h3,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saved ${relativeTime(item.bookmarkedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: tokens.colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

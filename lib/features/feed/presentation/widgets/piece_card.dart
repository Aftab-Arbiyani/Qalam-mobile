/// The feed/list piece card (docs/41 §11.2 "feed" variant). Byline → title (2-line
/// clamp, per-piece direction) → excerpt (2-line clamp) → footer (genre chip,
/// language badge, read-time, quiet like count). The whole card is one tap target
/// that opens the reader by id; social actions live on the reading surface (docs/41
/// §35). Const-friendly, RTL-correct, theme-aware.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/content/author_byline.dart';
import '../../domain/entities/piece_summary.dart';

class PieceCard extends ConsumerWidget {
  const PieceCard({required this.piece, super.key});

  final PieceSummary piece;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final String? avatarUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(piece.author.avatarKey);
    final TextDirection dir = piece.direction == TextDirectionKind.rtl
        ? TextDirection.rtl
        : TextDirection.ltr;
    final String? excerpt = _excerpt();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QSpacing.s4,
        vertical: QSpacing.s2,
      ),
      child: Semantics(
        button: true,
        label: '${piece.title}, by ${piece.author.displayName}',
        child: QCard(
          onTap: () => context.push(Routes.piecePath(piece.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AuthorByline(
                name: piece.author.displayName,
                handle: piece.author.handle,
                avatarUrl: avatarUrl,
                meta: piece.publishedAt == null
                    ? null
                    : relativeTime(piece.publishedAt!),
              ),
              Gap.v3,
              Directionality(
                textDirection: dir,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      piece.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                    if (excerpt != null) ...<Widget>[
                      Gap.v1,
                      Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Gap.v3,
              _Footer(piece: piece),
            ],
          ),
        ),
      ),
    );
  }

  String? _excerpt() {
    final String? subtitle = piece.subtitle;
    if (subtitle != null && subtitle.trim().isNotEmpty) return subtitle.trim();
    final String? quote = piece.featuredQuote;
    if (quote != null && quote.trim().isNotEmpty) return quote.trim();
    return null;
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.piece});

  final PieceSummary piece;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final TextStyle? metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: tokens.colors.textSecondary,
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Wrap(
            spacing: QSpacing.s2,
            runSpacing: QSpacing.s1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              if (piece.genre != null && piece.genre!.name.isNotEmpty)
                QChip(label: piece.genre!.name, tone: QChipTone.accent),
              if (piece.language.nativeName.isNotEmpty)
                QChip(label: piece.language.nativeName),
            ],
          ),
        ),
        Gap.h2,
        if (piece.readingTimeMinutes > 0) ...<Widget>[
          Icon(Icons.schedule, size: 14, color: tokens.colors.textMuted),
          const SizedBox(width: 4),
          Text('${piece.readingTimeMinutes}m', style: metaStyle),
          Gap.h3,
        ],
        Icon(Icons.favorite_border, size: 14, color: tokens.colors.textMuted),
        const SizedBox(width: 4),
        Text('${piece.stats.likes}', style: metaStyle),
      ],
    );
  }
}

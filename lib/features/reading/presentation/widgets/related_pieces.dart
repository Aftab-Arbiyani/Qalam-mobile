/// The reader's "More like this" section (docs/48 §3.1, docs/41 §11.19) — up to
/// four other pieces sharing this one's FIRST tag, at the end of the reader.
///
/// A compact link list, deliberately **not** the feed's `PieceCard`: the card is
/// the feed unit (cover, excerpt, stats, its own padding) and would out-weigh the
/// piece the reader is actually on. Same information as web ships: title, author,
/// read time.
///
/// Renders nothing at all — no heading, no skeleton, no error — when there is
/// nothing to suggest: an untagged piece, a failed load, or an empty result. It
/// must never cost the reader the piece they came for.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../domain/entities/piece_detail.dart';
import '../controllers/related_pieces_controller.dart';

class RelatedPieces extends ConsumerWidget {
  const RelatedPieces({required this.piece, super.key});

  final PieceDetail piece;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No tags → no section, and no request either (web disables the query).
    final TagRef? tag = piece.tags.isEmpty ? null : piece.tags.first;
    if (tag == null || tag.slug.isEmpty) return const SizedBox.shrink();

    final List<PieceSummary> related =
        ref
            .watch(relatedPiecesProvider((pieceId: piece.id, tag: tag)))
            .asData
            ?.value ??
        const <PieceSummary>[];
    if (related.isEmpty) return const SizedBox.shrink();

    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      // Owned here, not by the caller: an absent section must leave no gap.
      padding: const EdgeInsets.only(top: QSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'More like this',
            style: theme.textTheme.labelLarge?.copyWith(
              color: tokens.colors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          Gap.v3,
          QCard(
            padding: QCardPadding.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final (int i, PieceSummary p)
                    in related.indexed) ...<Widget>[
                  if (i > 0)
                    Divider(height: QSpacing.s4, color: tokens.colors.border),
                  _RelatedTile(piece: p),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.piece});

  final PieceSummary piece;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final TextDirection dir = piece.direction == TextDirectionKind.rtl
        ? TextDirection.rtl
        : TextDirection.ltr;
    final String readTime = readingTimeLabel(piece.readingTimeMinutes);
    final String meta = <String>[
      piece.author.displayName,
      if (readTime.isNotEmpty) readTime,
    ].join('  ·  ');

    return Semantics(
      button: true,
      label: '${piece.title}, by ${piece.author.displayName}',
      child: InkWell(
        onTap: () => context.push(Routes.piecePath(piece.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: QSpacing.s1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Directionality(
                textDirection: dir,
                child: Text(
                  piece.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Gap.v1,
              Text(
                meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

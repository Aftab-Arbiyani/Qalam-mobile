/// Reusable search-result rows (docs/40 §44 — every result type uses a shared
/// tile). A piece result reuses the shared `PieceCard`; writers, tags, genres and
/// languages get these compact tiles. Writer tiles open the profile (private
/// accounts show a lock teaser); taxonomy tiles hand their selection back to the
/// caller (which pivots the search to filtered pieces). RTL-correct, const-friendly.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/entities/trend_item.dart';
import '../../../../shared/domain/entities/writer_summary.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/content/author_byline.dart';

class WriterResultTile extends ConsumerWidget {
  const WriterResultTile({required this.writer, super.key});

  final WriterSummary writer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final String? avatarUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(writer.avatarKey);
    final String secondary = writer.isPrivate
        ? l10n.searchWriterPrivate
        : (writer.bio != null && writer.bio!.trim().isNotEmpty
              ? writer.bio!.trim()
              : l10n.searchFollowerCount(writer.followersCount));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QSpacing.s4,
        vertical: QSpacing.s1,
      ),
      child: QCard(
        padding: QCardPadding.md,
        onTap: () => context.push(Routes.userProfilePath(writer.username)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: AuthorByline(
                name: writer.displayName,
                handle: writer.handle,
                avatarUrl: avatarUrl,
                meta: secondary,
              ),
            ),
            if (writer.isPrivate)
              Icon(Icons.lock_outline, size: 18, color: tokens.colors.textMuted)
            else
              Icon(
                Icons.chevron_right,
                size: 20,
                color: tokens.colors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

/// A tag / genre / language result: a leading glyph, its name, a piece count, and
/// a chevron. [onTap] lets the caller pivot to filtered piece results.
class TaxonomyResultTile extends StatelessWidget {
  const TaxonomyResultTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
    this.direction = TextDirection.ltr,
    super.key,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;
  final TextDirection direction;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QSpacing.s4,
        vertical: QSpacing.s1,
      ),
      child: QCard(
        padding: QCardPadding.md,
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: tokens.colors.accent),
            Gap.h3,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Directionality(
                    textDirection: direction,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    l10n.searchPieceCount(count),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: tokens.colors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Convenience builders that pick the glyph + direction per taxonomy kind.
TaxonomyResultTile tagResultTile(TrendingTag tag, VoidCallback onTap) =>
    TaxonomyResultTile(
      icon: Icons.tag,
      title: tag.name.isNotEmpty ? tag.name : tag.slug,
      count: tag.pieceCount,
      onTap: onTap,
    );

TaxonomyResultTile genreResultTile(TrendingGenre genre, VoidCallback onTap) =>
    TaxonomyResultTile(
      icon: Icons.category_outlined,
      title: genre.name.isNotEmpty ? genre.name : genre.slug,
      count: genre.pieceCount,
      onTap: onTap,
    );

TaxonomyResultTile languageResultTile(
  TrendingLanguage language,
  VoidCallback onTap,
) => TaxonomyResultTile(
  icon: Icons.translate,
  title: language.nativeName.isNotEmpty ? language.nativeName : language.code,
  count: language.pieceCount,
  onTap: onTap,
  direction: language.direction == TextDirectionKind.rtl
      ? TextDirection.rtl
      : TextDirection.ltr,
);

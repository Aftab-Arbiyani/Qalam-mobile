/// Discovery shelf building blocks (docs/40 §6, docs/41 §11.2 featured). A titled
/// [ShelfSection], an AsyncValue-driven horizontal [DiscoveryShelf] (skeleton while
/// loading; hidden on empty/error — a best-effort surface), and the compact
/// piece/writer shelf cards. Pieces open the reader; writer/tag cards are
/// display-only in M3 (profile browsing is a later epic).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../../../../shared/widgets/media/q_network_image.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/writer_summary.dart';

class ShelfSection extends StatelessWidget {
  const ShelfSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s4,
            QSpacing.s4,
            QSpacing.s4,
            QSpacing.s2,
          ),
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        child,
      ],
    );
  }
}

/// A horizontally-scrolling shelf driven by an [AsyncValue] list.
class DiscoveryShelf<T> extends StatelessWidget {
  const DiscoveryShelf({
    required this.title,
    required this.state,
    required this.itemBuilder,
    required this.itemWidth,
    required this.height,
    super.key,
  });

  final String title;
  final AsyncValue<List<T>> state;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double itemWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return state.when(
      skipLoadingOnRefresh: true,
      loading: () => ShelfSection(title: title, child: _skeletonRow()),
      error: (Object _, StackTrace _) => const SizedBox.shrink(),
      data: (List<T> items) => items.isEmpty
          ? const SizedBox.shrink()
          : ShelfSection(
              title: title,
              child: SizedBox(
                height: height,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: QSpacing.s3),
                  itemBuilder: (BuildContext context, int index) => SizedBox(
                    width: itemWidth,
                    child: itemBuilder(context, items[index]),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _skeletonRow() => SizedBox(
    height: height,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(width: QSpacing.s3),
      itemBuilder: (_, _) => SizedBox(
        width: itemWidth,
        child: QSkeleton(height: height),
      ),
    ),
  );
}

/// A compact featured-piece card for a discovery shelf (cover + title + author).
class PieceShelfCard extends ConsumerWidget {
  const PieceShelfCard({required this.piece, super.key});

  final PieceSummary piece;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final String? coverUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(piece.coverImageKey);
    final TextDirection dir = piece.direction == TextDirectionKind.rtl
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Semantics(
      button: true,
      label: '${piece.title}, by ${piece.author.displayName}',
      child: InkWell(
        borderRadius: QRadii.cardRadius,
        onTap: () => context.push(Routes.piecePath(piece.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: QRadii.cardRadius,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: coverUrl == null
                    ? Container(
                        color: tokens.colors.bgRaised,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(QSpacing.s3),
                        child: Text(
                          piece.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      )
                    : QNetworkImage(url: coverUrl),
              ),
            ),
            Gap.v2,
            Directionality(
              textDirection: dir,
              child: Text(
                piece.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              piece.author.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact writer card for a discovery shelf (display-only in M3).
class WriterShelfCard extends ConsumerWidget {
  const WriterShelfCard({required this.writer, super.key});

  final WriterSummary writer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final String? avatarUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(writer.avatarKey);

    return Semantics(
      label: '${writer.displayName}, ${writer.followersCount} followers',
      child: Column(
        children: <Widget>[
          QAvatar(name: writer.displayName, imageUrl: avatarUrl, size: 56),
          Gap.v2,
          Text(
            writer.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge,
          ),
          Text(
            '${writer.followersCount} followers',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A collection's detail (docs/40 E7) — its pieces, cursor-paginated, with
/// per-piece remove (optimistic). Tapping a piece opens the reader. The header
/// is loaded separately; a failure to load the header still lets the pieces show.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/social/domain/entities/collection.dart';
import '../../../../shared/social/presentation/controllers/collections_controller.dart';
import '../../../../shared/social/social_providers.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({required this.collectionId, super.key});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = collectionPiecesControllerProvider(collectionId);
    final AsyncValue<Collection> header = ref.watch(
      _collectionHeaderProvider(collectionId),
    );

    return QScaffold(
      appBar: QAppBar(
        title: header.asData?.value.title ?? l10n.collectionsTitle,
      ),
      body: PagedFeedView<CollectionPieceItem>(
        state: ref.watch(provider),
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        empty: QEmptyState(
          icon: Icons.bookmark_border,
          title: l10n.collectionEmptyPiecesTitle,
          message: l10n.collectionEmptyPiecesBody,
        ),
        itemBuilder:
            (BuildContext context, CollectionPieceItem item, int index) =>
                _PieceRow(
                  item: item,
                  onRemove: () =>
                      ref.read(provider.notifier).removePiece(item.pieceId),
                ),
      ),
    );
  }
}

class _PieceRow extends StatelessWidget {
  const _PieceRow({required this.item, required this.onRemove});

  final CollectionPieceItem item;
  final VoidCallback onRemove;

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
        onTap: () => context.push(Routes.piecePath(item.pieceId)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      item.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.collectionRemovePiece,
              icon: Icon(Icons.close, size: 18, color: tokens.colors.textMuted),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

/// A tiny per-id header loader for the collection's title (owner-only read).
final _collectionHeaderProvider =
    FutureProvider.family<Collection, String>((ref, String id) async {
      final result = await ref.read(collectionRepositoryProvider).getCollection(id);
      return result.fold(
        (Collection c) => c,
        (Object failure) => throw failure,
      );
    });

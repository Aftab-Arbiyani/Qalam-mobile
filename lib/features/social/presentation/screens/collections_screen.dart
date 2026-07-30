/// The collections screen (docs/40 E7) — the owner's collections / reading lists,
/// cursor-paginated, with create (sheet) and per-card rename / delete. Tapping a
/// collection opens its detail. The default "Favorites" collection can't be
/// renamed or deleted (its menu is hidden). Reuses the shared [PagedFeedView].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/social/domain/entities/collection.dart';
import '../../../../shared/social/presentation/controllers/collections_controller.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_dialog.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/social/collection_form_sheet.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = collectionsControllerProvider;

    return QScaffold(
      appBar: QAppBar(
        title: l10n.collectionsTitle,
        actions: <Widget>[
          IconButton(
            tooltip: l10n.collectionCreate,
            icon: const Icon(Icons.add),
            onPressed: () => showCollectionFormSheet(context),
          ),
        ],
      ),
      body: PagedFeedView<Collection>(
        state: ref.watch(provider),
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        empty: QEmptyState(
          icon: Icons.collections_bookmark_outlined,
          title: l10n.collectionsEmptyTitle,
          message: l10n.collectionsEmptyBody,
        ),
        itemBuilder: (BuildContext context, Collection c, int index) =>
            _CollectionCard(collection: c),
      ),
    );
  }
}

class _CollectionCard extends ConsumerWidget {
  const _CollectionCard({required this.collection});

  final Collection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        onTap: () =>
            context.push(Routes.collectionDetailPath(collection.id)),
        child: Row(
          children: <Widget>[
            Icon(
              collection.isDefault
                  ? Icons.star_outline
                  : Icons.collections_bookmark_outlined,
              color: tokens.colors.accent,
            ),
            Gap.h3,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          collection.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (collection.isPrivate) ...<Widget>[
                        Gap.h2,
                        QChip(
                          label: l10n.collectionPrivateLabel,
                          icon: Icons.lock_outline,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    l10n.collectionPieceCount(collection.piecesCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!collection.isDefault)
              PopupMenuButton<String>(
                onSelected: (String action) =>
                    _onAction(context, ref, action),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'rename',
                    child: Text(l10n.collectionRename),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(l10n.collectionDelete),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (action == 'rename') {
      await showCollectionFormSheet(context, existing: collection);
    } else if (action == 'delete') {
      final bool ok = await QDialog.confirm(
        context,
        title: l10n.collectionDeleteConfirmTitle,
        message: l10n.collectionDeleteConfirmBody,
        confirmLabel: l10n.collectionDelete,
        destructive: true,
      );
      if (ok) {
        await ref
            .read(collectionsControllerProvider.notifier)
            .deleteCollection(collection.id);
      }
    }
  }
}

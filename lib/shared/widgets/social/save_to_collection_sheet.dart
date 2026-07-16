/// The "save to collection" sheet (docs/40 E7) — lists the owner's collections
/// (the shared [CollectionsController]) and adds [pieceId] to the tapped one, with
/// an inline "New collection" affordance. Presented via the shared [QBottomSheet].
/// Adding is confirmed with a snackbar; the collection's cached pieces are evicted
/// by the repository so its detail reloads fresh.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../domain/error_codes.dart';
import '../../pagination/paged_list_state.dart';
import '../../social/domain/entities/collection.dart';
import '../../social/presentation/controllers/collections_controller.dart';
import '../../social/social_providers.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../feedback/q_bottom_sheet.dart';
import '../feedback/q_snackbar.dart';
import '../haptics/q_haptics.dart';
import '../states/q_error_view.dart';
import 'collection_form_sheet.dart';

Future<void> showSaveToCollectionSheet(
  BuildContext context, {
  required String pieceId,
}) => QBottomSheet.show<void>(
  context,
  builder: (BuildContext context) => _SaveToCollectionSheet(pieceId: pieceId),
);

/// A thrown paginator error is already a [Failure]; convert defensively.
Failure _asFailure(Object e) => e is Failure
    ? e
    : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: e.toString());

class _SaveToCollectionSheet extends ConsumerWidget {
  const _SaveToCollectionSheet({required this.pieceId});

  final String pieceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AsyncValue<PagedListState<Collection>> state = ref.watch(
      collectionsControllerProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          QSpacing.s4,
          QSpacing.s4,
          QSpacing.s4,
          QSpacing.s5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  l10n.saveToCollectionTitle,
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _createAndSave(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.collectionCreate),
                ),
              ],
            ),
            Gap.v2,
            Flexible(
              child: state.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(QSpacing.s5),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (Object e, _) => QErrorView(
                  failure: _asFailure(e),
                  onRetry: () =>
                      ref.read(collectionsControllerProvider.notifier).refresh(),
                ),
                data: (PagedListState<Collection> paged) => paged.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(QSpacing.s4),
                        child: Text(
                          l10n.collectionsEmptyBody,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          for (final Collection c in paged.items)
                            ListTile(
                              leading: Icon(
                                c.isDefault
                                    ? Icons.star_outline
                                    : Icons.collections_bookmark_outlined,
                              ),
                              title: Text(c.title),
                              subtitle: Text(l10n.collectionPieceCount(c.piecesCount)),
                              onTap: () => _save(context, ref, c),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    Collection collection,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await QHaptics.selection();
    final result = await ref
        .read(collectionRepositoryProvider)
        .addPiece(collection.id, pieceId);
    if (!context.mounted) return;
    QSnackbar.show(
      context,
      message: result.isOk
          ? l10n.saveToCollectionAdded(collection.title)
          : l10n.socialActionFailed,
      variant: result.isOk ? QSnackbarVariant.success : QSnackbarVariant.danger,
    );
    Navigator.of(context).pop();
  }

  Future<void> _createAndSave(BuildContext context, WidgetRef ref) async {
    final Collection? created = await showCollectionFormSheet(context);
    if (created == null || !context.mounted) return;
    await _save(context, ref, created);
  }
}

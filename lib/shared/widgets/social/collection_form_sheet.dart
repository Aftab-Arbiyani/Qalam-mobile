/// The create / rename collection sheet (docs/40 E7). A name (required),
/// description (optional) and private toggle; saves through the shared
/// [CollectionsController] (create or rename) and pops the resulting [Collection]
/// so a caller (e.g. save-to-collection) can chain. The default "Favorites"
/// collection can't be renamed, so callers don't pass it here.
library;

import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/enums.dart';
import '../../domain/limits.dart';
import '../../social/domain/entities/collection.dart';
import '../../social/presentation/controllers/collections_controller.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../buttons/q_button.dart';
import '../feedback/q_bottom_sheet.dart';
import '../feedback/q_snackbar.dart';
import '../inputs/q_text_field.dart';

/// Present the collection form. [existing] non-null → rename mode. Returns the
/// created/updated collection, or null if cancelled/failed.
Future<Collection?> showCollectionFormSheet(
  BuildContext context, {
  Collection? existing,
}) => QBottomSheet.show<Collection>(
  context,
  builder: (BuildContext context) => _CollectionFormSheet(existing: existing),
);

class _CollectionFormSheet extends ConsumerStatefulWidget {
  const _CollectionFormSheet({this.existing});

  final Collection? existing;

  @override
  ConsumerState<_CollectionFormSheet> createState() =>
      _CollectionFormSheetState();
}

class _CollectionFormSheetState extends ConsumerState<_CollectionFormSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late bool _private = widget.existing?.isPrivate ?? true;
  bool _saving = false;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _canSave = _name.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool renaming = widget.existing != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          QSpacing.s4,
          QSpacing.s4,
          QSpacing.s4,
          QSpacing.s5 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              renaming ? l10n.collectionRename : l10n.collectionCreateTitle,
              style: theme.textTheme.titleLarge,
            ),
            Gap.v4,
            QTextField(
              label: l10n.collectionNameLabel,
              controller: _name,
              hint: l10n.collectionNameHint,
              maxLength: Limits.collectionNameMax,
              contentDirectionAuto: true,
              onChanged: (String v) {
                final bool can = v.trim().isNotEmpty;
                if (can != _canSave) setState(() => _canSave = can);
              },
            ),
            Gap.v3,
            QTextField(
              label: l10n.collectionDescriptionLabel,
              controller: _description,
              maxLength: Limits.collectionDescriptionMax,
              maxLines: 3,
              minLines: 2,
              contentDirectionAuto: true,
            ),
            Gap.v3,
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.collectionMakePrivate),
              value: _private,
              onChanged: renaming
                  ? null
                  : (bool v) => setState(() => _private = v),
            ),
            Gap.v4,
            SizedBox(
              width: double.infinity,
              child: QButton(
                label: l10n.collectionSave,
                variant: QButtonVariant.primary,
                loading: _saving,
                onPressed: _canSave && !_saving ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final controller = ref.read(collectionsControllerProvider.notifier);
    final String title = _name.text.trim();
    final String? description = _description.text.trim().isEmpty
        ? null
        : _description.text.trim();
    final result = widget.existing == null
        ? await controller.create(
            title: title,
            description: description,
            visibility: _private ? Visibility.private : Visibility.public,
          )
        : await controller.rename(
            widget.existing!.id,
            title: title,
            description: description,
          );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (Collection c) => Navigator.of(context).pop(c),
      (Object _) => QSnackbar.show(
        context,
        message: AppLocalizations.of(context).socialActionFailed,
        variant: QSnackbarVariant.danger,
      ),
    );
  }
}

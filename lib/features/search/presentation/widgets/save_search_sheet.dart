/// "Save this search" — name it, then keep it.
///
/// Saved searches existed server-side and on-device long before **D5**; what they
/// never had on mobile was a door. They lived on the semantic-search screen behind the
/// `/ai` prefix, which D5 deleted — so without this the feature would have been quietly
/// removed rather than de-branded, and a reader's saved searches would have become
/// unreachable data.
///
/// The name is the dedup key on both sides, so saving twice under one name replaces
/// rather than duplicates. The default offered is the query itself, which is what a
/// reader means most of the time.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/retrieval/domain/saved_search.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../controllers/saved_searches_controller.dart';

Future<void> showSaveSearchSheet(BuildContext context, String query) =>
    QBottomSheet.show<void>(
      context,
      builder: (_) => _SaveSearchSheet(query: query),
    );

class _SaveSearchSheet extends ConsumerStatefulWidget {
  const _SaveSearchSheet({required this.query});

  final String query;

  @override
  ConsumerState<_SaveSearchSheet> createState() => _SaveSearchSheetState();
}

class _SaveSearchSheetState extends ConsumerState<_SaveSearchSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.query,
  );
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);

    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final Result<SavedSearch> result = await ref
        .read(savedSearchesControllerProvider.notifier)
        .save(name: name, query: widget.query);
    if (!mounted) return;
    setState(() => _saving = false);

    // Pop first, then report: the sheet's own context is defunct once its route is
    // gone, and a snackbar shown into it would never appear.
    unawaited(navigator.maybePop());
    QSnackbar.show(
      context,
      message: result.isOk ? l10n.searchSaveDone : l10n.searchSaveFailed,
      variant: result.isOk ? QSnackbarVariant.success : QSnackbarVariant.danger,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s4,
        0,
        QSpacing.s4,
        QSpacing.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.searchSaveTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Gap.v3,
          TextField(
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.searchSaveNameLabel,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
          Gap.v4,
          QButton(
            label: l10n.searchSaveSubmit,
            variant: QButtonVariant.primary,
            block: true,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_badge.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_dialog.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/inputs/q_search_field.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../../../../shared/widgets/states/q_error_view.dart';

/// Design-system gallery (docs/41) — a debug surface that renders the component
/// catalog for visual verification and golden tests. Not a product screen.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return QScaffold(
      appBar: QAppBar(title: l10n.galleryTitle),
      body: ListView(
        padding: QSpacing.pagePadding,
        children: <Widget>[
          _section('Buttons'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              QButton(
                label: 'Primary',
                variant: QButtonVariant.primary,
                onPressed: () {},
              ),
              QButton(label: 'Secondary', onPressed: () {}),
              QButton(
                label: 'Ghost',
                variant: QButtonVariant.ghost,
                onPressed: () {},
              ),
              QButton(
                label: 'Danger',
                variant: QButtonVariant.danger,
                onPressed: () {},
              ),
              const QButton(label: 'Disabled'),
              const QButton(label: 'Loading', loading: true),
            ],
          ),
          Gap.v3,
          QButton(
            label: 'Block',
            variant: QButtonVariant.primary,
            block: true,
            icon: Icons.check,
            onPressed: () {},
          ),
          _section('Inputs'),
          QTextField(
            label: 'Label',
            hint: 'Type here…',
            controller: _textController,
          ),
          Gap.v4,
          QSearchField(controller: _searchController, hint: 'Search…'),
          _section('Chips & badges'),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              QChip(label: 'Neutral'),
              QChip(label: 'Accent', tone: QChipTone.accent),
              QChip(label: 'Success', tone: QChipTone.success),
              QChip(label: 'Danger', tone: QChipTone.danger),
              QBadge.count(count: 3, semanticLabel: '3 unread'),
              QBadge.dot(semanticLabel: 'unread'),
            ],
          ),
          _section('Card & avatar'),
          QCard(
            child: Row(
              children: <Widget>[
                const QAvatar(name: 'Farheen Q'),
                Gap.h3,
                Expanded(
                  child: Text(
                    'A card surface with a hairline border and warm shadow.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          _section('Skeletons'),
          const QPieceCardSkeleton(),
          _section('Feedback'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              QButton(
                label: 'Snackbar',
                onPressed: () => QSnackbar.show(context, message: 'Saved.'),
              ),
              QButton(
                label: 'Dialog',
                onPressed: () async {
                  await QHaptics.selection();
                  if (!context.mounted) return;
                  await QDialog.confirm(
                    context,
                    title: 'Discard?',
                    message: 'This cannot be undone.',
                    destructive: true,
                    confirmLabel: 'Discard',
                  );
                },
              ),
              QButton(
                label: 'Sheet',
                onPressed: () => QBottomSheet.show<void>(
                  context,
                  builder: (BuildContext context) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'A bottom sheet — the default mobile choice surface.',
                    ),
                  ),
                ),
              ),
            ],
          ),
          _section('Error state'),
          SizedBox(
            height: 320,
            child: QErrorView(
              failure: const Failure.unexpected(
                code: 'DEMO',
                requestId: 'req_demo_1234',
              ),
              onRetry: () {},
            ),
          ),
          Gap.v6,
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

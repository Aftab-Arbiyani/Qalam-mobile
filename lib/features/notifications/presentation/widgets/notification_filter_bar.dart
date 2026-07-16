/// The status-filter chip row for the inbox (docs/41 §37 — "filterable by
/// status"). A horizontally-scrolling set of chips (All / Unread / Read /
/// Archived); the selected one is accent-toned. Stateless — the screen owns the
/// selected [NotificationFilter] and swaps the controller family on change.
library;

import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../domain/value_objects/notification_filter.dart';

class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.colors.border)),
      ),
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: QSpacing.s4,
            vertical: QSpacing.s2,
          ),
          itemCount: NotificationFilter.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: QSpacing.s2),
          itemBuilder: (BuildContext context, int index) {
            final NotificationFilter filter = NotificationFilter.values[index];
            final bool isSelected = filter == selected;
            return Semantics(
              selected: isSelected,
              button: true,
              child: QChip(
                label: _label(l10n, filter),
                tone: isSelected ? QChipTone.accent : QChipTone.neutral,
                onTap: isSelected ? null : () => onSelected(filter),
              ),
            );
          },
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n, NotificationFilter filter) =>
      switch (filter) {
        NotificationFilter.all => l10n.notificationsFilterAll,
        NotificationFilter.unread => l10n.notificationsFilterUnread,
        NotificationFilter.read => l10n.notificationsFilterRead,
        NotificationFilter.archived => l10n.notificationsFilterArchived,
      };
}

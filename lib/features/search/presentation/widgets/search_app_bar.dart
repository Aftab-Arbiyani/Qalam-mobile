/// The search screen's app bar (docs/41 §16) — an animated search field plus a
/// filter affordance. The field grows a soft accent focus-ring when focused
/// (static under reduced motion), and the filter button (results phase only)
/// carries a count badge of active filters. Query state is owned by the screen /
/// [SearchQueryController]; this widget is presentation-only.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/motion/motion.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/motion_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_badge.dart';
import '../../../../shared/widgets/inputs/q_search_field.dart';
import '../controllers/search_controller.dart';
import '../controllers/search_filters_controller.dart';

class SearchAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SearchAppBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onOpenFilters,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onOpenFilters;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final SearchPhase phase = ref.watch(
      searchQueryControllerProvider.select((SearchState s) => s.phase),
    );
    final int filterCount = ref.watch(
      searchFiltersControllerProvider.select((s) => s.activeCount),
    );
    final bool showFilters = phase == SearchPhase.results;

    return Material(
      color: tokens.colors.bgCanvas,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s4,
            QSpacing.s2,
            QSpacing.s4,
            QSpacing.s2,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AnimatedBuilder(
                  animation: focusNode,
                  builder: (BuildContext context, Widget? child) {
                    final bool focused = focusNode.hasFocus;
                    return AnimatedContainer(
                      duration: Motion.duration(context, QDurations.fast),
                      curve: QCurves.standard,
                      decoration: BoxDecoration(
                        borderRadius: QRadii.controlRadius,
                        border: Border.all(
                          color: focused
                              ? tokens.colors.accent
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: QSearchField(
                    controller: controller,
                    focusNode: focusNode,
                    hint: l10n.searchHint,
                    clearTooltip: l10n.searchClearTooltip,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    onClear: onClear,
                  ),
                ),
              ),
              if (showFilters) ...<Widget>[
                Gap.h2,
                _FilterButton(
                  count: filterCount,
                  label: l10n.searchFiltersButton,
                  onPressed: onOpenFilters,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.count,
    required this.label,
    required this.onPressed,
  });

  final int count;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: count > 0 ? '$label, $count active' : label,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        isSelected: count > 0,
        icon: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            const Icon(Icons.tune),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                // The outer Semantics already announces the count.
                child: ExcludeSemantics(
                  child: QBadge.count(count: count, semanticLabel: '$count'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

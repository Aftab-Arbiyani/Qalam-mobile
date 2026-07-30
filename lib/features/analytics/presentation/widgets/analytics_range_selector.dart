/// The analytics range selector (docs/40 §30) — a horizontally scrollable row of
/// preset pills (Today / Last 7 / 30 / 90 days / Last year) plus a Custom pill that
/// opens a date-range picker. Drives [AnalyticsRangeController]; the growth chart
/// re-fetches on change. Each pill is a semantics button announcing its selected
/// state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../domain/value_objects/analytics_range.dart';
import '../controllers/analytics_range_controller.dart';

class AnalyticsRangeSelector extends ConsumerWidget {
  const AnalyticsRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnalyticsRange range = ref.watch(analyticsRangeControllerProvider);
    final AnalyticsRangeController controller = ref.read(
      analyticsRangeControllerProvider.notifier,
    );

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: <Widget>[
          for (final AnalyticsRangePreset preset in AnalyticsRangePreset.values)
            Padding(
              padding: const EdgeInsets.only(right: QSpacing.s2),
              child: _RangePill(
                label: preset == AnalyticsRangePreset.custom
                    ? range.label
                    : preset.label,
                selected: range.preset == preset,
                onTap: () async {
                  await QHaptics.selection();
                  if (preset == AnalyticsRangePreset.custom) {
                    if (!context.mounted) return;
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      controller.selectCustom(picked.start, picked.end);
                    }
                  } else {
                    controller.select(preset);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? tokens.colors.accent : tokens.colors.bgSurface,
        borderRadius: QRadii.controlRadius,
        child: InkWell(
          borderRadius: QRadii.controlRadius,
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: QSpacing.s3),
            decoration: BoxDecoration(
              borderRadius: QRadii.controlRadius,
              border: Border.all(
                color: selected ? tokens.colors.accent : tokens.colors.border,
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? tokens.colors.accentContrast
                    : tokens.colors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

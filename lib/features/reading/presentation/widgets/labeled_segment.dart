/// A labeled segmented control (docs/41 §35, §28) — a section label above a
/// full-width [SegmentedButton]. Shared by the reader settings sheet and the
/// appearance settings screen so the reading-preference controls look and behave
/// identically wherever they're surfaced. Generic over the option type.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/tokens/spacing_tokens.dart';

class LabeledSegment<T> extends StatelessWidget {
  const LabeledSegment({
    required this.label,
    required this.value,
    required this.segments,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final List<(T, String)> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.labelLarge),
        Gap.v2,
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            showSelectedIcon: false,
            segments: <ButtonSegment<T>>[
              for (final (T v, String text) segment in segments)
                ButtonSegment<T>(value: segment.$1, label: Text(segment.$2)),
            ],
            selected: <T>{value},
            onSelectionChanged: (Set<T> selection) =>
                onChanged(selection.first),
          ),
        ),
      ],
    );
  }
}

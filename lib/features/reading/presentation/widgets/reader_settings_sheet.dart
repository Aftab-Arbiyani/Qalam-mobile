/// Reader settings sheet (docs/41 §35) — reachable without leaving the flow;
/// changes apply live. Adjusts reading font size, line spacing, and column width
/// (persisted per-device via [ReaderPreferencesController]) and the app theme
/// (via [ThemeModeController]). Accessible segmented controls throughout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme_mode_controller.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../domain/value_objects/reader_preferences.dart';
import '../controllers/reader_preferences_controller.dart';

class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ReaderPreferences prefs = ref.watch(
      readerPreferencesControllerProvider,
    );
    final ReaderPreferencesController controller = ref.read(
      readerPreferencesControllerProvider.notifier,
    );
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          QSpacing.s4,
          QSpacing.s2,
          QSpacing.s4,
          QSpacing.s5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Reading settings', style: theme.textTheme.titleMedium),
            Gap.v4,
            _Section<ReadingFontSize>(
              label: 'Text size',
              value: prefs.fontSize,
              segments: const <(ReadingFontSize, String)>[
                (ReadingFontSize.small, 'S'),
                (ReadingFontSize.medium, 'M'),
                (ReadingFontSize.large, 'L'),
              ],
              onChanged: (ReadingFontSize v) {
                QHaptics.selection();
                controller.setFontSize(v);
              },
            ),
            Gap.v4,
            _Section<ReadingLineHeight>(
              label: 'Line spacing',
              value: prefs.lineHeight,
              segments: const <(ReadingLineHeight, String)>[
                (ReadingLineHeight.compact, 'Compact'),
                (ReadingLineHeight.normal, 'Normal'),
                (ReadingLineHeight.relaxed, 'Relaxed'),
              ],
              onChanged: (ReadingLineHeight v) {
                QHaptics.selection();
                controller.setLineHeight(v);
              },
            ),
            Gap.v4,
            _Section<ReadingWidth>(
              label: 'Reading width',
              value: prefs.width,
              segments: const <(ReadingWidth, String)>[
                (ReadingWidth.narrow, 'Narrow'),
                (ReadingWidth.medium, 'Medium'),
                (ReadingWidth.wide, 'Wide'),
              ],
              onChanged: (ReadingWidth v) {
                QHaptics.selection();
                controller.setWidth(v);
              },
            ),
            Gap.v4,
            _Section<ThemeMode>(
              label: 'Theme',
              value: themeMode,
              segments: const <(ThemeMode, String)>[
                (ThemeMode.light, 'Light'),
                (ThemeMode.dark, 'Dark'),
                (ThemeMode.system, 'System'),
              ],
              onChanged: (ThemeMode v) {
                QHaptics.selection();
                ref.read(themeModeControllerProvider.notifier).set(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Section<T> extends StatelessWidget {
  const _Section({
    required this.label,
    required this.value,
    required this.segments,
    required this.onChanged,
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

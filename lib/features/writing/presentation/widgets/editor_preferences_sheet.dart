/// The editor-preferences sheet (M4). Adjusts the writing surface — font size,
/// line spacing, column width, surface theme, and the autosave toggle — persisted
/// per device via [EditorPreferencesController]. Applies live to the open editor.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../domain/value_objects/editor_preferences.dart';
import '../controllers/editor_preferences_controller.dart';

class EditorPreferencesSheet extends ConsumerWidget {
  const EditorPreferencesSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final EditorPreferences prefs = ref.watch(
      editorPreferencesControllerProvider,
    );
    final EditorPreferencesController notifier = ref.read(
      editorPreferencesControllerProvider.notifier,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s5,
        QSpacing.s2,
        QSpacing.s5,
        QSpacing.s6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Editor settings', style: theme.textTheme.titleLarge),
          Gap.v5,
          _Segmented<EditorFontSize>(
            label: 'Font size',
            value: prefs.fontSize,
            options: EditorFontSize.values,
            labelOf: (EditorFontSize v) => switch (v) {
              EditorFontSize.small => 'Small',
              EditorFontSize.medium => 'Medium',
              EditorFontSize.large => 'Large',
            },
            onChanged: notifier.setFontSize,
          ),
          Gap.v4,
          _Segmented<EditorLineHeight>(
            label: 'Line spacing',
            value: prefs.lineHeight,
            options: EditorLineHeight.values,
            labelOf: (EditorLineHeight v) => switch (v) {
              EditorLineHeight.compact => 'Compact',
              EditorLineHeight.normal => 'Normal',
              EditorLineHeight.relaxed => 'Relaxed',
            },
            onChanged: notifier.setLineHeight,
          ),
          Gap.v4,
          _Segmented<EditorWidth>(
            label: 'Width',
            value: prefs.width,
            options: EditorWidth.values,
            labelOf: (EditorWidth v) => switch (v) {
              EditorWidth.narrow => 'Narrow',
              EditorWidth.medium => 'Medium',
              EditorWidth.wide => 'Wide',
            },
            onChanged: notifier.setWidth,
          ),
          Gap.v4,
          _Segmented<EditorSurface>(
            label: 'Theme',
            value: prefs.surface,
            options: EditorSurface.values,
            labelOf: (EditorSurface v) => switch (v) {
              EditorSurface.system => 'System',
              EditorSurface.sepia => 'Sepia',
              EditorSurface.dark => 'Dark',
            },
            onChanged: notifier.setSurface,
          ),
          Gap.v3,
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Autosave',
              style: TextStyle(color: tokens.colors.textPrimary),
            ),
            subtitle: Text(
              'Save changes automatically as you write.',
              style: TextStyle(color: tokens.colors.textSecondary),
            ),
            value: prefs.autosaveEnabled,
            onChanged: notifier.setAutosaveEnabled,
          ),
        ],
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.label,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: tokens.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.v2,
        SegmentedButton<T>(
          showSelectedIcon: false,
          segments: <ButtonSegment<T>>[
            for (final T option in options)
              ButtonSegment<T>(value: option, label: Text(labelOf(option))),
          ],
          selected: <T>{value},
          onSelectionChanged: (Set<T> s) => onChanged(s.first),
        ),
      ],
    );
  }
}

/// Appearance & reading settings (docs/40 §8.4, docs/41 §35) at `/settings/appearance`.
/// A full-screen home for the reading-preference controls that previously only lived
/// in the in-reader sheet — theme, text size, line spacing, reading width — plus two
/// app preferences new to M5: the default home-feed tab and media autoplay. Every
/// control persists locally (device-scoped, never synced) and applies live.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/preferences/app_preferences_controllers.dart';
import '../../../../shared/preferences/default_feed.dart';
import '../../../../shared/theme/theme_mode_controller.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/settings/settings_tiles.dart';
import '../../domain/value_objects/reader_preferences.dart';
import '../controllers/reader_preferences_controller.dart';
import '../widgets/labeled_segment.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReaderPreferences prefs = ref.watch(
      readerPreferencesControllerProvider,
    );
    final ReaderPreferencesController reader = ref.read(
      readerPreferencesControllerProvider.notifier,
    );
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);
    final DefaultFeed defaultFeed = ref.watch(defaultFeedControllerProvider);
    final bool autoplay = ref.watch(autoplayMediaControllerProvider);

    return QScaffold(
      appBar: const QAppBar(title: 'Appearance & reading'),
      body: ListView(
        padding: QSpacing.pagePadding,
        children: <Widget>[
          LabeledSegment<ThemeMode>(
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
          Gap.v5,
          LabeledSegment<ReadingFontSize>(
            label: 'Text size',
            value: prefs.fontSize,
            segments: const <(ReadingFontSize, String)>[
              (ReadingFontSize.small, 'S'),
              (ReadingFontSize.medium, 'M'),
              (ReadingFontSize.large, 'L'),
            ],
            onChanged: (ReadingFontSize v) {
              QHaptics.selection();
              reader.setFontSize(v);
            },
          ),
          Gap.v5,
          LabeledSegment<ReadingLineHeight>(
            label: 'Line spacing',
            value: prefs.lineHeight,
            segments: const <(ReadingLineHeight, String)>[
              (ReadingLineHeight.compact, 'Compact'),
              (ReadingLineHeight.normal, 'Normal'),
              (ReadingLineHeight.relaxed, 'Relaxed'),
            ],
            onChanged: (ReadingLineHeight v) {
              QHaptics.selection();
              reader.setLineHeight(v);
            },
          ),
          Gap.v5,
          LabeledSegment<ReadingWidth>(
            label: 'Reading width',
            value: prefs.width,
            segments: const <(ReadingWidth, String)>[
              (ReadingWidth.narrow, 'Narrow'),
              (ReadingWidth.medium, 'Medium'),
              (ReadingWidth.wide, 'Wide'),
            ],
            onChanged: (ReadingWidth v) {
              QHaptics.selection();
              reader.setWidth(v);
            },
          ),
          Gap.v5,
          LabeledSegment<DefaultFeed>(
            label: 'Default feed',
            value: defaultFeed,
            segments: const <(DefaultFeed, String)>[
              (DefaultFeed.forYou, 'For you'),
              (DefaultFeed.following, 'Following'),
              (DefaultFeed.trending, 'Trending'),
              (DefaultFeed.latest, 'Latest'),
            ],
            onChanged: (DefaultFeed v) {
              QHaptics.selection();
              ref.read(defaultFeedControllerProvider.notifier).set(v);
            },
          ),
          Gap.v5,
          QSettingsSection(
            title: 'Media',
            children: <Widget>[
              QSettingsSwitchTile(
                icon: Icons.play_circle_outline,
                title: 'Autoplay media',
                subtitle: 'Play media automatically where available.',
                value: autoplay,
                onChanged: (bool v) =>
                    ref.read(autoplayMediaControllerProvider.notifier).set(v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

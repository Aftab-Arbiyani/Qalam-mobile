/// Device-preference controllers (docs/40 §8.4, §26.1) — keep-alive UI-state
/// notifiers over the shared `prefs` box, cross-cutting so any feature reads them
/// (mirroring `themeModeController`). Each change persists immediately and survives
/// navigation, restart, and logout. Client/UI state, never synced.
///
/// - [defaultFeedController] — the landing home-feed tab (read by the feed screen).
/// - [autoplayMediaController] — media autoplay opt-in (no consumer yet; a future
///   extension point).
/// - [contentPrivacyController] — whether the owner shows their reading-history /
///   bookmarks tiles on their own profile.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import 'content_privacy.dart';
import 'default_feed.dart';

part 'app_preferences_controllers.g.dart';

@Riverpod(keepAlive: true)
class DefaultFeedController extends _$DefaultFeedController {
  @override
  DefaultFeed build() =>
      DefaultFeed.fromWire(ref.watch(preferencesStoreProvider).defaultFeed);

  Future<void> set(DefaultFeed value) async {
    await ref.read(preferencesStoreProvider).setDefaultFeed(value.wire);
    state = value;
  }
}

@Riverpod(keepAlive: true)
class AutoplayMediaController extends _$AutoplayMediaController {
  @override
  bool build() => ref.watch(preferencesStoreProvider).autoplayMedia;

  Future<void> set(bool value) async {
    await ref.read(preferencesStoreProvider).setAutoplayMedia(value);
    state = value;
  }
}

@Riverpod(keepAlive: true)
class ContentPrivacyController extends _$ContentPrivacyController {
  @override
  ContentPrivacy build() {
    final prefs = ref.watch(preferencesStoreProvider);
    return ContentPrivacy(
      showReadingHistory: prefs.showReadingHistory,
      showBookmarks: prefs.showBookmarks,
    );
  }

  Future<void> setShowReadingHistory(bool value) async {
    await ref.read(preferencesStoreProvider).setShowReadingHistory(value);
    state = state.copyWith(showReadingHistory: value);
  }

  Future<void> setShowBookmarks(bool value) async {
    await ref.read(preferencesStoreProvider).setShowBookmarks(value);
    state = state.copyWith(showBookmarks: value);
  }
}

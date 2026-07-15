import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/shared/preferences/app_preferences_controllers.dart';
import 'package:qalam_mobile/shared/preferences/default_feed.dart';

import '../../support/harness.dart';

void main() {
  test(
    'DefaultFeedController defaults to For You and persists a change',
    () async {
      final ProviderContainer c = await buildTestContainer();
      addTearDown(c.dispose);
      c.listen(defaultFeedControllerProvider, (_, _) {});

      expect(c.read(defaultFeedControllerProvider), DefaultFeed.forYou);
      await c
          .read(defaultFeedControllerProvider.notifier)
          .set(DefaultFeed.latest);
      expect(c.read(defaultFeedControllerProvider), DefaultFeed.latest);
      expect(c.read(preferencesStoreProvider).defaultFeed, 'latest');
    },
  );

  test('AutoplayMediaController defaults off and toggles', () async {
    final ProviderContainer c = await buildTestContainer();
    addTearDown(c.dispose);
    c.listen(autoplayMediaControllerProvider, (_, _) {});

    expect(c.read(autoplayMediaControllerProvider), isFalse);
    await c.read(autoplayMediaControllerProvider.notifier).set(true);
    expect(c.read(autoplayMediaControllerProvider), isTrue);
    expect(c.read(preferencesStoreProvider).autoplayMedia, isTrue);
  });

  test('ContentPrivacyController defaults on and toggles each flag', () async {
    final ProviderContainer c = await buildTestContainer();
    addTearDown(c.dispose);
    c.listen(contentPrivacyControllerProvider, (_, _) {});

    expect(c.read(contentPrivacyControllerProvider).showReadingHistory, isTrue);
    expect(c.read(contentPrivacyControllerProvider).showBookmarks, isTrue);

    await c
        .read(contentPrivacyControllerProvider.notifier)
        .setShowReadingHistory(false);
    await c
        .read(contentPrivacyControllerProvider.notifier)
        .setShowBookmarks(false);

    expect(
      c.read(contentPrivacyControllerProvider).showReadingHistory,
      isFalse,
    );
    expect(c.read(contentPrivacyControllerProvider).showBookmarks, isFalse);
    expect(c.read(preferencesStoreProvider).showReadingHistory, isFalse);
  });
}

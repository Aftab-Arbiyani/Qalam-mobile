import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/session/onboarding_controller.dart';

import '../../support/harness.dart';

void main() {
  test('reflects the persisted flag on build', () async {
    final ProviderContainer container = await buildTestContainer(
      onboardingComplete: false,
    );
    addTearDown(container.dispose);
    expect(container.read(onboardingControllerProvider), isFalse);
  });

  test('complete() persists and flips the flag once', () async {
    final ProviderContainer container = await buildTestContainer(
      onboardingComplete: false,
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.notifier).complete();

    expect(container.read(onboardingControllerProvider), isTrue);
    expect(container.read(preferencesStoreProvider).onboardingComplete, isTrue);
  });
}

/// Onboarding completion state (docs/40 §11.5, M2) — a keep-alive flag mirroring
/// the persisted `onboardingComplete` preference. It lives in `core` (not the
/// onboarding feature) because the router guard and the launch-phase provider
/// read it; a feature-owned provider would force a cross-feature/app import.
///
/// The onboarding *screen* (the carousel + its transient page index) is the
/// feature; this is only the durable "have they seen it" bit.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/providers.dart';

part 'onboarding_controller.g.dart';

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  bool build() => ref.watch(preferencesStoreProvider).onboardingComplete;

  /// Mark onboarding seen/skipped — persisted so it shows exactly once per
  /// install. Flipping this re-runs the router redirect (the router listens).
  Future<void> complete() async {
    if (state) return;
    await ref.read(preferencesStoreProvider).setOnboardingComplete(true);
    state = true;
  }
}

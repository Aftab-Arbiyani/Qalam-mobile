// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_launch.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive launch phase — recomputes when the session resolves or onboarding
/// completes. `keepAlive` because it mirrors the two keep-alive sources it reads.

@ProviderFor(appLaunchPhase)
final appLaunchPhaseProvider = AppLaunchPhaseProvider._();

/// Reactive launch phase — recomputes when the session resolves or onboarding
/// completes. `keepAlive` because it mirrors the two keep-alive sources it reads.

final class AppLaunchPhaseProvider
    extends $FunctionalProvider<AppLaunchPhase, AppLaunchPhase, AppLaunchPhase>
    with $Provider<AppLaunchPhase> {
  /// Reactive launch phase — recomputes when the session resolves or onboarding
  /// completes. `keepAlive` because it mirrors the two keep-alive sources it reads.
  AppLaunchPhaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLaunchPhaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLaunchPhaseHash();

  @$internal
  @override
  $ProviderElement<AppLaunchPhase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLaunchPhase create(Ref ref) {
    return appLaunchPhase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLaunchPhase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLaunchPhase>(value),
    );
  }
}

String _$appLaunchPhaseHash() => r'3b4f5be0ccc5865f903881762fb2b6015bb521d7';

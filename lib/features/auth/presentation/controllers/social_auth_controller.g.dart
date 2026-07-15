// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialAuthController)
final socialAuthControllerProvider = SocialAuthControllerProvider._();

final class SocialAuthControllerProvider
    extends $NotifierProvider<SocialAuthController, SocialAuthState> {
  SocialAuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialAuthControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialAuthControllerHash();

  @$internal
  @override
  SocialAuthController create() => SocialAuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialAuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialAuthState>(value),
    );
  }
}

String _$socialAuthControllerHash() =>
    r'b984cb3a9222ac639df18cdc393536fdb1c0aa31';

abstract class _$SocialAuthController extends $Notifier<SocialAuthState> {
  SocialAuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SocialAuthState, SocialAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SocialAuthState, SocialAuthState>,
              SocialAuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

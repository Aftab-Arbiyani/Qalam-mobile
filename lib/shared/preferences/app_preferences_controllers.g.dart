// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preferences_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DefaultFeedController)
final defaultFeedControllerProvider = DefaultFeedControllerProvider._();

final class DefaultFeedControllerProvider
    extends $NotifierProvider<DefaultFeedController, DefaultFeed> {
  DefaultFeedControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultFeedControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultFeedControllerHash();

  @$internal
  @override
  DefaultFeedController create() => DefaultFeedController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DefaultFeed value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DefaultFeed>(value),
    );
  }
}

String _$defaultFeedControllerHash() =>
    r'0d90f03fbdf1c3f1ffaf51e94c195e452a3d6c2a';

abstract class _$DefaultFeedController extends $Notifier<DefaultFeed> {
  DefaultFeed build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DefaultFeed, DefaultFeed>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DefaultFeed, DefaultFeed>,
              DefaultFeed,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(AutoplayMediaController)
final autoplayMediaControllerProvider = AutoplayMediaControllerProvider._();

final class AutoplayMediaControllerProvider
    extends $NotifierProvider<AutoplayMediaController, bool> {
  AutoplayMediaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoplayMediaControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoplayMediaControllerHash();

  @$internal
  @override
  AutoplayMediaController create() => AutoplayMediaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$autoplayMediaControllerHash() =>
    r'ada7883cf33fb16ed5d0ecd11b897643caedc2cc';

abstract class _$AutoplayMediaController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ContentPrivacyController)
final contentPrivacyControllerProvider = ContentPrivacyControllerProvider._();

final class ContentPrivacyControllerProvider
    extends $NotifierProvider<ContentPrivacyController, ContentPrivacy> {
  ContentPrivacyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentPrivacyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentPrivacyControllerHash();

  @$internal
  @override
  ContentPrivacyController create() => ContentPrivacyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentPrivacy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentPrivacy>(value),
    );
  }
}

String _$contentPrivacyControllerHash() =>
    r'7b37414a10c9886331c8e858c1bff8d229eda722';

abstract class _$ContentPrivacyController extends $Notifier<ContentPrivacy> {
  ContentPrivacy build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ContentPrivacy, ContentPrivacy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContentPrivacy, ContentPrivacy>,
              ContentPrivacy,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

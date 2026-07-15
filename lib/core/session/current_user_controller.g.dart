// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentUserController)
final currentUserControllerProvider = CurrentUserControllerProvider._();

final class CurrentUserControllerProvider
    extends $NotifierProvider<CurrentUserController, CurrentUser?> {
  CurrentUserControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserControllerHash();

  @$internal
  @override
  CurrentUserController create() => CurrentUserController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrentUser? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrentUser?>(value),
    );
  }
}

String _$currentUserControllerHash() =>
    r'6e806b6a44231fa56c685b113d95e7751c58426f';

abstract class _$CurrentUserController extends $Notifier<CurrentUser?> {
  CurrentUser? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CurrentUser?, CurrentUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CurrentUser?, CurrentUser?>,
              CurrentUser?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

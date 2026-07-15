// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_stats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileStatsController)
final profileStatsControllerProvider = ProfileStatsControllerProvider._();

final class ProfileStatsControllerProvider
    extends $AsyncNotifierProvider<ProfileStatsController, ProfileStats> {
  ProfileStatsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileStatsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileStatsControllerHash();

  @$internal
  @override
  ProfileStatsController create() => ProfileStatsController();
}

String _$profileStatsControllerHash() =>
    r'7a415c640c160f11409f45149063780d89a548c6';

abstract class _$ProfileStatsController extends $AsyncNotifier<ProfileStats> {
  FutureOr<ProfileStats> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ProfileStats>, ProfileStats>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProfileStats>, ProfileStats>,
              AsyncValue<ProfileStats>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

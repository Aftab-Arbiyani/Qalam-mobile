// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_searches_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecentSearchesController)
final recentSearchesControllerProvider = RecentSearchesControllerProvider._();

final class RecentSearchesControllerProvider
    extends $NotifierProvider<RecentSearchesController, List<RecentSearch>> {
  RecentSearchesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesControllerHash();

  @$internal
  @override
  RecentSearchesController create() => RecentSearchesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RecentSearch> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RecentSearch>>(value),
    );
  }
}

String _$recentSearchesControllerHash() =>
    r'9c1a514ac929fa8ed51fa647cb198660eaf4a6a8';

abstract class _$RecentSearchesController
    extends $Notifier<List<RecentSearch>> {
  List<RecentSearch> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<RecentSearch>, List<RecentSearch>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<RecentSearch>, List<RecentSearch>>,
              List<RecentSearch>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

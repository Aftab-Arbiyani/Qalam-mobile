// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_searches_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavedSearchesController)
final savedSearchesControllerProvider = SavedSearchesControllerProvider._();

final class SavedSearchesControllerProvider
    extends $NotifierProvider<SavedSearchesController, List<SavedSearch>> {
  SavedSearchesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedSearchesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedSearchesControllerHash();

  @$internal
  @override
  SavedSearchesController create() => SavedSearchesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedSearch> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedSearch>>(value),
    );
  }
}

String _$savedSearchesControllerHash() =>
    r'80e9443fb7024dbdd40924bbca4741859f403383';

abstract class _$SavedSearchesController extends $Notifier<List<SavedSearch>> {
  List<SavedSearch> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<SavedSearch>, List<SavedSearch>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SavedSearch>, List<SavedSearch>>,
              List<SavedSearch>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

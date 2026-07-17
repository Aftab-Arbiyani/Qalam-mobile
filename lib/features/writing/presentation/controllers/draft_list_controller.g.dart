// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DraftListController)
final draftListControllerProvider = DraftListControllerProvider._();

final class DraftListControllerProvider
    extends $AsyncNotifierProvider<DraftListController, List<DraftSummary>> {
  DraftListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftListControllerHash();

  @$internal
  @override
  DraftListController create() => DraftListController();
}

String _$draftListControllerHash() =>
    r'74df60dbc4f4992aea2831e63f977229413a08ef';

abstract class _$DraftListController
    extends $AsyncNotifier<List<DraftSummary>> {
  FutureOr<List<DraftSummary>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<DraftSummary>>, List<DraftSummary>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DraftSummary>>, List<DraftSummary>>,
              AsyncValue<List<DraftSummary>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(draftSyncSummary)
final draftSyncSummaryProvider = DraftSyncSummaryProvider._();

final class DraftSyncSummaryProvider
    extends $FunctionalProvider<SyncSummary, SyncSummary, SyncSummary>
    with $Provider<SyncSummary> {
  DraftSyncSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftSyncSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftSyncSummaryHash();

  @$internal
  @override
  $ProviderElement<SyncSummary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncSummary create(Ref ref) {
    return draftSyncSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncSummary>(value),
    );
  }
}

String _$draftSyncSummaryHash() => r'cecd10c54beb0c26b28729fb9b26ab82e1e5eb29';

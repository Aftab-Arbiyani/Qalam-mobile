// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedListController)
final feedListControllerProvider = FeedListControllerFamily._();

final class FeedListControllerProvider
    extends
        $AsyncNotifierProvider<
          FeedListController,
          PagedListState<PieceSummary>
        > {
  FeedListControllerProvider._({
    required FeedListControllerFamily super.from,
    required FeedTab super.argument,
  }) : super(
         retry: null,
         name: r'feedListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedListControllerHash();

  @override
  String toString() {
    return r'feedListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FeedListController create() => FeedListController();

  @override
  bool operator ==(Object other) {
    return other is FeedListControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedListControllerHash() =>
    r'f1af24e8ee4f2f2002a3458841c1b795ada89ec9';

final class FeedListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FeedListController,
          AsyncValue<PagedListState<PieceSummary>>,
          PagedListState<PieceSummary>,
          FutureOr<PagedListState<PieceSummary>>,
          FeedTab
        > {
  FeedListControllerFamily._()
    : super(
        retry: null,
        name: r'feedListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedListControllerProvider call(FeedTab tab) =>
      FeedListControllerProvider._(argument: tab, from: this);

  @override
  String toString() => r'feedListControllerProvider';
}

abstract class _$FeedListController
    extends $AsyncNotifier<PagedListState<PieceSummary>> {
  late final _$args = ref.$arg as FeedTab;
  FeedTab get tab => _$args;

  FutureOr<PagedListState<PieceSummary>> build(FeedTab tab);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<PieceSummary>>,
              PagedListState<PieceSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<PieceSummary>>,
                PagedListState<PieceSummary>
              >,
              AsyncValue<PagedListState<PieceSummary>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

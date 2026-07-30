// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_range_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnalyticsRangeController)
final analyticsRangeControllerProvider = AnalyticsRangeControllerProvider._();

final class AnalyticsRangeControllerProvider
    extends $NotifierProvider<AnalyticsRangeController, AnalyticsRange> {
  AnalyticsRangeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsRangeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsRangeControllerHash();

  @$internal
  @override
  AnalyticsRangeController create() => AnalyticsRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsRange value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsRange>(value),
    );
  }
}

String _$analyticsRangeControllerHash() =>
    r'fa90678e2d2045a53c5460f70da58af9cd4106f5';

abstract class _$AnalyticsRangeController extends $Notifier<AnalyticsRange> {
  AnalyticsRange build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AnalyticsRange, AnalyticsRange>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnalyticsRange, AnalyticsRange>,
              AnalyticsRange,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

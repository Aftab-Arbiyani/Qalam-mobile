// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CouponController)
final couponControllerProvider = CouponControllerProvider._();

final class CouponControllerProvider
    extends $AsyncNotifierProvider<CouponController, CouponValidation?> {
  CouponControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'couponControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$couponControllerHash();

  @$internal
  @override
  CouponController create() => CouponController();
}

String _$couponControllerHash() => r'7926ca45b70fcaf962516aa3d89287bc697d3bbc';

abstract class _$CouponController extends $AsyncNotifier<CouponValidation?> {
  FutureOr<CouponValidation?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CouponValidation?>, CouponValidation?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CouponValidation?>, CouponValidation?>,
              AsyncValue<CouponValidation?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

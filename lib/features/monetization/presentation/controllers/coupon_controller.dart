/// Coupon preview controller (AF5) — drives `POST /monetization/coupons/validate` and
/// holds the answer for the plans screen.
///
/// **Validation is a preview, never a promise.** The code is redeemed server-side during
/// checkout, at which point it can still fail — someone else may take the last
/// redemption between the preview and the purchase. So an accepted code is handed to
/// checkout and checkout's own result is what the reader is told; this only saves them
/// from typing a code that was never going to work.
///
/// `valid: false` is a normal answer, not a failure: the endpoint catches the coupon
/// exceptions and resolves with a false flag, so an [AsyncError] here only ever means
/// transport or rate limiting.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/coupon_validation.dart';
import '../../domain/entities/monetization_enums.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../providers/monetization_providers.dart';

part 'coupon_controller.g.dart';

@riverpod
class CouponController extends _$CouponController {
  /// No code entered yet — distinct from a code that was checked and refused.
  @override
  Future<CouponValidation?> build() async => null;

  /// Preview [code] against the server. Returns the accepted code, or null when the
  /// server refused it or the request failed.
  ///
  /// The code is normalized before it leaves: the server looks a coupon up by its
  /// normalized form, so an untrimmed lower-case code finds nothing.
  Future<String?> validate({
    required String code,
    String? tier,
    String? interval,
  }) async {
    final String normalized = normalizeCouponCode(code);
    if (normalized.isEmpty) return null;

    state = const AsyncValue<CouponValidation?>.loading();
    final MonetizationRepository repo = ref.read(
      monetizationRepositoryProvider,
    );
    final Result<CouponValidation> result = await repo.validateCoupon(
      code: normalized,
      tier: tier,
      interval: interval,
    );
    switch (result) {
      case Ok<CouponValidation>(:final CouponValidation value):
        state = AsyncValue<CouponValidation?>.data(value);
        return value.valid ? value.code : null;
      case Err<CouponValidation>(:final Failure failure):
        state = AsyncValue<CouponValidation?>.error(
          failure,
          StackTrace.current,
        );
        return null;
    }
  }

  /// Forget the last answer — called as the reader edits the code, so a stale verdict
  /// never sits under a field whose contents have changed.
  void clear() => state = const AsyncValue<CouponValidation?>.data(null);
}

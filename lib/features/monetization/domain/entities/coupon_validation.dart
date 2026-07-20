/// Coupon preview result (AF5) — `POST /monetization/coupons/validate`.
library;

import '../../../../core/utils/typedefs.dart';

class CouponValidation {
  const CouponValidation({
    required this.code,
    required this.valid,
    required this.type,
    required this.description,
    this.discountedAmount,
  });

  final String code;
  final bool valid;
  final String type;
  final String description;
  final int? discountedAmount;

  factory CouponValidation.fromJson(Json json) => CouponValidation(
    code: json['code'] as String? ?? '',
    valid: json['valid'] as bool? ?? false,
    type: json['type'] as String? ?? '',
    description: json['description'] as String? ?? '',
    discountedAmount: (json['discountedAmount'] as num?)?.toInt(),
  );
}

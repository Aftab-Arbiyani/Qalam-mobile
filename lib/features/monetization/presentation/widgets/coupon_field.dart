/// Coupon entry with a server-side preview (AF5) — the surface that makes
/// `validateCoupon` reachable.
///
/// The repository has exposed `validateCoupon` since AF5 shipped and **nothing called
/// it**: the plans screen passed no `couponCode` to checkout and there was no field to
/// type one into, so a mobile subscriber could not use a promotion and the whole
/// `PromotionType` catalogue was unreachable from the app (docs/48 §3.7, M5-2). This is
/// that missing half.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../../domain/entities/coupon_validation.dart';
import '../../domain/entities/monetization_enums.dart';
import '../controllers/coupon_controller.dart';
import '../monetization_format.dart';

class CouponField extends ConsumerStatefulWidget {
  const CouponField({
    required this.interval,
    required this.currency,
    required this.onApplied,
    this.tier,
    super.key,
  });

  /// The plan being priced, so the server can compute a real discounted amount.
  final String? tier;
  final String interval;
  final String currency;

  /// Bubbles the accepted code up so checkout can send it. `null` clears it.
  final ValueChanged<String?> onApplied;

  @override
  ConsumerState<CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends ConsumerState<CouponField> {
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (normalizeCouponCode(_code.text).isEmpty) return;
    final String? accepted = await ref
        .read(couponControllerProvider.notifier)
        .validate(
          code: _code.text,
          tier: widget.tier,
          interval: widget.interval,
        );
    widget.onApplied(accepted);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CouponValidation?> state = ref.watch(
      couponControllerProvider,
    );
    final bool busy = state.isLoading;
    // `asData?.value`, not `value`: the state's own type is nullable, so a plain `value`
    // read cannot tell "no code entered yet" from "loading" or "failed".
    final CouponValidation? result = state.asData?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: QTextField(
                label: 'Promo code',
                controller: _code,
                // The wire form is upper-case (`normalizeCouponCode`); showing it that
                // way as the reader types means the field agrees with the code on
                // their voucher.
                textCapitalization: TextCapitalization.characters,
                maxLength: couponCodeMax,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  // An edited code invalidates both the last verdict and the code
                  // checkout is holding.
                  widget.onApplied(null);
                  ref.read(couponControllerProvider.notifier).clear();
                },
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: QSpacing.s2),
            Padding(
              padding: const EdgeInsets.only(bottom: QSpacing.s1),
              child: QButton(
                label: 'Apply',
                loading: busy,
                onPressed: busy ? null : _submit,
              ),
            ),
          ],
        ),
        if (state.hasError) ...<Widget>[
          Gap.v1,
          _Note(text: _errorText(state.error), tone: _NoteTone.bad),
        ] else if (result != null) ...<Widget>[
          Gap.v1,
          _Note(
            text: _resultText(result),
            tone: result.valid ? _NoteTone.good : _NoteTone.neutral,
          ),
        ],
      ],
    );
  }

  String _errorText(Object? error) =>
      error is Failure ? error.message : 'That didn’t work. Please try again.';

  String _resultText(CouponValidation result) {
    if (!result.valid) return 'That code isn’t valid or has expired.';
    final String description = result.description.isEmpty
        ? 'Code applied'
        : result.description;
    // `discountedAmount` is only computed when the request carried both a tier and an
    // interval; without one the server prices from 0 and answers null, so the code is
    // confirmed without a figure rather than shown as a zero discount.
    if (result.discountedAmount == null) return '$description.';
    return '$description — '
        '${formatMoney(result.discountedAmount!, widget.currency)} after discount';
  }
}

enum _NoteTone { good, neutral, bad }

/// A one-line verdict under the field. Announced to a screen reader, and carrying an
/// icon as well as a colour so the outcome does not depend on hue alone.
class _Note extends StatelessWidget {
  const _Note({required this.text, required this.tone});

  final String text;
  final _NoteTone tone;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final Color color = switch (tone) {
      _NoteTone.good => tokens.colors.success,
      _NoteTone.neutral => tokens.colors.textSecondary,
      _NoteTone.bad => tokens.colors.danger,
    };
    final IconData icon = switch (tone) {
      _NoteTone.good => Icons.check_circle_outline,
      _NoteTone.neutral => Icons.cancel_outlined,
      _NoteTone.bad => Icons.error_outline,
    };
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: QSpacing.s2),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

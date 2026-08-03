/// Text field (docs/41 §11.3). STATIC label above the field (no floating labels —
/// they misbehave in RTL + Nastaliq), inline hint/error, accent focus ring from
/// the theme. User-content fields default to auto directionality.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens/spacing_tokens.dart';

class QTextField extends StatelessWidget {
  const QTextField({
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.maxLength,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.contentDirectionAuto = false,
    this.trailing,
    this.onTapOutside,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final int? maxLength;
  final Iterable<String>? autofillHints;

  /// Keyboard capitalisation. Fields whose value has a canonical case on the wire —
  /// a coupon code, which the server looks up upper-cased — set this so what is typed
  /// matches what is sent.
  final TextCapitalization textCapitalization;

  /// User-content fields (bio, comment) set this so text follows its own script.
  final bool contentDirectionAuto;

  /// Max visible lines (1 = single-line). A multiline composer sets this > 1.
  final int maxLines;

  /// Optional minimum lines the field grows to before scrolling.
  final int? minLines;

  /// Optional trailing affordance inside the field (e.g. a password visibility
  /// toggle). Rendered as the input's suffix icon.
  final Widget? trailing;

  /// Called when a tap lands outside the field — used to dismiss the keyboard.
  final TapRegionCallback? onTapOutside;

  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.v2,
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          autofillHints: autofillHints,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTapOutside: onTapOutside,
          textDirection: contentDirectionAuto ? null : TextDirection.ltr,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            counterText: '',
            suffixIcon: trailing,
          ),
        ),
      ],
    );
  }
}

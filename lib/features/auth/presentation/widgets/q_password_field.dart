/// Password input with a visibility toggle (docs/41 §11.3, §29). Wraps [QTextField]
/// (static label, error slot, RTL-safe) and adds an eye toggle in the trailing slot
/// with a proper semantic label, plus autofill + keyboard hints. Obscure state is
/// ephemeral view state, owned here.
library;

import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';

class QPasswordField extends StatefulWidget {
  const QPasswordField({
    required this.label,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onEditingBlur,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const <String>[AutofillHints.password],
    this.focusNode,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingBlur;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final FocusNode? focusNode;

  @override
  State<QPasswordField> createState() => _QPasswordFieldState();
}

class _QPasswordFieldState extends State<QPasswordField> {
  bool _obscured = true;
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.onEditingBlur != null) {
      _focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) widget.onEditingBlur?.call();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    // Only dispose a node we created ourselves.
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);

    return QTextField(
      label: widget.label,
      controller: widget.controller,
      focusNode: _focusNode,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: _obscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      trailing: Semantics(
        button: true,
        label: _obscured ? l10n.actionShowPassword : l10n.actionHidePassword,
        child: IconButton(
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: tokens.colors.textSecondary,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}

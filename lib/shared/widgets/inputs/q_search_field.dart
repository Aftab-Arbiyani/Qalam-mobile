/// Search field (docs/41 §11.13). A leading search icon, a trailing clear button
/// while non-empty, and a search-action keyboard. The Search screen (M8) owns the
/// query state; this is the input primitive.
library;

import 'package:flutter/material.dart';

class QSearchField extends StatelessWidget {
  const QSearchField({
    required this.controller,
    this.hint,
    this.clearTooltip,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String? hint;

  /// Tooltip for the trailing clear button; defaults to the Material cancel
  /// label.
  final String? clearTooltip;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip:
                        clearTooltip ??
                        MaterialLocalizations.of(context).cancelButtonLabel,
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                      onChanged?.call('');
                    },
                  ),
          ),
        );
      },
    );
  }
}

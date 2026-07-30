/// A comment / reply composer (docs/41 §11.3) — a multiline field + a send
/// button, gated on a non-empty trimmed body. Owns its own controller; clears on
/// a successful submit. Used by the comment thread (top-level) and inline reply
/// boxes. Sign-in gating is the caller's concern (it hides the composer).
library;

import 'package:flutter/material.dart';

import '../../theme/tokens/spacing_tokens.dart';
import '../buttons/q_button.dart';
import '../haptics/q_haptics.dart';
import '../inputs/q_text_field.dart';

class CommentComposer extends StatefulWidget {
  const CommentComposer({
    required this.hint,
    required this.sendLabel,
    required this.onSubmit,
    this.autofocus = false,
    super.key,
  });

  final String hint;
  final String sendLabel;

  /// Called with the trimmed body. Returns true if accepted (field then clears).
  final Future<bool> Function(String body) onSubmit;
  final bool autofocus;

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  bool _canSend = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    await QHaptics.light();
    final bool accepted = await widget.onSubmit(body);
    if (!mounted) return;
    setState(() => _sending = false);
    if (accepted) {
      _controller.clear();
      setState(() => _canSend = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QSpacing.s4,
        vertical: QSpacing.s2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: QTextField(
              label: '',
              controller: _controller,
              hint: widget.hint,
              autofocus: widget.autofocus,
              minLines: 1,
              maxLines: 5,
              maxLength: 2000,
              textInputAction: TextInputAction.newline,
              contentDirectionAuto: true,
              onChanged: (String v) {
                final bool can = v.trim().isNotEmpty;
                if (can != _canSend) setState(() => _canSend = can);
              },
            ),
          ),
          Gap.h2,
          QButton(
            label: widget.sendLabel,
            size: QButtonSize.sm,
            loading: _sending,
            onPressed: _canSend && !_sending ? _submit : null,
          ),
        ],
      ),
    );
  }
}

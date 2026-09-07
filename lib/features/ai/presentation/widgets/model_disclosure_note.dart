/// The one quiet line every writing tool carries (D5, decision 9).
///
/// D5 removed the "AI" branding, not the fact — a literary writer's objection is to
/// being *sold* a machine and to their manuscript being used without their knowing,
/// not to being told plainly what a tool does. So the word leaves every button, tab
/// and plan card, and this single sentence appears in the foot of each tool that
/// actually sends text to a provider: Polish, Manuscript feedback, Story Map.
///
/// Both halves are load-bearing. The first says a model produced the output, so no
/// reader mistakes it for an editor's note; the second answers the question the
/// audience actually asks, which is whether their unpublished work becomes training
/// data. Neither is a legal disclaimer — [text] is exported so tests can pin the
/// exact wording, and so the copy lives in exactly one place across three surfaces.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';

class ModelDisclosureNote extends StatelessWidget {
  const ModelDisclosureNote({super.key});

  /// The exact sentence. Pinned by tests; never re-worded per surface.
  static const String text =
      'Produced by a language model. Your text isn’t used to train it.';

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: QSpacing.s2),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: tokens.colors.textMuted),
      ),
    );
  }
}

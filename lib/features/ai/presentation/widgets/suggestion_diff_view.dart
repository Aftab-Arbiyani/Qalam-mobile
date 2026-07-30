/// Renders a [SuggestionDiff] (AF2) — the word-level Compare view for a suggestion:
/// additions in the success colour, removals struck through in the danger colour,
/// unchanged text normal. Powers the "Compare" toggle and communicates exactly what
/// an Apply would change before the writer commits.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../domain/entities/ai_suggestion.dart';

class SuggestionDiffView extends StatelessWidget {
  const SuggestionDiffView({required this.diff, super.key});

  final SuggestionDiff diff;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final TextStyle base = Theme.of(context).textTheme.bodyMedium!;
    final List<InlineSpan> spans = <InlineSpan>[];
    for (final DiffSegment seg in diff.segments) {
      final String text = '${seg.text} ';
      spans.add(switch (seg.kind) {
        DiffKind.equal => TextSpan(text: text, style: base),
        DiffKind.added => TextSpan(
            text: text,
            style: base.copyWith(
              color: tokens.colors.successText,
              backgroundColor: tokens.colors.successBg,
            ),
          ),
        DiffKind.removed => TextSpan(
            text: text,
            style: base.copyWith(
              color: tokens.colors.dangerText,
              backgroundColor: tokens.colors.dangerBg,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: QSpacing.s2),
          child: Row(
            children: <Widget>[
              _legend(tokens.colors.successText, '+${diff.addedWords} added'),
              const SizedBox(width: QSpacing.s3),
              _legend(tokens.colors.dangerText, '−${diff.removedWords} removed'),
            ],
          ),
        ),
        Text.rich(TextSpan(children: spans)),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: QSpacing.s1),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      );
}

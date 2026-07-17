/// Streaming text with a typing animation (AF2). While tokens arrive it renders the
/// accumulating plain text with a blinking caret (partial Markdown isn't parsed until
/// it's complete); when the stream settles the caller swaps in [AiMarkdown]. Honours
/// the OS "reduce motion" setting — the caret is static then. Accessible: the live
/// region is labelled so screen readers announce it politely.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';

class AiStreamingText extends StatefulWidget {
  const AiStreamingText({required this.text, this.semanticsLabel, super.key});

  final String text;
  final String? semanticsLabel;

  @override
  State<AiStreamingText> createState() => _AiStreamingTextState();
}

class _AiStreamingTextState extends State<AiStreamingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final bool reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final TextStyle style = theme.textTheme.bodyMedium!;

    final Widget caret = Container(
      width: 8,
      height: (style.fontSize ?? 14) + 2,
      margin: const EdgeInsets.only(left: 2),
      color: tokens.colors.accent,
    );

    return Semantics(
      liveRegion: true,
      label: widget.semanticsLabel ?? 'AI is writing',
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: widget.text, style: style),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: reduceMotion
                  ? caret
                  : FadeTransition(
                      opacity: _blink.drive(
                        TweenSequence<double>(<TweenSequenceItem<double>>[
                          TweenSequenceItem<double>(tween: ConstantTween<double>(1), weight: 50),
                          TweenSequenceItem<double>(tween: ConstantTween<double>(0), weight: 50),
                        ]),
                      ),
                      child: caret,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

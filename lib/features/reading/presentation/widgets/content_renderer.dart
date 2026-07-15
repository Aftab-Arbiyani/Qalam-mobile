/// The TipTap-JSON reading renderer (docs/40 §19.4, docs/41 §35). Walks the typed
/// [PieceContent] tree and maps the whitelisted nodes/marks to native widgets —
/// NEVER a WebView, never HTML. Per-script typography (reading size + line-height)
/// and direction are applied by the caller; italic is suppressed for Urdu
/// (Nastaliq, docs/41 §4.4). Unknown nodes degrade gracefully (block → a subtle
/// placeholder; inline → skipped) so additive server nodes never break the reader.
library;

import 'package:flutter/material.dart';

import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../domain/entities/content_node.dart';

class ContentRenderer extends StatelessWidget {
  const ContentRenderer({
    required this.content,
    required this.baseFontSize,
    required this.lineHeight,
    required this.direction,
    super.key,
  });

  final PieceContent content;
  final double baseFontSize;
  final double lineHeight;
  final TextDirectionKind direction;

  bool get _isRtl => direction == TextDirectionKind.rtl;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final TextStyle bodyStyle = TextStyle(
      fontSize: baseFontSize,
      height: lineHeight,
      color: tokens.colors.textPrimary,
    );

    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final BlockNode block in content.blocks)
            _block(context, block, bodyStyle, tokens),
        ],
      ),
    );
  }

  Widget _block(
    BuildContext context,
    BlockNode node,
    TextStyle bodyStyle,
    QTokens tokens,
  ) {
    return switch (node) {
      Paragraph(:final List<InlineNode> spans, :final ContentAlign? align) =>
        Padding(
          padding: const EdgeInsets.only(bottom: QSpacing.s4),
          child: Text.rich(
            TextSpan(children: _inlines(spans, bodyStyle, tokens)),
            textAlign: _align(align),
          ),
        ),
      Heading(
        :final int level,
        :final List<InlineNode> spans,
        :final ContentAlign? align,
      ) =>
        Padding(
          padding: const EdgeInsets.only(top: QSpacing.s5, bottom: QSpacing.s3),
          child: Text.rich(
            TextSpan(
              children: _inlines(
                spans,
                _headingStyle(bodyStyle, level),
                tokens,
              ),
            ),
            textAlign: _align(align),
          ),
        ),
      Blockquote(:final List<BlockNode> children) => _blockquote(
        context,
        children,
        bodyStyle,
        tokens,
      ),
      ListBlock() => _list(context, node, bodyStyle, tokens),
      UnknownBlock() => _unsupported(tokens),
    };
  }

  Widget _blockquote(
    BuildContext context,
    List<BlockNode> children,
    TextStyle bodyStyle,
    QTokens tokens,
  ) {
    final TextStyle quoteStyle = bodyStyle.copyWith(
      color: tokens.colors.textSecondary,
      fontStyle: _isRtl ? FontStyle.normal : FontStyle.italic,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: QSpacing.s4),
      child: Container(
        padding: const EdgeInsetsDirectional.only(
          start: QSpacing.s4,
          top: QSpacing.s1,
          bottom: QSpacing.s1,
        ),
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: tokens.colors.accent, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final BlockNode child in children)
              _block(context, child, quoteStyle, tokens),
          ],
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    ListBlock node,
    TextStyle bodyStyle,
    QTokens tokens,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: QSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (int index, ListItemBlock item) in node.items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: QSpacing.s2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 28,
                    child: Text(
                      node.ordered ? '${node.start + index}.' : '•',
                      style: bodyStyle.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (final BlockNode child in item.children)
                          _block(context, child, bodyStyle, tokens),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<InlineSpan> _inlines(
    List<InlineNode> nodes,
    TextStyle base,
    QTokens tokens,
  ) {
    final List<InlineSpan> spans = <InlineSpan>[];
    for (final InlineNode node in nodes) {
      switch (node) {
        case TextRun(:final String text, :final Set<TextMark> marks):
          spans.add(TextSpan(text: text, style: _applyMarks(base, marks)));
        case LineBreak():
          spans.add(const TextSpan(text: '\n'));
        case FootnoteRef():
          // No footnote-content node exists in the whitelist, so render an inert
          // accent marker rather than a dead tap target (documented gap).
          spans.add(
            TextSpan(
              text: ' *',
              style: base.copyWith(
                color: tokens.colors.accent,
                fontFeatures: const <FontFeature>[FontFeature.superscripts()],
              ),
            ),
          );
        case Mention(:final String label):
          spans.add(
            TextSpan(
              text: '@$label',
              style: base.copyWith(color: tokens.colors.accent),
            ),
          );
        case Hashtag(:final String tag):
          spans.add(
            TextSpan(
              text: '#$tag',
              style: base.copyWith(color: tokens.colors.accent),
            ),
          );
        case UnknownInline():
          break; // skip silently (forward-compatible)
      }
    }
    return spans;
  }

  Widget _unsupported(QTokens tokens) => Padding(
    padding: const EdgeInsets.only(bottom: QSpacing.s4),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(QSpacing.s3),
      decoration: BoxDecoration(
        color: tokens.colors.bgRaised,
        borderRadius: QRadii.cardRadius,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.block_outlined, size: 16, color: tokens.colors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This part isn’t supported here yet.',
              style: TextStyle(fontSize: 14, color: tokens.colors.textMuted),
            ),
          ),
        ],
      ),
    ),
  );

  TextStyle _headingStyle(TextStyle base, int level) => base.copyWith(
    fontSize:
        base.fontSize! *
        switch (level) {
          2 => 1.5,
          3 => 1.3,
          _ => 1.15,
        },
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  TextStyle _applyMarks(TextStyle base, Set<TextMark> marks) {
    TextStyle style = base;
    if (marks.contains(TextMark.bold)) {
      style = style.copyWith(fontWeight: FontWeight.w700);
    }
    if (marks.contains(TextMark.italic) && !_isRtl) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    if (marks.contains(TextMark.underline)) {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
    return style;
  }

  TextAlign _align(ContentAlign? align) => switch (align) {
    ContentAlign.left => TextAlign.left,
    ContentAlign.right => TextAlign.right,
    ContentAlign.center => TextAlign.center,
    ContentAlign.justify => TextAlign.justify,
    null => TextAlign.start,
  };
}

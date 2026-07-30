/// A lean, dependency-free Markdown renderer for AI output (AF2). The app is
/// deliberately dependency-minimal, so rather than pull a Markdown package this
/// renders the subset AI responses actually use: headings, bold/italic, inline code,
/// bullet/numbered lists, blockquotes, and fenced code blocks (monospace surface,
/// language chip, copy button, light generic highlighting). Content direction is
/// auto so Hindi/Urdu renders correctly. Unknown syntax falls back to plain text.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';

class AiMarkdown extends StatelessWidget {
  const AiMarkdown(this.text, {this.selectable = true, super.key});

  final String text;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final List<Widget> blocks = _buildBlocks(context, text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );
  }

  List<Widget> _buildBlocks(BuildContext context, String source) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final List<String> lines = source.replaceAll('\r\n', '\n').split('\n');
    final List<Widget> out = <Widget>[];

    int i = 0;
    while (i < lines.length) {
      final String line = lines[i];

      // Fenced code block.
      if (line.trimLeft().startsWith('```')) {
        final String lang = line.trimLeft().substring(3).trim();
        final List<String> code = <String>[];
        i++;
        while (i < lines.length && !lines[i].trimLeft().startsWith('```')) {
          code.add(lines[i]);
          i++;
        }
        if (i < lines.length) i++; // consume closing fence
        out.add(_CodeBlock(code: code.join('\n'), language: lang));
        continue;
      }

      // Blank line → spacing between blocks.
      if (line.trim().isEmpty) {
        i++;
        continue;
      }

      // Heading.
      final RegExpMatch? heading = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(line);
      if (heading != null) {
        final int level = heading.group(1)!.length;
        final TextStyle style = (level == 1
                ? theme.textTheme.titleLarge
                : level == 2
                    ? theme.textTheme.titleMedium
                    : theme.textTheme.titleSmall)!
            .copyWith(fontWeight: FontWeight.w600);
        out.add(Padding(
          padding: const EdgeInsets.only(top: QSpacing.s3, bottom: QSpacing.s1),
          child: _richLine(context, heading.group(2)!, style),
        ));
        i++;
        continue;
      }

      // Blockquote.
      if (line.trimLeft().startsWith('> ')) {
        out.add(_Blockquote(child: _richLine(context, line.trimLeft().substring(2), null)));
        i++;
        continue;
      }

      // List (grouped consecutive items).
      final bool bullet = RegExp(r'^\s*[-*]\s+').hasMatch(line);
      final bool numbered = RegExp(r'^\s*\d+\.\s+').hasMatch(line);
      if (bullet || numbered) {
        int index = 1;
        while (i < lines.length &&
            (RegExp(r'^\s*[-*]\s+').hasMatch(lines[i]) ||
                RegExp(r'^\s*\d+\.\s+').hasMatch(lines[i]))) {
          final String item = lines[i]
              .replaceFirst(RegExp(r'^\s*[-*]\s+'), '')
              .replaceFirst(RegExp(r'^\s*\d+\.\s+'), '');
          out.add(Padding(
            padding: const EdgeInsets.only(bottom: QSpacing.s1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: QSpacing.s2),
                  child: Text(
                    numbered ? '$index.' : '•',
                    style: TextStyle(color: tokens.colors.textMuted),
                  ),
                ),
                Expanded(child: _richLine(context, item, null)),
              ],
            ),
          ));
          index++;
          i++;
        }
        continue;
      }

      // Paragraph — gather consecutive plain lines.
      final List<String> para = <String>[line];
      i++;
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !lines[i].trimLeft().startsWith('```') &&
          !RegExp(r'^(#{1,3})\s+').hasMatch(lines[i]) &&
          !lines[i].trimLeft().startsWith('> ') &&
          !RegExp(r'^\s*[-*]\s+').hasMatch(lines[i]) &&
          !RegExp(r'^\s*\d+\.\s+').hasMatch(lines[i])) {
        para.add(lines[i]);
        i++;
      }
      out.add(Padding(
        padding: const EdgeInsets.only(bottom: QSpacing.s2),
        child: _richLine(context, para.join(' '), null),
      ));
    }

    return out;
  }

  Widget _richLine(BuildContext context, String text, TextStyle? baseStyle) {
    final ThemeData theme = Theme.of(context);
    final TextStyle style = baseStyle ?? theme.textTheme.bodyMedium!;
    final List<InlineSpan> spans = _inlineSpans(context, text, style);
    final Text child = selectable
        ? Text.rich(TextSpan(children: spans), textAlign: TextAlign.start)
        : Text.rich(TextSpan(children: spans));
    return child;
  }

  /// Parse inline `**bold**`, `*italic*` / `_italic_`, and `` `code` ``.
  List<InlineSpan> _inlineSpans(BuildContext context, String text, TextStyle base) {
    final QTokens tokens = QTokens.of(context);
    final List<InlineSpan> spans = <InlineSpan>[];
    final RegExp pattern = RegExp(r'(\*\*(.+?)\*\*)|(\*(.+?)\*)|(_(.+?)_)|(`(.+?)`)');
    int last = 0;
    for (final RegExpMatch m in pattern.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start), style: base));
      }
      if (m.group(2) != null) {
        spans.add(TextSpan(text: m.group(2), style: base.copyWith(fontWeight: FontWeight.w700)));
      } else if (m.group(4) != null) {
        spans.add(TextSpan(text: m.group(4), style: base.copyWith(fontStyle: FontStyle.italic)));
      } else if (m.group(6) != null) {
        spans.add(TextSpan(text: m.group(6), style: base.copyWith(fontStyle: FontStyle.italic)));
      } else if (m.group(8) != null) {
        spans.add(TextSpan(
          text: m.group(8),
          style: base.copyWith(
            fontFamilyFallback: const <String>['monospace'],
            backgroundColor: tokens.colors.bgRaised,
          ),
        ));
      }
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: base));
    }
    return spans;
  }
}

class _Blockquote extends StatelessWidget {
  const _Blockquote({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: QSpacing.s2),
      padding: const EdgeInsets.only(left: QSpacing.s3),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: tokens.colors.borderStrong, width: 3)),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tokens.colors.textSecondary, fontStyle: FontStyle.italic),
        child: child,
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code, required this.language});
  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: QSpacing.s2),
      decoration: BoxDecoration(
        color: tokens.colors.bgRaised,
        borderRadius: QRadii.cardRadius,
        border: Border.all(color: tokens.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(QSpacing.s3, QSpacing.s2, 0, 0),
                child: Text(
                  language.isEmpty ? 'code' : language,
                  style: TextStyle(fontSize: 11, color: tokens.colors.textMuted),
                ),
              ),
              const Spacer(),
              IconButton(
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                tooltip: 'Copy code',
                icon: Icon(Icons.copy, color: tokens.colors.textMuted),
                onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(QSpacing.s3, 0, QSpacing.s3, QSpacing.s3),
            child: RichText(text: _highlight(context, code)),
          ),
        ],
      ),
    );
  }

  /// A deliberately light generic highlighter (strings, comments, numbers) — Qalam is
  /// a prose platform, so code is rare; this reads as syntax-highlighted without a
  /// heavy tokenizer dependency.
  TextSpan _highlight(BuildContext context, String source) {
    final QTokens tokens = QTokens.of(context);
    final TextStyle mono = TextStyle(
      fontFamilyFallback: const <String>['monospace'],
      fontSize: 13,
      height: 1.5,
      color: tokens.colors.textPrimary,
    );
    final List<InlineSpan> spans = <InlineSpan>[];
    final RegExp pattern = RegExp(
      r'(//[^\n]*|#[^\n]*)|("(?:[^"\\]|\\.)*"|' r"'(?:[^'\\]|\\.)*')|(\b\d+(?:\.\d+)?\b)",
    );
    int last = 0;
    for (final RegExpMatch m in pattern.allMatches(source)) {
      if (m.start > last) spans.add(TextSpan(text: source.substring(last, m.start), style: mono));
      if (m.group(1) != null) {
        spans.add(TextSpan(text: m.group(1), style: mono.copyWith(color: tokens.colors.textMuted)));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(text: m.group(2), style: mono.copyWith(color: tokens.colors.success)));
      } else if (m.group(3) != null) {
        spans.add(TextSpan(text: m.group(3), style: mono.copyWith(color: tokens.colors.accent)));
      }
      last = m.end;
    }
    if (last < source.length) spans.add(TextSpan(text: source.substring(last), style: mono));
    return TextSpan(children: spans);
  }
}

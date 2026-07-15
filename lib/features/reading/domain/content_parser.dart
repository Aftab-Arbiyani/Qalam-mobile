/// TipTap-JSON → typed [PieceContent] parser (docs/40 §18, §19.4, §36).
///
/// Turns the raw `pieces.content` map (carried verbatim on [PieceDetail]) into the
/// renderer's typed tree. A pure DOMAIN transformation (no Flutter, no I/O), so the
/// presentation layer may call it directly. It mirrors the SERVER whitelist and is
/// defensive by construction: unknown node/mark types, missing fields, and wrong
/// value types never throw — they degrade to [UnknownBlock]/[UnknownInline] or are
/// skipped (docs/40 §18.2). Unit-tested with null/unknown/malformed payloads.
library;

import 'entities/content_node.dart';

/// Parse a TipTap `doc` map into a [PieceContent] tree. Any shape that isn't a
/// well-formed doc yields [PieceContent.empty] rather than throwing.
PieceContent parsePieceContent(Map<String, dynamic>? doc) {
  if (doc == null) return PieceContent.empty;
  final List<BlockNode> blocks = <BlockNode>[];
  for (final Object? node in _children(doc)) {
    final BlockNode? block = _block(node);
    if (block != null) blocks.add(block);
  }
  return PieceContent(blocks);
}

BlockNode? _block(Object? node) {
  if (node is! Map) return null;
  final String type = _string(node['type']);
  switch (type) {
    case 'paragraph':
      return Paragraph(_inlines(node), align: _align(node));
    case 'heading':
      return Heading(
        level: _headingLevel(node),
        spans: _inlines(node),
        align: _align(node),
      );
    case 'blockquote':
      return Blockquote(_blocks(node));
    case 'bulletList':
      return ListBlock(ordered: false, items: _items(node));
    case 'orderedList':
      return ListBlock(ordered: true, start: _start(node), items: _items(node));
    case '':
      return null;
    default:
      return UnknownBlock(type);
  }
}

List<BlockNode> _blocks(Object? node) {
  final List<BlockNode> out = <BlockNode>[];
  for (final Object? child in _children(node)) {
    final BlockNode? block = _block(child);
    if (block != null) out.add(block);
  }
  return out;
}

List<ListItemBlock> _items(Object? node) {
  final List<ListItemBlock> out = <ListItemBlock>[];
  for (final Object? child in _children(node)) {
    if (child is! Map) continue;
    if (_string(child['type']) != 'listItem') continue;
    out.add(ListItemBlock(_blocks(child)));
  }
  return out;
}

List<InlineNode> _inlines(Object? node) {
  final List<InlineNode> out = <InlineNode>[];
  for (final Object? child in _children(node)) {
    if (child is! Map) continue;
    final String type = _string(child['type']);
    switch (type) {
      case 'text':
        final String text = _string(child['text']);
        if (text.isEmpty) break;
        out.add(TextRun(text, marks: _marks(child['marks'])));
      case 'hardBreak':
        out.add(const LineBreak());
      case 'footnote':
        out.add(FootnoteRef(_string(_attr(child, 'id'))));
      case 'mention':
        out.add(
          Mention(
            userId: _string(_attr(child, 'userId')),
            label: _string(_attr(child, 'label')),
          ),
        );
      case 'hashtag':
        out.add(Hashtag(_string(_attr(child, 'tag'))));
      case '':
        break;
      default:
        out.add(UnknownInline(type));
    }
  }
  return out;
}

Set<TextMark> _marks(Object? raw) {
  if (raw is! List) return const <TextMark>{};
  final Set<TextMark> marks = <TextMark>{};
  for (final Object? mark in raw) {
    if (mark is! Map) continue;
    switch (_string(mark['type'])) {
      case 'bold':
        marks.add(TextMark.bold);
      case 'italic':
        marks.add(TextMark.italic);
      case 'underline':
        marks.add(TextMark.underline);
    }
  }
  return marks;
}

ContentAlign? _align(Object? node) =>
    switch (_string(_attr(node, 'textAlign'))) {
      'left' => ContentAlign.left,
      'right' => ContentAlign.right,
      'center' => ContentAlign.center,
      'justify' => ContentAlign.justify,
      _ => null,
    };

int _headingLevel(Object? node) {
  final Object? raw = _attr(node, 'level');
  final int level = raw is int ? raw : (raw is num ? raw.toInt() : 2);
  return level.clamp(2, 4);
}

int _start(Object? node) {
  final Object? raw = _attr(node, 'start');
  final int start = raw is int ? raw : (raw is num ? raw.toInt() : 1);
  return start < 1 ? 1 : start;
}

Object? _attr(Object? node, String key) {
  if (node is! Map) return null;
  final Object? attrs = node['attrs'];
  return attrs is Map ? attrs[key] : null;
}

List<Object?> _children(Object? node) {
  if (node is! Map) return const <Object?>[];
  final Object? content = node['content'];
  return content is List ? content : const <Object?>[];
}

String _string(Object? value) => value is String ? value : '';

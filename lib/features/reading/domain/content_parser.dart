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

// ── Anchor-aware parse (docs/48 §3.22a, AF6's "propose an edit" composer) ────────

/// A character-offset anchor for one block — the range it occupies in the server's
/// `anchorText` coordinate space: every `type: 'text'` leaf in the raw TipTap doc,
/// concatenated verbatim with NO separator anywhere, not between text runs and not
/// between blocks (`platfrom/backend/src/modules/collaboration/content-text.util.ts`).
/// This is NOT the string [ContentRenderer] shows: mentions/hashtags/footnotes/hard
/// breaks render synthetic characters (`'@label'`, `'#tag'`, `' *'`, `'\n'`) that do
/// not exist in this coordinate space.
class BlockAnchor {
  const BlockAnchor({required this.from, required this.to, required this.text});

  final int from;
  final int to;
  final String text;
}

/// Parses [doc] exactly like [parsePieceContent], but also returns a same-object
/// identity map from every non-empty `Paragraph`/`Heading` to its [BlockAnchor].
/// Building both the tree and the anchors in one pass — rather than a second,
/// independently-filtered walk over the result — means "which blocks get a tap
/// target" and "what offset does each one have" can never desync.
///
/// A node type this client does not model still has its raw `content` walked to
/// advance the running offset by however many `type: 'text'` leaves it contains,
/// even though nothing renderable comes out of it (it still parses to
/// [UnknownBlock], exactly as [parsePieceContent] does). This mirrors the backend's
/// own walk, which does not know or care about a whitelist — skipping unknown
/// nodes here, the way rendering correctly does for its own purpose, would
/// undercount every later offset the day the server ships a node type this client
/// has not been taught to render yet.
(PieceContent, Map<BlockNode, BlockAnchor>) parseContentWithAnchors(
  Map<String, dynamic>? doc,
) {
  if (doc == null) {
    return (PieceContent.empty, const <BlockNode, BlockAnchor>{});
  }
  final Map<BlockNode, BlockAnchor> anchors = <BlockNode, BlockAnchor>{};
  final List<BlockNode> blocks = <BlockNode>[];
  int cursor = 0;
  for (final Object? node in _children(doc)) {
    final (BlockNode? block, int consumed) = _blockAnchored(
      node,
      cursor,
      anchors,
    );
    if (block != null) blocks.add(block);
    cursor += consumed;
  }
  return (PieceContent(blocks), anchors);
}

(BlockNode?, int) _blockAnchored(
  Object? node,
  int from,
  Map<BlockNode, BlockAnchor> anchors,
) {
  if (node is! Map) return (null, 0);
  final String type = _string(node['type']);
  switch (type) {
    case 'paragraph':
      final List<InlineNode> spans = _inlines(node);
      final Paragraph block = Paragraph(spans, align: _align(node));
      return (block, _recordAnchor(block, from, spans, anchors));
    case 'heading':
      final List<InlineNode> spans = _inlines(node);
      final Heading block = Heading(
        level: _headingLevel(node),
        spans: spans,
        align: _align(node),
      );
      return (block, _recordAnchor(block, from, spans, anchors));
    case 'blockquote':
      final (List<BlockNode> children, int consumed) = _blocksAnchored(
        node,
        from,
        anchors,
      );
      return (Blockquote(children), consumed);
    case 'bulletList':
      final (List<ListItemBlock> items, int consumed) = _itemsAnchored(
        node,
        from,
        anchors,
      );
      return (ListBlock(ordered: false, items: items), consumed);
    case 'orderedList':
      final (List<ListItemBlock> items, int consumed) = _itemsAnchored(
        node,
        from,
        anchors,
      );
      return (
        ListBlock(ordered: true, start: _start(node), items: items),
        consumed,
      );
    case '':
      return (null, _rawTextLength(node));
    default:
      return (UnknownBlock(type), _rawTextLength(node));
  }
}

(List<BlockNode>, int) _blocksAnchored(
  Object? node,
  int from,
  Map<BlockNode, BlockAnchor> anchors,
) {
  final List<BlockNode> out = <BlockNode>[];
  int cursor = from;
  for (final Object? child in _children(node)) {
    final (BlockNode? block, int consumed) = _blockAnchored(
      child,
      cursor,
      anchors,
    );
    if (block != null) out.add(block);
    cursor += consumed;
  }
  return (out, cursor - from);
}

(List<ListItemBlock>, int) _itemsAnchored(
  Object? node,
  int from,
  Map<BlockNode, BlockAnchor> anchors,
) {
  final List<ListItemBlock> out = <ListItemBlock>[];
  int cursor = from;
  for (final Object? child in _children(node)) {
    if (child is! Map || _string(child['type']) != 'listItem') continue;
    final (List<BlockNode> children, int consumed) = _blocksAnchored(
      child,
      cursor,
      anchors,
    );
    out.add(ListItemBlock(children));
    cursor += consumed;
  }
  return (out, cursor - from);
}

/// Records the anchor for a [Paragraph]/[Heading] (identity-keyed) and returns its
/// length, which the caller uses to advance the running cursor. An empty block
/// contributes zero length and gets no map entry — a composer with a quoted empty
/// string is a broken-looking affordance for no benefit.
int _recordAnchor(
  BlockNode block,
  int from,
  List<InlineNode> spans,
  Map<BlockNode, BlockAnchor> anchors,
) {
  final String text = spans
      .whereType<TextRun>()
      .map((TextRun run) => run.text)
      .join();
  if (text.isNotEmpty) {
    anchors[block] = BlockAnchor(
      from: from,
      to: from + text.length,
      text: text,
    );
  }
  return text.length;
}

/// The total length of every `type: 'text'` leaf inside [node], at any depth —
/// mirrors the backend's `anchorText` walk exactly: it does not know about a
/// whitelist, so an unrecognized node type still contributes whatever text leaves
/// it contains, however deeply nested.
int _rawTextLength(Object? node) {
  if (node is! Map) return 0;
  int length = _string(node['type']) == 'text'
      ? _string(node['text']).length
      : 0;
  final Object? content = node['content'];
  if (content is List) {
    for (final Object? child in content) {
      length += _rawTextLength(child);
    }
  }
  return length;
}

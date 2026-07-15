/// TipTap-JSON ⇄ [EditorDocument] codec (M4 editor; docs/40 §19.4, §42.1).
///
/// The single translation between the editor's block model and the `content`
/// document the backend stores. It emits ONLY the server-whitelisted shape (root
/// `doc`; blocks paragraph / heading 2–4 / blockquote / bullet+ordered list; marks
/// bold / italic / underline; `hardBreak` for soft breaks) so a round-trip can
/// never yield a document the sanitizer rejects (422 `PIECE_CONTENT_INVALID`).
///
/// Decoding is tolerant (mirrors the reader's parser): unknown nodes/marks and
/// malformed shapes degrade rather than throw. Inline mentions/hashtags/footnotes
/// authored on other clients are flattened to their display text on decode (the
/// mobile editor does not create them); this is lossy-but-safe (plain text is
/// always valid) and documented, matching the reader's no-link-mark stance
/// (see the m3 contract notes).
library;

import 'editor_block.dart';
import 'editor_document.dart';
import 'marked_text.dart' show MarkRange, MarkedText, StyledRun, TextMark;

/// Encode an [EditorDocument] into a TipTap `doc` map (the `content` payload).
Map<String, dynamic> encodeDocument(EditorDocument doc) {
  return <String, dynamic>{
    'type': 'doc',
    'content': <Map<String, dynamic>>[
      for (final EditorBlock block in doc.blocks) ..._encodeBlock(block),
    ],
  };
}

/// Decode a TipTap `doc` map into an [EditorDocument]. Any non-doc / empty shape
/// yields a blank document so the editor always has something to edit.
EditorDocument decodeDocument(Map<String, dynamic>? doc) {
  final List<EditorBlock> blocks = <EditorBlock>[];
  int counter = 0;
  String nextId() => 'b${counter++}';

  for (final Object? node in _content(doc)) {
    final EditorBlock? block = _decodeBlock(node, nextId);
    if (block != null) blocks.add(block);
  }
  if (blocks.isEmpty) return EditorDocument.blank();
  return EditorDocument.of(blocks);
}

// ── Encoding ───────────────────────────────────────────────────────────────────

/// A block may encode to zero-or-more nodes (a block never does, but the shape
/// keeps callers uniform and future-proof).
List<Map<String, dynamic>> _encodeBlock(EditorBlock block) {
  switch (block.type) {
    case EditorBlockType.paragraph:
      return <Map<String, dynamic>>[
        <String, dynamic>{'type': 'paragraph', 'content': _inlines(block.text)},
      ];
    case EditorBlockType.heading2:
    case EditorBlockType.heading3:
    case EditorBlockType.heading4:
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'type': 'heading',
          'attrs': <String, dynamic>{'level': block.type.headingLevel},
          'content': _inlines(block.text),
        },
      ];
    case EditorBlockType.blockquote:
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'type': 'blockquote',
          'content': <Map<String, dynamic>>[
            for (final MarkedText line in _lines(block.text))
              <String, dynamic>{'type': 'paragraph', 'content': _inlines(line)},
          ],
        },
      ];
    case EditorBlockType.bulletList:
    case EditorBlockType.orderedList:
      final bool ordered = block.type == EditorBlockType.orderedList;
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'type': ordered ? 'orderedList' : 'bulletList',
          if (ordered && block.listStart != 1)
            'attrs': <String, dynamic>{'start': block.listStart},
          'content': <Map<String, dynamic>>[
            for (final MarkedText item in _lines(block.text))
              <String, dynamic>{
                'type': 'listItem',
                'content': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'type': 'paragraph',
                    'content': _inlines(item),
                  },
                ],
              },
          ],
        },
      ];
  }
}

/// A block's text as inline nodes: styled `text` nodes split by `hardBreak` on
/// newlines. An empty run yields an empty content list (a valid empty paragraph).
List<Map<String, dynamic>> _inlines(MarkedText text) {
  final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
  for (final StyledRun run in text.runs()) {
    final List<String> segments = run.text.split('\n');
    for (int i = 0; i < segments.length; i++) {
      if (i > 0) out.add(<String, dynamic>{'type': 'hardBreak'});
      final String seg = segments[i];
      if (seg.isEmpty) continue;
      out.add(<String, dynamic>{
        'type': 'text',
        'text': seg,
        if (run.marks.isNotEmpty)
          'marks': <Map<String, dynamic>>[
            for (final TextMark m in _orderedMarks(run.marks))
              <String, dynamic>{'type': m.name},
          ],
      });
    }
  }
  return out;
}

/// Newline-separated lines of a [MarkedText], marks preserved per line — the list
/// items / blockquote paragraphs of a multi-line block.
List<MarkedText> _lines(MarkedText text) {
  final String raw = text.text;
  if (!raw.contains('\n')) return <MarkedText>[text];
  final List<MarkedText> out = <MarkedText>[];
  int start = 0;
  for (int i = 0; i <= raw.length; i++) {
    if (i == raw.length || raw[i] == '\n') {
      out.add(text.slice(start, i));
      start = i + 1;
    }
  }
  return out;
}

List<TextMark> _orderedMarks(Set<TextMark> marks) => <TextMark>[
  for (final TextMark m in TextMark.values)
    if (marks.contains(m)) m,
];

// ── Decoding ─────────────────────────────────────────────────────────────────

EditorBlock? _decodeBlock(Object? node, String Function() nextId) {
  if (node is! Map) return null;
  final String type = _string(node['type']);
  switch (type) {
    case 'paragraph':
      return EditorBlock(
        id: nextId(),
        type: EditorBlockType.paragraph,
        text: _markedFromInlines(node['content']),
      );
    case 'heading':
      final int level = _headingLevel(node);
      return EditorBlock(
        id: nextId(),
        type: EditorBlockType.headingForLevel(level),
        text: _markedFromInlines(node['content']),
      );
    case 'blockquote':
      return EditorBlock(
        id: nextId(),
        type: EditorBlockType.blockquote,
        text: _joinChildParagraphs(node['content']),
      );
    case 'bulletList':
    case 'orderedList':
      return EditorBlock(
        id: nextId(),
        type: type == 'orderedList'
            ? EditorBlockType.orderedList
            : EditorBlockType.bulletList,
        text: _joinListItems(node['content']),
        listStart: type == 'orderedList' ? _start(node) : 1,
      );
    default:
      return null; // hardBreak/unknown at top level — skipped, forward-compatible.
  }
}

/// Join the paragraphs inside a blockquote/listItem into one newline-separated
/// [MarkedText] (the block's single editable run), preserving marks.
MarkedText _joinChildParagraphs(Object? content) {
  final List<MarkedText> parts = <MarkedText>[];
  for (final Object? child in _asList(content)) {
    if (child is! Map) continue;
    if (_string(child['type']) == 'paragraph') {
      parts.add(_markedFromInlines(child['content']));
    }
  }
  return _joinLines(parts);
}

MarkedText _joinListItems(Object? content) {
  final List<MarkedText> items = <MarkedText>[];
  for (final Object? child in _asList(content)) {
    if (child is! Map) continue;
    if (_string(child['type']) != 'listItem') continue;
    items.add(_joinChildParagraphs(child['content']));
  }
  return _joinLines(items);
}

MarkedText _joinLines(List<MarkedText> lines) {
  if (lines.isEmpty) return MarkedText.empty;
  MarkedText acc = lines.first;
  for (int i = 1; i < lines.length; i++) {
    acc = acc.concat(MarkedText.plain('\n')).concat(lines[i]);
  }
  return acc;
}

/// Build a [MarkedText] from a paragraph/heading `content` array: concatenate text
/// nodes (carrying bold/italic/underline), turn `hardBreak` into '\n', and flatten
/// mention/hashtag to their display text (footnote/unknown dropped).
MarkedText _markedFromInlines(Object? content) {
  final StringBuffer buffer = StringBuffer();
  final List<MarkRange> ranges = <MarkRange>[];
  for (final Object? child in _asList(content)) {
    if (child is! Map) continue;
    switch (_string(child['type'])) {
      case 'text':
        final String text = _string(child['text']);
        if (text.isEmpty) break;
        final int start = buffer.length;
        buffer.write(text);
        for (final TextMark mark in _marks(child['marks'])) {
          ranges.add(MarkRange(start, start + text.length, mark));
        }
      case 'hardBreak':
        buffer.write('\n');
      case 'mention':
        final String label = _string(_attr(child, 'label'));
        if (label.isNotEmpty) buffer.write('@$label');
      case 'hashtag':
        final String tag = _string(_attr(child, 'tag'));
        if (tag.isNotEmpty) buffer.write('#$tag');
      // footnote / unknown → dropped (no display text).
    }
  }
  return MarkedText(buffer.toString(), ranges);
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

List<Object?> _content(Map<String, dynamic>? doc) {
  final Object? content = doc?['content'];
  return content is List ? content : const <Object?>[];
}

List<Object?> _asList(Object? value) =>
    value is List ? value : const <Object?>[];

String _string(Object? value) => value is String ? value : '';

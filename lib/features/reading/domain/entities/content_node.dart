/// The typed reading-content model (docs/40 §19.4, docs/41 §35).
///
/// `pieces.content` is TipTap (ProseMirror) JSON. Rather than let the reading
/// renderer walk raw maps, the data layer parses it once into this immutable,
/// exhaustively-matchable tree (see `data/mappers/content_mapper.dart`). The tree
/// mirrors the SERVER whitelist exactly (the server is authoritative and rejects
/// anything outside it): nodes `doc, paragraph, heading(2–4), blockquote,
/// bulletList, orderedList, listItem, hardBreak, footnote, mention, hashtag`;
/// marks `bold, italic, underline`. There is deliberately NO image node in body
/// content (only the piece's cover image) and NO link mark.
///
/// Forward-compatibility (docs/40 §18.2): any node/mark the server later adds that
/// this client does not model parses to an [UnknownBlock] / [UnknownInline] and is
/// rendered gracefully (skipped or a subtle placeholder), never crashing.
///
/// Pure Dart — no Flutter, no I/O. Hand-written sealed classes (like `Result`) so
/// the renderer pattern-matches with an exhaustive `switch` and no code-gen.
library;

/// Inline text emphasis. Urdu (Nastaliq) suppresses italic at render time
/// (docs/41 §4.4) — the mark may still be present in the data.
enum TextMark { bold, italic, underline }

/// Block text alignment (`paragraph.textAlign` / `heading.textAlign`). Physical
/// values as they cross the wire; the renderer resolves the default from the
/// piece's reading direction.
enum ContentAlign { left, right, center, justify }

// ── Inline nodes (the leaves of a paragraph/heading) ─────────────────────────

sealed class InlineNode {
  const InlineNode();
}

/// A run of text carrying zero or more [marks].
final class TextRun extends InlineNode {
  const TextRun(this.text, {this.marks = const <TextMark>{}});

  final String text;
  final Set<TextMark> marks;
}

/// A `hardBreak` — a line break within a block.
final class LineBreak extends InlineNode {
  const LineBreak();
}

/// A `footnote` reference (`{ id }`) — tap-to-reveal in the reader (docs/41 §35).
final class FootnoteRef extends InlineNode {
  const FootnoteRef(this.id);

  final String id;
}

/// A `mention` (`{ userId, label }`) — tappable, bidi-isolated (docs/41 §35).
final class Mention extends InlineNode {
  const Mention({required this.userId, required this.label});

  final String userId;
  final String label;
}

/// A `hashtag` (`{ tag }`) — tappable, bidi-isolated.
final class Hashtag extends InlineNode {
  const Hashtag(this.tag);

  final String tag;
}

/// Any inline node type this client does not model — rendered as inert text so a
/// future additive node never breaks an older client.
final class UnknownInline extends InlineNode {
  const UnknownInline(this.type);

  final String type;
}

// ── Block nodes ──────────────────────────────────────────────────────────────

sealed class BlockNode {
  const BlockNode();
}

final class Paragraph extends BlockNode {
  const Paragraph(this.spans, {this.align});

  final List<InlineNode> spans;
  final ContentAlign? align;
}

final class Heading extends BlockNode {
  const Heading({required this.level, required this.spans, this.align});

  /// Whitelisted to 2–4 (H1 is not allowed by the server, docs §19.4).
  final int level;
  final List<InlineNode> spans;
  final ContentAlign? align;
}

final class Blockquote extends BlockNode {
  const Blockquote(this.children);

  final List<BlockNode> children;
}

/// A bulleted or numbered list. [ordered] distinguishes the two; [start] is the
/// first ordinal for ordered lists (1 for bullets).
final class ListBlock extends BlockNode {
  const ListBlock({required this.ordered, required this.items, this.start = 1});

  final bool ordered;
  final int start;
  final List<ListItemBlock> items;
}

/// A single `listItem` — holds block content (usually one paragraph).
final class ListItemBlock {
  const ListItemBlock(this.children);

  final List<BlockNode> children;
}

/// Any block node type this client does not model — rendered as nothing (or a
/// subtle "unsupported" placeholder) so additive server nodes degrade gracefully.
final class UnknownBlock extends BlockNode {
  const UnknownBlock(this.type);

  final String type;
}

/// A parsed piece body — the ordered top-level blocks of the `doc`.
class PieceContent {
  const PieceContent(this.blocks);

  final List<BlockNode> blocks;

  static const PieceContent empty = PieceContent(<BlockNode>[]);

  bool get isEmpty => blocks.isEmpty;
}

/// The block editor surface (M4). Renders the [EditorDocument] as a vertical list
/// of per-block text fields, each backed by a [RichTextEditingController]. Owns the
/// controllers + focus nodes (keyed by block id) and reconciles them against the
/// controller state, so structural edits (split/merge/type-change) and mark toggles
/// reflect without cursor jumps. All logic lives in [CurrentDraftController]; this
/// widget only wires input → notifier and paints the result.
///
/// Interaction: Enter splits a block (a new item in a list block); Backspace at the
/// start of a block merges it into the previous one (best-effort on soft keyboards,
/// reliable on hardware — docs/40 §45). Selection changes are pushed to the
/// [EditorSelectionController] for the formatting toolbar.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../domain/editor/editor_block.dart';
import '../../domain/editor/editor_document.dart';
import '../../domain/editor/marked_text.dart';
import '../controllers/current_draft_controller.dart';
import '../controllers/editor_state.dart';
import 'editor_selection_controller.dart';
import 'rich_text_controller.dart';

class BlockEditor extends ConsumerStatefulWidget {
  const BlockEditor({
    required this.routeId,
    required this.baseFontSize,
    required this.lineHeight,
    required this.direction,
    required this.placeholder,
    this.textColor,
    this.hintColor,
    super.key,
  });

  final String routeId;
  final double baseFontSize;
  final double lineHeight;
  final TextDirectionKind direction;
  final String placeholder;

  /// Optional writing-surface overrides (editor sepia/dark theme). Fall back to
  /// the design-system text tokens when null.
  final Color? textColor;
  final Color? hintColor;

  @override
  ConsumerState<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends ConsumerState<BlockEditor> {
  final Map<String, RichTextEditingController> _controllers =
      <String, RichTextEditingController>{};
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  final Map<String, String> _lastText = <String, String>{};
  bool _reconciling = false;

  bool get _isRtl => widget.direction == TextDirectionKind.rtl;

  CurrentDraftController get _notifier =>
      ref.read(currentDraftControllerProvider(widget.routeId).notifier);

  @override
  void dispose() {
    for (final RichTextEditingController c in _controllers.values) {
      c.dispose();
    }
    for (final FocusNode n in _focusNodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EditorState? st = ref
        .watch(currentDraftControllerProvider(widget.routeId))
        .asData
        ?.value;
    if (st == null) return const SizedBox.shrink();
    final EditorDocument doc = st.document;
    _reconcile(doc);
    _handleFocusRequest(st);

    final QTokens tokens = QTokens.of(context);
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (int i, EditorBlock block) in doc.blocks.indexed)
            _BlockField(
              key: ValueKey<String>(block.id),
              block: block,
              controller: _controllers[block.id]!,
              focusNode: _focusNodes[block.id]!,
              tokens: tokens,
              baseStyle: _styleFor(block, tokens),
              isRtl: _isRtl,
              hintColor: widget.hintColor ?? tokens.colors.textMuted,
              placeholder: i == 0 ? widget.placeholder : null,
              onBackspaceAtStart: () => _onBackspaceAtStart(block.id, doc),
            ),
        ],
      ),
    );
  }

  // ── Reconciliation ─────────────────────────────────────────────────────────────

  void _reconcile(EditorDocument doc) {
    _reconciling = true;
    final Set<String> ids = <String>{
      for (final EditorBlock b in doc.blocks) b.id,
    };

    // Drop controllers for removed blocks.
    for (final String gone in _controllers.keys.toList()) {
      if (ids.contains(gone)) continue;
      _controllers.remove(gone)?.dispose();
      _focusNodes.remove(gone)?.dispose();
      _lastText.remove(gone);
    }

    for (final EditorBlock block in doc.blocks) {
      final RichTextEditingController? existing = _controllers[block.id];
      if (existing == null) {
        final RichTextEditingController c = RichTextEditingController(
          marked: block.text,
          suppressItalic: _isRtl,
        )..addListener(() => _onChanged(block.id));
        _controllers[block.id] = c;
        _focusNodes[block.id] = FocusNode();
        _lastText[block.id] = block.text.text;
      } else if (existing.marked != block.text) {
        // A non-typing change (mark toggle, split truncation, discard) — sync the
        // controller. Keep the full selection for a mark-only change (text same);
        // collapse the caret when the text itself changed.
        final bool sameText = existing.text == block.text.text;
        existing.setMarked(
          block.text,
          selection: sameText && existing.selection.isValid
              ? existing.selection
              : null,
        );
        _lastText[block.id] = block.text.text;
      }
    }
    _reconciling = false;
  }

  void _handleFocusRequest(EditorState st) {
    final FocusRequest? focus = st.focus;
    if (focus == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RichTextEditingController? c = _controllers[focus.blockId];
      final FocusNode? node = _focusNodes[focus.blockId];
      if (c != null && node != null) {
        c.selection = TextSelection.collapsed(
          offset: focus.caret.clamp(0, c.text.length),
        );
        node.requestFocus();
      }
      _notifier.clearFocus();
    });
  }

  // ── Input → notifier ────────────────────────────────────────────────────────────

  void _onChanged(String id) {
    if (_reconciling) return;
    final RichTextEditingController? c = _controllers[id];
    if (c == null) return;
    final MarkedText marked = c.marked;
    _pushSelection(id, c);
    if (marked.text == _lastText[id]) return; // selection-only change
    _lastText[id] = marked.text;
    _handleTextChange(id, marked);
  }

  void _handleTextChange(String id, MarkedText marked) {
    final EditorState? st = ref
        .read(currentDraftControllerProvider(widget.routeId))
        .asData
        ?.value;
    final EditorBlock? block = st?.document.blockById(id);
    final bool isList = block?.type.isList ?? false;

    if (!isList && marked.text.contains('\n')) {
      final int i = marked.text.indexOf('\n');
      final MarkedText cleaned = marked.replace(i, 1, '');
      _lastText[id] = cleaned.text;
      _notifier
        ..updateBlockText(id, cleaned)
        ..splitBlock(id, i);
      return;
    }
    _notifier.updateBlockText(id, marked);
  }

  void _pushSelection(String id, RichTextEditingController c) {
    final TextSelection sel = c.selection;
    if (!sel.isValid) return;
    ref
        .read(editorSelectionControllerProvider.notifier)
        .set(id, sel.start, sel.end);
  }

  void _onBackspaceAtStart(String id, EditorDocument doc) {
    if (doc.indexOfId(id) > 0) _notifier.mergeBackward(id);
  }

  // ── Per-type styling ─────────────────────────────────────────────────────────────

  TextStyle _styleFor(EditorBlock block, QTokens tokens) {
    final TextStyle base = TextStyle(
      fontSize: widget.baseFontSize,
      height: widget.lineHeight,
      color: widget.textColor ?? tokens.colors.textPrimary,
    );
    return switch (block.type) {
      EditorBlockType.heading2 => base.copyWith(
        fontSize: widget.baseFontSize * 1.5,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      EditorBlockType.heading3 => base.copyWith(
        fontSize: widget.baseFontSize * 1.3,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      EditorBlockType.heading4 => base.copyWith(
        fontSize: widget.baseFontSize * 1.15,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      EditorBlockType.blockquote => base.copyWith(
        color: tokens.colors.textSecondary,
        fontStyle: _isRtl ? FontStyle.normal : FontStyle.italic,
      ),
      _ => base,
    };
  }
}

/// One editable block. A [Focus] wraps the field so a Backspace that the field
/// leaves unconsumed (caret already at offset 0) bubbles up to merge blocks.
class _BlockField extends StatelessWidget {
  const _BlockField({
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.tokens,
    required this.baseStyle,
    required this.isRtl,
    required this.hintColor,
    required this.onBackspaceAtStart,
    this.placeholder,
    super.key,
  });

  final EditorBlock block;
  final RichTextEditingController controller;
  final FocusNode focusNode;
  final QTokens tokens;
  final TextStyle baseStyle;
  final bool isRtl;
  final Color hintColor;
  final String? placeholder;
  final VoidCallback onBackspaceAtStart;

  @override
  Widget build(BuildContext context) {
    final Widget field = TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      style: baseStyle,
      cursorColor: tokens.colors.accent,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: placeholder,
        hintStyle: baseStyle.copyWith(color: hintColor),
      ),
    );

    final Widget keyed = Focus(
      onKeyEvent: (FocusNode _, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controller.selection.isCollapsed &&
            controller.selection.baseOffset == 0) {
          onBackspaceAtStart();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: field,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: block.type.isHeading ? QSpacing.s4 : QSpacing.s1,
        bottom: QSpacing.s1,
      ),
      child: switch (block.type) {
        EditorBlockType.blockquote => _quoteWrap(keyed),
        EditorBlockType.bulletList ||
        EditorBlockType.orderedList => _listWrap(context, keyed),
        _ => keyed,
      },
    );
  }

  Widget _quoteWrap(Widget child) => Container(
    padding: const EdgeInsetsDirectional.only(start: QSpacing.s4),
    decoration: BoxDecoration(
      border: BorderDirectional(
        start: BorderSide(color: tokens.colors.accent, width: 3),
      ),
    ),
    child: child,
  );

  Widget _listWrap(BuildContext context, Widget child) {
    final bool ordered = block.type == EditorBlockType.orderedList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              ordered ? Icons.format_list_numbered : Icons.format_list_bulleted,
              size: 14,
              color: tokens.colors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              ordered ? 'Numbered list' : 'Bulleted list',
              style: TextStyle(fontSize: 11, color: tokens.colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 2),
        child,
      ],
    );
  }
}

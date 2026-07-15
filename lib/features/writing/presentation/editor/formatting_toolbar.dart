/// The persistent formatting toolbar (M4). Sits above the keyboard and toggles the
/// backend-whitelisted formatting for the focused block: inline bold/italic/
/// underline over the current selection, and the block type (paragraph, heading
/// 2–4, blockquote, bullet/ordered list). It holds NO editing logic — it reads the
/// active selection + block from providers and calls [CurrentDraftController].
///
/// Every control is a ≥44px, semantically-labelled tap target (docs/40 §a11y).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../domain/editor/editor_block.dart';
import '../../domain/editor/marked_text.dart';
import '../controllers/current_draft_controller.dart';
import '../controllers/editor_state.dart';
import 'editor_selection_controller.dart';

class FormattingToolbar extends ConsumerWidget {
  const FormattingToolbar({required this.routeId, super.key});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final EditorSelection? selection = ref.watch(
      editorSelectionControllerProvider,
    );
    final EditorState? st = ref
        .watch(currentDraftControllerProvider(routeId))
        .asData
        ?.value;
    final EditorBlock? block = (selection != null && st != null)
        ? st.document.blockById(selection.blockId)
        : null;

    final Set<TextMark> active =
        (block != null && selection != null && !selection.isCollapsed)
        ? block.text.activeMarks(selection.start, selection.end)
        : const <TextMark>{};
    final bool canMark = selection != null && !selection.isCollapsed;
    final bool hasBlock = block != null;
    final CurrentDraftController notifier = ref.read(
      currentDraftControllerProvider(routeId).notifier,
    );

    void toggle(TextMark mark) {
      if (block == null || selection == null) return;
      QHaptics.selection();
      notifier.toggleMark(block.id, mark, selection.start, selection.end);
    }

    void setType(EditorBlockType type) {
      if (block == null) return;
      QHaptics.selection();
      notifier.setBlockType(block.id, type);
    }

    return Material(
      color: tokens.colors.bgSurface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: <Widget>[
                  _ToolButton(
                    icon: Icons.format_bold,
                    tooltip: 'Bold',
                    active: active.contains(TextMark.bold),
                    enabled: canMark,
                    onTap: () => toggle(TextMark.bold),
                    tokens: tokens,
                  ),
                  _ToolButton(
                    icon: Icons.format_italic,
                    tooltip: 'Italic',
                    active: active.contains(TextMark.italic),
                    enabled: canMark,
                    onTap: () => toggle(TextMark.italic),
                    tokens: tokens,
                  ),
                  _ToolButton(
                    icon: Icons.format_underlined,
                    tooltip: 'Underline',
                    active: active.contains(TextMark.underline),
                    enabled: canMark,
                    onTap: () => toggle(TextMark.underline),
                    tokens: tokens,
                  ),
                  _Divider(tokens: tokens),
                  _ToolButton(
                    icon: Icons.notes,
                    tooltip: 'Paragraph',
                    active: block?.type == EditorBlockType.paragraph,
                    enabled: hasBlock,
                    onTap: () => setType(EditorBlockType.paragraph),
                    tokens: tokens,
                  ),
                  _ToolButton(
                    label: 'H2',
                    tooltip: 'Heading 2',
                    active: block?.type == EditorBlockType.heading2,
                    enabled: hasBlock,
                    onTap: () => setType(EditorBlockType.heading2),
                    tokens: tokens,
                  ),
                  _ToolButton(
                    label: 'H3',
                    tooltip: 'Heading 3',
                    active: block?.type == EditorBlockType.heading3,
                    enabled: hasBlock,
                    onTap: () => setType(EditorBlockType.heading3),
                    tokens: tokens,
                  ),
                  _ToolButton(
                    label: 'H4',
                    tooltip: 'Heading 4',
                    active: block?.type == EditorBlockType.heading4,
                    enabled: hasBlock,
                    onTap: () => setType(EditorBlockType.heading4),
                    tokens: tokens,
                  ),
                  _ToolButton(
                    icon: Icons.format_quote,
                    tooltip: 'Quote',
                    active: block?.type == EditorBlockType.blockquote,
                    enabled: hasBlock,
                    onTap: () => setType(EditorBlockType.blockquote),
                    tokens: tokens,
                  ),
                  _ToolButton(
                    icon: Icons.format_list_bulleted,
                    tooltip: 'Bulleted list',
                    active: block?.type == EditorBlockType.bulletList,
                    enabled: hasBlock,
                    onTap: () => setType(EditorBlockType.bulletList),
                    tokens: tokens,
                  ),
                  _ToolButton(
                    icon: Icons.format_list_numbered,
                    tooltip: 'Numbered list',
                    active: block?.type == EditorBlockType.orderedList,
                    enabled: hasBlock,
                    onTap: () => setType(EditorBlockType.orderedList),
                    tokens: tokens,
                  ),
                  _Divider(tokens: tokens),
                  _ToolButton(
                    icon: Icons.add,
                    tooltip: 'New block',
                    active: false,
                    enabled: st != null,
                    onTap: () {
                      final String? id =
                          block?.id ?? st?.document.blocks.last.id;
                      if (id == null) return;
                      QHaptics.selection();
                      notifier.addBlockAfter(id);
                    },
                    tokens: tokens,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.tooltip,
    required this.active,
    required this.enabled,
    required this.onTap,
    required this.tokens,
    this.icon,
    this.label,
  });

  final IconData? icon;
  final String? label;
  final String tooltip;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;
  final QTokens tokens;

  @override
  Widget build(BuildContext context) {
    final Color fg = !enabled
        ? tokens.colors.textMuted
        : active
        ? tokens.colors.accent
        : tokens.colors.textSecondary;
    return Semantics(
      button: true,
      enabled: enabled,
      toggled: active,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: QRadii.controlRadius,
          onTap: enabled ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: active ? tokens.colors.accentSubtle : Colors.transparent,
              borderRadius: QRadii.controlRadius,
            ),
            child: icon != null
                ? Icon(icon, size: 20, color: fg)
                : Text(
                    label!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.tokens});
  final QTokens tokens;

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 24,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    color: tokens.colors.border,
  );
}

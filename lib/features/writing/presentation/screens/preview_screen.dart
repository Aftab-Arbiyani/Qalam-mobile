/// Reading preview (M4; docs/40 §35.3). Renders the CURRENT (unsaved) draft the way
/// a reader will see it — theme-aware, per-script typography + direction, cover,
/// featured quote, estimated reading time, and a live reading-progress bar. It
/// renders the editor's own [EditorDocument] to widgets (no WebView, no HTML, and
/// no cross-feature import of the reader), so it works fully offline.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/content/reading_progress_bar.dart';
import '../../../../shared/widgets/media/q_network_image.dart';
import '../../domain/editor/editor_block.dart';
import '../../domain/editor/editor_document.dart';
import '../../domain/editor/marked_text.dart';
import '../../domain/entities/draft.dart';
import '../controllers/current_draft_controller.dart';
import '../controllers/editor_state.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({required this.draftId, super.key});

  final String draftId;

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _progress.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final double max = _scroll.position.maxScrollExtent;
    _progress.value = max <= 0 ? 1.0 : (_scroll.offset / max).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final EditorState? st = ref
        .watch(currentDraftControllerProvider(widget.draftId))
        .asData
        ?.value;
    final Draft draft = st?.liveDraft ?? _empty();
    final TextDirection dir = draft.isRtl
        ? TextDirection.rtl
        : TextDirection.ltr;
    final double top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: tokens.colors.bgCanvas,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.only(top: top + 52, bottom: QSpacing.s8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: QSpacing.s4,
                    ),
                    child: (st == null)
                        ? const SizedBox.shrink()
                        : _PreviewBody(
                            draft: draft,
                            document: st.document,
                            direction: dir,
                          ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: top,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (_, double value, _) =>
                  ReadingProgressBar(progress: value, direction: dir),
            ),
          ),
          Positioned(
            top: top,
            left: 0,
            right: 0,
            child: Material(
              color: tokens.colors.bgCanvas.withValues(alpha: 0.92),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back to editing',
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Draft _empty() => Draft(
    localId: widget.draftId,
    createdAt: DateTime.now().toUtc(),
    localUpdatedAt: DateTime.now().toUtc(),
  );
}

class _PreviewBody extends ConsumerWidget {
  const _PreviewBody({
    required this.draft,
    required this.document,
    required this.direction,
  });

  final Draft draft;
  final EditorDocument document;
  final TextDirection direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final String? coverUrl = draft.pendingCoverPath == null
        ? ref.watch(mediaUrlBuilderProvider).urlForKey(draft.coverImageKey)
        : null;

    final List<String> meta = <String>[
      if (draft.readingTimeMinutes > 0)
        readingTimeLabel(draft.readingTimeMinutes),
      if (draft.wordCount > 0) '${draft.wordCount} words',
      if (draft.languageName.isNotEmpty) draft.languageName,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (coverUrl != null) ...<Widget>[
          ClipRRect(
            borderRadius: QRadii.cardRadius,
            child: AspectRatio(
              aspectRatio: 2,
              child: QNetworkImage(url: coverUrl),
            ),
          ),
          Gap.v5,
        ],
        Directionality(
          textDirection: direction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                draft.title.trim().isEmpty ? 'Untitled' : draft.title.trim(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: tokens.colors.textPrimary,
                ),
              ),
              if (draft.subtitle.trim().isNotEmpty) ...<Widget>[
                Gap.v2,
                Text(
                  draft.subtitle.trim(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (meta.isNotEmpty) ...<Widget>[
          Gap.v3,
          Text(
            meta.join('  ·  '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
        ],
        Gap.v5,
        if (draft.hasFeaturedQuote) ...<Widget>[
          _Quote(quote: draft.featuredQuote.trim(), direction: direction),
          Gap.v5,
        ],
        _DocumentView(document: document, direction: direction),
        if (draft.tags.isNotEmpty) ...<Widget>[
          Gap.v4,
          Wrap(
            spacing: QSpacing.s2,
            runSpacing: QSpacing.s2,
            children: <Widget>[
              for (final String tag in draft.tags) QChip(label: '#$tag'),
            ],
          ),
        ],
      ],
    );
  }
}

/// Renders the editor's [EditorDocument] read-only (the reader's view of it).
class _DocumentView extends StatelessWidget {
  const _DocumentView({required this.document, required this.direction});

  final EditorDocument document;
  final TextDirection direction;

  bool get _isRtl => direction == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final TextStyle body = TextStyle(
      fontSize: 18,
      height: _isRtl ? 2.1 : 1.7,
      color: tokens.colors.textPrimary,
    );
    return Directionality(
      textDirection: direction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final EditorBlock block in document.blocks)
            Padding(
              padding: EdgeInsets.only(
                top: block.type.isHeading ? QSpacing.s4 : 0,
                bottom: QSpacing.s4,
              ),
              child: _block(block, body, tokens),
            ),
        ],
      ),
    );
  }

  Widget _block(EditorBlock block, TextStyle body, QTokens tokens) {
    switch (block.type) {
      case EditorBlockType.paragraph:
        return _text(block.text, body);
      case EditorBlockType.heading2:
        return _text(
          block.text,
          body.copyWith(
            fontSize: body.fontSize! * 1.5,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        );
      case EditorBlockType.heading3:
        return _text(
          block.text,
          body.copyWith(
            fontSize: body.fontSize! * 1.3,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        );
      case EditorBlockType.heading4:
        return _text(
          block.text,
          body.copyWith(
            fontSize: body.fontSize! * 1.15,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        );
      case EditorBlockType.blockquote:
        return Container(
          padding: const EdgeInsetsDirectional.only(start: QSpacing.s4),
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: tokens.colors.accent, width: 3),
            ),
          ),
          child: _text(
            block.text,
            body.copyWith(
              color: tokens.colors.textSecondary,
              fontStyle: _isRtl ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        );
      case EditorBlockType.bulletList:
      case EditorBlockType.orderedList:
        final List<String> lines = block.text.text.split('\n');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final (int i, String line) in lines.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: QSpacing.s2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 28,
                      child: Text(
                        block.type == EditorBlockType.orderedList
                            ? '${block.listStart + i}.'
                            : '•',
                        style: body.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Text(line, style: body)),
                  ],
                ),
              ),
          ],
        );
    }
  }

  Widget _text(MarkedText marked, TextStyle base) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          for (final StyledRun run in marked.runs())
            TextSpan(text: run.text, style: _apply(base, run.marks)),
        ],
      ),
    );
  }

  TextStyle _apply(TextStyle base, Set<TextMark> marks) {
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
}

class _Quote extends StatelessWidget {
  const _Quote({required this.quote, required this.direction});

  final String quote;
  final TextDirection direction;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(QSpacing.s4),
      decoration: BoxDecoration(
        color: tokens.colors.accentSubtle,
        borderRadius: QRadii.cardRadius,
      ),
      child: Directionality(
        textDirection: direction,
        child: Text(
          quote,
          style: TextStyle(
            fontSize: 20,
            height: 1.5,
            fontStyle: direction == TextDirection.rtl
                ? FontStyle.normal
                : FontStyle.italic,
            color: tokens.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

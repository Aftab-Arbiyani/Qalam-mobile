/// The writing editor (M4; docs/40 §10.1, §47 M6). A distraction-first, keyboard-
/// aware surface: cover, title, subtitle, the block body, and a collapsible details
/// section, with a persistent formatting toolbar above the keyboard. It owns its
/// own error boundary and degrades offline (edits autosave locally and queue).
///
/// All logic lives in [CurrentDraftController]; this screen wires input widgets to
/// it, reflects autosave/sync/offline status, and hosts the publish/preview/settings
/// affordances. Never performs I/O or business logic directly (docs/40 §44).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/layout/connectivity_banner.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../../ai/domain/value_objects/ai_feature_ids.dart';
import '../../../ai/presentation/panels/craft_coach_panel.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../../domain/entities/draft_sync.dart';
import '../../domain/value_objects/editor_preferences.dart';
import '../controllers/current_draft_controller.dart';
import '../controllers/editor_preferences_controller.dart';
import '../controllers/editor_state.dart';
import '../editor/block_editor.dart';
import '../editor/draft_ai_editor_target.dart';
import '../editor/formatting_toolbar.dart';
import '../widgets/cover_field.dart';
import '../widgets/draft_status_chips.dart';
import '../widgets/editor_preferences_sheet.dart';
import '../widgets/metadata_section.dart';
import '../widgets/publish_sheet.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({required this.draftId, super.key});

  final String draftId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with WidgetsBindingObserver {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _subtitle = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _seeded = false;
  bool _focusMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _title.dispose();
    _subtitle.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flush + push on background so nothing is lost if the app is killed.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_notifier.saveNow());
    }
  }

  CurrentDraftController get _notifier =>
      ref.read(currentDraftControllerProvider(widget.draftId).notifier);

  @override
  Widget build(BuildContext context) {
    final AsyncValue<EditorState> async = ref.watch(
      currentDraftControllerProvider(widget.draftId),
    );
    final EditorPreferences prefs = ref.watch(
      editorPreferencesControllerProvider,
    );
    final QTokens tokens = QTokens.of(context);
    final _EditorPalette palette = _EditorPalette.resolve(
      prefs.surface,
      tokens,
    );
    final EditorState? st = async.asData?.value;

    if (st != null && !_seeded) {
      _title.text = st.draft.title;
      _subtitle.text = st.draft.subtitle;
      _seeded = true;
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _appBar(st, tokens),
      bottomSheet: st == null
          ? null
          : FormattingToolbar(routeId: widget.draftId),
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => _error(error),
        data: (EditorState state) => _body(state, prefs, palette),
      ),
    );
  }

  PreferredSizeWidget _appBar(EditorState? st, QTokens tokens) {
    final bool aiOn = ref.watch(appConfigProvider).enableAi;
    final bool coachEnabled = aiOn &&
        (ref.watch(aiFeaturesProvider).asData?.value.isEnabled(AiFeatureIds.craftCoach) ?? false);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: () async {
          await _notifier.saveNow();
          if (mounted) context.pop();
        },
      ),
      title: st == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: AutosaveIndicator(
                    autosaving: st.autosaving,
                    saved: st.draft.syncState != DraftSyncState.pending,
                  ),
                ),
                if (st.draft.syncState != DraftSyncState.synced) ...<Widget>[
                  const SizedBox(width: QSpacing.s3),
                  Flexible(child: SyncStateChip(state: st.draft.syncState)),
                ],
              ],
            ),
      actions: st == null
          ? null
          : <Widget>[
              const Padding(
                padding: EdgeInsets.only(right: QSpacing.s2),
                child: Center(child: OfflineChip()),
              ),
              if (coachEnabled)
                IconButton(
                  icon: const Icon(Icons.school_outlined),
                  tooltip: 'Craft coach',
                  onPressed: () => unawaited(
                    CraftCoachPanel.show(
                      context,
                      writingContext: DraftAiEditorTarget.build(ref, widget.draftId).context,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  _focusMode ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
                tooltip: _focusMode ? 'Exit focus mode' : 'Focus mode',
                onPressed: () => setState(() => _focusMode = !_focusMode),
              ),
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'Preview',
                onPressed: () async {
                  await _notifier.saveNow();
                  if (mounted) {
                    unawaited(
                      context.push(Routes.piecePreviewPath(widget.draftId)),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Editor settings',
                onPressed: () => QBottomSheet.show<void>(
                  context,
                  builder: (_) => const EditorPreferencesSheet(),
                ),
              ),
              _overflow(st),
              TextButton(
                onPressed: () => _openPublish(st),
                child: Text(
                  st.draft.isPublished ? 'Update' : 'Publish',
                  style: TextStyle(
                    color: tokens.colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
    );
  }

  Widget _overflow(EditorState st) {
    final bool aiOn = ref.watch(appConfigProvider).enableAi;
    final bool anyAi = aiOn &&
        ((ref.watch(aiFeaturesProvider).asData?.value.isEnabled(AiFeatureIds.writingAssistant) ??
                false) ||
            (ref.watch(aiFeaturesProvider).asData?.value.isEnabled(AiFeatureIds.craftCoach) ??
                false));
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) => _onMenu(value, st),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'save', child: Text('Save draft')),
        const PopupMenuItem<String>(value: 'discard', child: Text('Discard changes')),
        const PopupMenuItem<String>(value: 'delete', child: Text('Delete draft')),
        if (anyAi) ...<PopupMenuEntry<String>>[
          const PopupMenuDivider(),
          const PopupMenuItem<String>(value: 'ai_conversations', child: Text('AI conversations')),
          const PopupMenuItem<String>(value: 'ai_prompts', child: Text('Prompt library')),
          const PopupMenuItem<String>(value: 'ai_usage', child: Text('AI usage')),
        ],
      ],
    );
  }

  Widget _body(
    EditorState st,
    EditorPreferences prefs,
    _EditorPalette palette,
  ) {
    final bool rtl = st.draft.isRtl;
    final double toolbarInset =
        48 + MediaQuery.paddingOf(context).bottom + QSpacing.s5;

    return Column(
      children: <Widget>[
        const ConnectivityBanner(),
        if (st.draft.syncState == DraftSyncState.conflict)
          _ConflictBanner(routeId: widget.draftId),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.only(bottom: toolbarInset),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: prefs.width.maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (!_focusMode) ...<Widget>[
                        Gap.v2,
                        CoverField(routeId: widget.draftId),
                        Gap.v4,
                      ],
                      _MetaTextField(
                        controller: _title,
                        hint: 'Title',
                        rtl: rtl,
                        color: palette.foreground,
                        hintColor: palette.muted,
                        style: Theme.of(context).textTheme.headlineSmall,
                        onChanged: _notifier.setTitle,
                      ),
                      _MetaTextField(
                        controller: _subtitle,
                        hint: 'Subtitle (optional)',
                        rtl: rtl,
                        color: palette.secondary,
                        hintColor: palette.muted,
                        style: Theme.of(context).textTheme.titleMedium,
                        onChanged: _notifier.setSubtitle,
                      ),
                      Gap.v3,
                      BlockEditor(
                        routeId: widget.draftId,
                        baseFontSize: prefs.bodyPx(st.draft.direction),
                        lineHeight: prefs.lineHeightFor(st.draft.direction),
                        direction: st.draft.direction,
                        placeholder: 'Tell your story…',
                        textColor: palette.foreground,
                        hintColor: palette.muted,
                      ),
                      if (!_focusMode) ...<Widget>[
                        Gap.v6,
                        Divider(color: QTokens.of(context).colors.border),
                        Gap.v5,
                        MetadataSection(routeId: widget.draftId),
                        const SizedBox(height: QSpacing.s7),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _error(Object error) {
    final Failure failure = error is Failure
        ? error
        : Failure.unexpected(code: 'API_UNEXPECTED_ERROR', message: '$error');
    return QErrorView(
      failure: failure,
      onRetry: () =>
          ref.invalidate(currentDraftControllerProvider(widget.draftId)),
    );
  }

  Future<void> _onMenu(String value, EditorState st) async {
    switch (value) {
      case 'save':
        await _notifier.saveNow();
        if (mounted) {
          QSnackbar.show(context, message: 'Saved');
        }
      case 'discard':
        final bool ok = await _confirm(
          title: 'Discard changes?',
          body: 'Your unsaved changes will be lost.',
          confirmLabel: 'Discard',
          danger: true,
        );
        if (!ok) return;
        await _notifier.discardChanges();
        if (mounted && !st.draft.isRemote) context.pop();
      case 'delete':
        final bool ok = await _confirm(
          title: 'Delete this draft?',
          body: "This can't be undone.",
          confirmLabel: 'Delete',
          danger: true,
        );
        if (!ok) return;
        await _notifier.deleteDraft();
        if (mounted) {
          unawaited(QHaptics.medium());
          QSnackbar.show(context, message: 'Draft deleted');
          context.pop();
        }
      case 'ai_conversations':
        unawaited(context.push(Routes.aiConversations));
      case 'ai_prompts':
        unawaited(context.push(Routes.promptLibrary));
      case 'ai_usage':
        unawaited(context.push(Routes.aiUsage));
    }
  }

  Future<void> _openPublish(EditorState st) async {
    final bool? done = await QBottomSheet.show<bool>(
      context,
      builder: (_) => PublishSheet(routeId: widget.draftId),
    );
    if (done == true && mounted) {
      unawaited(QHaptics.medium());
      final EditorState? cur = ref
          .read(currentDraftControllerProvider(widget.draftId))
          .asData
          ?.value;
      final bool scheduled = cur?.draft.status == PieceStatus.scheduled;
      QSnackbar.show(
        context,
        message: scheduled ? 'Scheduled' : 'Published',
        variant: QSnackbarVariant.success,
      );
      context.pop();
    }
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    bool danger = false,
  }) async {
    final QTokens tokens = QTokens.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: danger ? tokens.colors.danger : tokens.colors.accent,
              ),
            ),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}

/// A plain (non-rich) metadata text field for the title / subtitle.
class _MetaTextField extends StatelessWidget {
  const _MetaTextField({
    required this.controller,
    required this.hint,
    required this.rtl,
    required this.color,
    required this.hintColor,
    required this.style,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool rtl;
  final Color color;
  final Color hintColor;
  final TextStyle? style;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextStyle resolved = (style ?? const TextStyle()).copyWith(
      color: color,
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: null,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      style: resolved,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: QSpacing.s2),
        hintText: hint,
        hintStyle: resolved.copyWith(color: hintColor),
      ),
    );
  }
}

class _ConflictBanner extends ConsumerWidget {
  const _ConflictBanner({required this.routeId});
  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    return Container(
      width: double.infinity,
      color: tokens.colors.warningBg,
      padding: const EdgeInsets.all(QSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'This piece changed on another device.',
            style: TextStyle(
              color: tokens.colors.warningText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.v1,
          Text(
            'Keep which version?',
            style: TextStyle(color: tokens.colors.warningText),
          ),
          Gap.v2,
          Row(
            children: <Widget>[
              TextButton(
                onPressed: () => ref
                    .read(currentDraftControllerProvider(routeId).notifier)
                    .resolveConflict(ConflictResolution.keepLocal),
                child: const Text('Keep mine'),
              ),
              TextButton(
                onPressed: () => ref
                    .read(currentDraftControllerProvider(routeId).notifier)
                    .resolveConflict(ConflictResolution.keepServer),
                child: const Text('Use the other version'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The resolved writing-surface palette for the chosen [EditorSurface].
class _EditorPalette {
  const _EditorPalette({
    required this.background,
    required this.foreground,
    required this.secondary,
    required this.muted,
  });

  final Color background;
  final Color foreground;
  final Color secondary;
  final Color muted;

  factory _EditorPalette.resolve(EditorSurface surface, QTokens tokens) {
    return switch (surface) {
      EditorSurface.system => _EditorPalette(
        background: tokens.colors.bgCanvas,
        foreground: tokens.colors.textPrimary,
        secondary: tokens.colors.textSecondary,
        muted: tokens.colors.textMuted,
      ),
      EditorSurface.sepia => const _EditorPalette(
        background: Color(0xFFF7F0E1),
        foreground: Color(0xFF3B352B),
        secondary: Color(0xFF6B655A),
        muted: Color(0xFF9C9484),
      ),
      EditorSurface.dark => const _EditorPalette(
        background: Color(0xFF16130F),
        foreground: Color(0xFFE7E1D4),
        secondary: Color(0xFFA69F90),
        muted: Color(0xFF7A7367),
      ),
    };
  }
}

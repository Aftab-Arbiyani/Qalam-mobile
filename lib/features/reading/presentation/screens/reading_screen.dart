/// The reading screen (docs/40 §10.2, docs/41 §35) — the immersive, chrome-receding
/// reader. Renders the cover (hero), rich typography, author card, featured quote,
/// TipTap content, tags; drives reading progress (auto-saved locally for resume),
/// reading-duration accrual, and the view/read analytics beacons. Owns its own
/// error boundary; degrades to a cached copy offline.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/reading_history/reading_history_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/motion_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/content/reading_progress_bar.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';
import '../../../../shared/widgets/media/q_network_image.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/content_parser.dart';
import '../../domain/entities/content_node.dart';
import '../../domain/entities/piece_detail.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/value_objects/reader_preferences.dart';
import '../controllers/engagement_controller.dart';
import '../controllers/piece_detail_controller.dart';
import '../controllers/reader_preferences_controller.dart';
import '../providers/reading_providers.dart';
import '../widgets/content_renderer.dart';
import '../widgets/quote_card.dart';
import '../widgets/reader_action_bar.dart';
import '../widgets/reader_author_card.dart';
import '../widgets/reader_settings_sheet.dart';

/// Hero tag for a piece cover, shared with list cards for a smooth transition.
String pieceCoverHeroTag(String pieceId) => 'piece-cover-$pieceId';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({required this.pieceId, super.key});

  final String pieceId;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);
  final ValueNotifier<bool> _chromeVisible = ValueNotifier<bool>(true);
  final Stopwatch _dwell = Stopwatch();

  Timer? _saveDebounce;
  PieceContent? _parsed;
  PieceDetail? _piece;
  // Captured while mounted so [dispose] can flush without touching `ref` (unsafe
  // after unmount, Riverpod contract).
  ReadingHistoryController? _history;
  ReadingRepository? _repo;
  bool _sessionStarted = false;
  bool _resumed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _finishSession();
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _progress.dispose();
    _chromeVisible.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final double max = _scroll.position.maxScrollExtent;
    final double fraction = max <= 0
        ? 1.0
        : (_scroll.offset / max).clamp(0.0, 1.0);
    _progress.value = fraction;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 1200), _saveProgress);
  }

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse &&
        _scroll.offset > 80) {
      _chromeVisible.value = false;
    } else if (notification.direction == ScrollDirection.forward) {
      _chromeVisible.value = true;
    }
    return false;
  }

  /// Begin a reading session once the piece is available: view beacon, dwell
  /// timer, seed the history entry, and resume the saved scroll position.
  void _startSession(PieceDetail piece) {
    _piece = piece;
    if (_sessionStarted) return;
    _sessionStarted = true;
    final ReadingHistoryController history = ref.read(
      readingHistoryControllerProvider.notifier,
    );
    final ReadingRepository repo = ref.read(readingRepositoryProvider);
    _history = history;
    _repo = repo;
    _dwell.start();
    unawaited(repo.recordView(piece.id));

    final double saved = history.positionFor(piece.id);
    _saveProgress(
      overrideProgress: saved,
    ); // ensure it appears in Recently Read now

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _resumed) return;
      _resumed = true;
      if (saved > 0.03 && saved < 0.98 && _scroll.hasClients) {
        _scroll.jumpTo(saved * _scroll.position.maxScrollExtent);
      }
    });
  }

  void _saveProgress({double? overrideProgress}) {
    final PieceDetail? piece = _piece;
    final ReadingHistoryController? history = _history;
    if (piece == null || history == null) return;
    final double fraction = overrideProgress ?? _progress.value;
    // Throttled saves advance the position only; dwell time is accrued once at end.
    history.record(
      pieceId: piece.id,
      title: piece.title,
      authorName: piece.author.displayName,
      authorUsername: piece.author.username,
      slug: piece.slug,
      coverImageKey: piece.coverImageKey,
      languageCode: piece.language?.code,
      direction: piece.direction,
      progress: fraction,
      completed: fraction >= 0.95,
    );
  }

  /// End the session: accrue dwell time, save the final position, and fire the
  /// read beacon (server applies the ≥30s AND ≥50% completion rule). Uses the
  /// captured references so it is safe from `dispose` (no `ref`).
  void _finishSession() {
    final PieceDetail? piece = _piece;
    final ReadingHistoryController? history = _history;
    final ReadingRepository? repo = _repo;
    if (piece == null || history == null || repo == null || !_sessionStarted) {
      return;
    }
    _dwell.stop();
    final int seconds = _dwell.elapsed.inSeconds;
    final double fraction = _progress.value;

    unawaited(
      history.record(
        pieceId: piece.id,
        title: piece.title,
        authorName: piece.author.displayName,
        authorUsername: piece.author.username,
        slug: piece.slug,
        coverImageKey: piece.coverImageKey,
        languageCode: piece.language?.code,
        direction: piece.direction,
        progress: fraction,
        sessionSeconds: seconds,
        completed: fraction >= 0.95,
      ),
    );
    if (seconds > 0) {
      unawaited(
        repo.recordRead(
          piece.id,
          durationSeconds: seconds,
          completionPct: (fraction * 100).round(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final AsyncValue<CachedDetail> async = ref.watch(
      pieceDetailControllerProvider(widget.pieceId),
    );
    final PieceDetail? piece = async.asData?.value.piece;

    return Scaffold(
      backgroundColor: tokens.colors.bgCanvas,
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const _ReaderScaffold(child: _ReaderSkeleton()),
        error: (Object error, StackTrace _) =>
            _ReaderScaffold(child: _error(error)),
        data: (CachedDetail cached) => _reader(cached, tokens),
      ),
      bottomNavigationBar: piece == null
          ? null
          : ReaderActionBar(pieceId: piece.id, slug: piece.slug),
    );
  }

  Widget _reader(CachedDetail cached, QTokens tokens) {
    final PieceDetail piece = cached.piece;
    _parsed ??= parsePieceContent(piece.content);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSession(piece);
    });

    final ReaderPreferences prefs = ref.watch(
      readerPreferencesControllerProvider,
    );
    final TextDirection dir = piece.direction == TextDirectionKind.rtl
        ? TextDirection.rtl
        : TextDirection.ltr;
    final double topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: NotificationListener<UserScrollNotification>(
            onNotification: _onUserScroll,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.only(top: topInset + 52, bottom: QSpacing.s7),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: prefs.width.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: QSpacing.s4,
                    ),
                    child: _ReaderBody(
                      piece: piece,
                      parsed: _parsed!,
                      prefs: prefs,
                      isStale: cached.isStale,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: topInset,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (_, double value, _) =>
                ReadingProgressBar(progress: value, direction: dir),
          ),
        ),
        Positioned(
          top: topInset,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<bool>(
            valueListenable: _chromeVisible,
            builder: (BuildContext context, bool visible, Widget? child) =>
                AnimatedSlide(
                  offset: visible ? Offset.zero : const Offset(0, -1),
                  duration: QDurations.base,
                  child: AnimatedOpacity(
                    opacity: visible ? 1 : 0,
                    duration: QDurations.base,
                    child: child,
                  ),
                ),
            child: _TopBar(onSettings: _openSettings),
          ),
        ),
      ],
    );
  }

  Widget _error(Object error) {
    final Failure failure = error is Failure
        ? error
        : Failure.unexpected(code: 'API_UNEXPECTED_ERROR', message: '$error');
    if (failure is NotFoundFailure) {
      return const QEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'This piece isn’t available.',
        message: 'It may have been unpublished or made private.',
      );
    }
    return QErrorView(
      failure: failure,
      onRetry: () => ref
          .read(pieceDetailControllerProvider(widget.pieceId).notifier)
          .refresh(),
    );
  }

  void _openSettings() {
    QBottomSheet.show<void>(
      context,
      builder: (_) => const ReaderSettingsSheet(),
    );
  }
}

/// A minimal top bar for the reader (back + reading settings). More actions live
/// in the bottom bar (docs/41 §35).
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Material(
      color: tokens.colors.bgCanvas.withValues(alpha: 0.92),
      child: SizedBox(
        height: 52,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => context.pop(),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.text_fields),
              tooltip: 'Reading settings',
              onPressed: onSettings,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a non-content reader state (loading/error) with a back affordance.
class _ReaderScaffold extends StatelessWidget {
  const _ReaderScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ReaderBody extends ConsumerWidget {
  const _ReaderBody({
    required this.piece,
    required this.parsed,
    required this.prefs,
    required this.isStale,
  });

  final PieceDetail piece;
  final PieceContent parsed;
  final ReaderPreferences prefs;
  final bool isStale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final TextDirection dir = piece.direction == TextDirectionKind.rtl
        ? TextDirection.rtl
        : TextDirection.ltr;
    final String? coverUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(piece.coverImageKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isStale) const _StaleNote(),
        if (piece.hasCover) ...<Widget>[
          Hero(
            tag: pieceCoverHeroTag(piece.id),
            child: ClipRRect(
              borderRadius: QRadii.cardRadius,
              child: AspectRatio(
                aspectRatio: 2,
                child: QNetworkImage(url: coverUrl),
              ),
            ),
          ),
          Gap.v5,
        ],
        Directionality(
          textDirection: dir,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                piece.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: tokens.colors.textPrimary,
                ),
              ),
              if (piece.subtitle != null &&
                  piece.subtitle!.trim().isNotEmpty) ...<Widget>[
                Gap.v2,
                Text(
                  piece.subtitle!.trim(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Gap.v4,
        ReaderAuthorCard(
          username: piece.author.username,
          fallbackName: piece.author.displayName,
        ),
        Gap.v3,
        _MetaRow(piece: piece),
        Gap.v5,
        if (piece.hasFeaturedQuote) ...<Widget>[
          QuoteCard(
            quote: piece.featuredQuote!.trim(),
            direction: piece.direction,
          ),
          Gap.v5,
        ],
        ContentRenderer(
          content: parsed,
          baseFontSize: prefs.bodyPx(piece.direction),
          lineHeight: prefs.lineHeightFor(piece.direction),
          direction: piece.direction,
        ),
        if (piece.tags.isNotEmpty) ...<Widget>[
          Gap.v4,
          Wrap(
            spacing: QSpacing.s2,
            runSpacing: QSpacing.s2,
            children: <Widget>[
              for (final tag in piece.tags)
                if (tag.name.isNotEmpty) QChip(label: '#${tag.name}'),
            ],
          ),
        ],
        Gap.v5,
        _SocialFooter(
          pieceId: piece.id,
          languageCode: piece.language?.code ?? 'ur',
        ),
      ],
    );
  }
}

/// Entry points to the piece's comments + responses (docs/40 §21.4). Counts come
/// from the engagement controller; tapping opens the dedicated screen.
class _SocialFooter extends ConsumerWidget {
  const _SocialFooter({required this.pieceId, required this.languageCode});

  final String pieceId;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final e = ref
        .watch(engagementControllerProvider(pieceId))
        .asData
        ?.value;
    return Column(
      children: <Widget>[
        Divider(color: tokens.colors.border),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.mode_comment_outlined),
          title: Text(l10n.commentsCount(e?.comments ?? 0)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(Routes.pieceCommentsPath(pieceId)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.forum_outlined),
          title: Text(l10n.responsesCount(e?.responses ?? 0)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(
            '${Routes.pieceResponsesPath(pieceId)}?lang=$languageCode',
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.piece});

  final PieceDetail piece;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.bodySmall?.copyWith(
      color: tokens.colors.textSecondary,
    );
    final List<String> parts = <String>[
      if (piece.publishedAt != null) readableDate(piece.publishedAt!),
      if (piece.readingTimeMinutes > 0)
        readingTimeLabel(piece.readingTimeMinutes),
      if (piece.language != null && piece.language!.nativeName.isNotEmpty)
        piece.language!.nativeName,
    ];

    return Wrap(
      spacing: QSpacing.s2,
      runSpacing: QSpacing.s1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        if (piece.genre != null && piece.genre!.name.isNotEmpty)
          QChip(label: piece.genre!.name, tone: QChipTone.accent),
        Text(parts.join('  ·  '), style: style),
      ],
    );
  }
}

class _StaleNote extends StatelessWidget {
  const _StaleNote();

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: QSpacing.s4),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: tokens.colors.textMuted,
          ),
          const SizedBox(width: 8),
          Text(
            'Offline — showing a saved copy.',
            style: TextStyle(fontSize: 13, color: tokens.colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ReaderSkeleton extends StatelessWidget {
  const _ReaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(QSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const QSkeleton(height: 28),
          Gap.v3,
          const QSkeleton(height: 28, width: 220),
          Gap.v5,
          QSkeleton.line(),
          Gap.v2,
          QSkeleton.line(),
          Gap.v2,
          const QSkeleton(width: 180),
        ],
      ),
    );
  }
}

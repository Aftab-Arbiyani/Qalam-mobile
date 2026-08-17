/// The reader's bottom action bar (docs/41 §35, §11.19). Like · Clap · Bookmark ·
/// Share · More, within thumb reach, with quiet counts, haptics, and optimistic
/// updates. "More" hosts Report, save-to-collection, and removing the viewer's
/// claps. Auth-gated actions prompt sign-in when signed out.
///
/// **Clap and Like both ship — one does not replace the other** (M7-3). A like is
/// a boolean; a clap is a 1..50 quantity with an all-or-nothing removal. The
/// batching, capping and optimism live in [EngagementController]; this is the
/// surface.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/social/report_sheet.dart';
import '../../../../shared/widgets/social/save_to_collection_sheet.dart';
import '../../domain/entities/piece_engagement.dart';
import '../controllers/engagement_controller.dart';

class ReaderActionBar extends ConsumerWidget {
  const ReaderActionBar({required this.pieceId, required this.slug, super.key});

  final String pieceId;
  final String? slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final PieceEngagement e =
        ref.watch(engagementControllerProvider(pieceId)).asData?.value ??
        PieceEngagement.empty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colors.bgSurface,
        border: Border(top: BorderSide(color: tokens.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _Action(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                active: e.hasLiked,
                activeColor: tokens.colors.accent,
                count: e.likes,
                semanticLabel: e.hasLiked ? 'Unlike' : 'Like',
                onTap: () => _guarded(context, ref, () {
                  QHaptics.selection();
                  ref
                      .read(engagementControllerProvider(pieceId).notifier)
                      .toggleLike();
                }),
              ),
              // A clap is NOT a like and does not replace one: a like is a
              // boolean, a clap is a 1..50 quantity. Both ship, side by side.
              //
              // The prominent number is the PIECE total (what a reader arriving
              // cold wants); the viewer's own contribution rides in the quiet
              // suffix and in the accessible name, because a bare number does
              // not say whose it is. At the cap the control goes INERT rather
              // than hidden or refused — a reader hammering a full button must
              // meet no error and no phantom increment.
              _Action(
                icon: Icons.volunteer_activism_outlined,
                activeIcon: Icons.volunteer_activism,
                active: e.clapCount > 0,
                activeColor: tokens.colors.accent,
                count: e.claps,
                ownCount: e.clapCount,
                enabled: e.clapCount < Limits.maxClapsPerUserPerPiece,
                semanticLabel: e.clapCount >= Limits.maxClapsPerUserPerPiece
                    ? "Clap — you've given all "
                          '${Limits.maxClapsPerUserPerPiece}'
                    : e.clapCount > 0
                    ? "Clap — you've given ${e.clapCount}"
                    : 'Clap',
                onTap: () => _guarded(context, ref, () {
                  QHaptics.selection();
                  ref
                      .read(engagementControllerProvider(pieceId).notifier)
                      .clap();
                }),
              ),
              _Action(
                icon: Icons.bookmark_border,
                activeIcon: Icons.bookmark,
                active: e.hasBookmarked,
                activeColor: tokens.colors.accent,
                semanticLabel: e.hasBookmarked ? 'Remove bookmark' : 'Bookmark',
                onTap: () => _guarded(context, ref, () {
                  QHaptics.selection();
                  ref
                      .read(engagementControllerProvider(pieceId).notifier)
                      .toggleBookmark();
                }),
              ),
              _Action(
                icon: Icons.ios_share,
                semanticLabel: 'Share',
                onTap: () => _share(context, ref),
              ),
              _Action(
                icon: Icons.more_horiz,
                semanticLabel: 'More actions',
                onTap: () => _more(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final String base = ref.read(appConfigProvider).shareBaseUrl;
    final String path = (slug != null && slug!.isNotEmpty) ? slug! : pieceId;
    await Clipboard.setData(ClipboardData(text: '$base/p/$path'));
    await QHaptics.light();
    if (ref.read(sessionControllerProvider).stateOrUnknown.isAuthenticated) {
      await ref
          .read(engagementControllerProvider(pieceId).notifier)
          .recordShare(ShareChannel.copyLink);
    }
    if (context.mounted) {
      QSnackbar.show(
        context,
        message: 'Link copied.',
        variant: QSnackbarVariant.success,
      );
    }
  }

  void _more(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int myClaps =
        ref
            .read(engagementControllerProvider(pieceId))
            .asData
            ?.value
            .clapCount ??
        0;
    QBottomSheet.show<void>(
      context,
      builder: (BuildContext sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.collections_bookmark_outlined),
              title: Text(l10n.saveToCollectionTitle),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _guarded(
                  context,
                  ref,
                  () => showSaveToCollectionSheet(context, pieceId: pieceId),
                );
              },
            ),
            // Removal is ALL-OR-NOTHING — `DELETE` takes every clap this viewer
            // has and there is no decrement endpoint, so there is no "−1" to
            // build. The label states the real effect and the real number.
            //
            // It lives in this sheet rather than beside the clap (web puts an
            // inline "Undo" there) because the bar is five thumb targets already
            // and a sixth, conditional one would crowd the row it appears in.
            // Recorded as an accepted arrangement difference in docs/48 §4.1.
            if (myClaps > 0)
              ListTile(
                leading: const Icon(Icons.backspace_outlined),
                title: Text(
                  myClaps == 1 ? 'Remove my clap' : 'Remove my $myClaps claps',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _guarded(
                    context,
                    ref,
                    () => ref
                        .read(engagementControllerProvider(pieceId).notifier)
                        .removeClaps(),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l10n.reportTitle),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _guarded(
                  context,
                  ref,
                  () => showReportSheet(
                    context,
                    entityType: ReportEntityType.piece,
                    entityId: pieceId,
                    title: l10n.reportPieceTitle,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Run [action] if signed in, else prompt to sign in (docs/40 §11).
  void _guarded(BuildContext context, WidgetRef ref, VoidCallback action) {
    if (ref.read(sessionControllerProvider).stateOrUnknown.isAuthenticated) {
      action();
      return;
    }
    QSnackbar.show(
      context,
      message: 'Sign in to do that.',
      actionLabel: 'Sign in',
      onAction: () =>
          context.push('${Routes.login}?returnTo=${Routes.piecePath(pieceId)}'),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.activeIcon,
    this.active = false,
    this.activeColor,
    this.count,
    this.ownCount,
    this.enabled = true,
  });

  final IconData icon;
  final IconData? activeIcon;
  final bool active;
  final Color? activeColor;
  final int? count;

  /// The VIEWER's own contribution, shown as a quiet suffix beside the public
  /// [count]. Only claps have one: a like is a boolean, so "1" would say
  /// nothing, whereas "· you 12" is the only thing that says whose 12 it is.
  final int? ownCount;

  /// False renders the control inert rather than hiding it — the reader can
  /// still see the counts and read WHY it will not respond (the cap), which is
  /// the house pattern for a limit that has been reached.
  final bool enabled;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final Color color = !enabled
        ? tokens.colors.textMuted
        : active
        ? (activeColor ?? tokens.colors.accent)
        : tokens.colors.textSecondary;
    final bool showCount = count != null && count! > 0;
    final bool showOwn = ownCount != null && ownCount! > 0;

    return Semantics(
      button: true,
      enabled: enabled,
      label: showCount ? '$semanticLabel, $count' : semanticLabel,
      child: InkResponse(
        onTap: enabled ? onTap : null,
        radius: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                active ? (activeIcon ?? icon) : icon,
                size: 24,
                color: color,
              ),
              if (showCount) ...<Widget>[
                const SizedBox(width: 6),
                Text('$count', style: TextStyle(fontSize: 13, color: color)),
              ],
              if (showOwn) ...<Widget>[
                const SizedBox(width: 4),
                Text(
                  '· $ownCount',
                  style: TextStyle(
                    fontSize: 12,
                    color: tokens.colors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

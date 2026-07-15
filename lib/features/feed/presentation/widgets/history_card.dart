/// A reading-history / continue-reading card (docs/41 §35). Cover thumb + title
/// (per-piece direction) + author, and — for an unfinished piece — a progress bar
/// with a "continue" affordance. Opens the reader by id (which resumes at the
/// saved position). Reused by the History tab and the Discover shelves.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/reading_history/reading_history_entry.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/content/reading_progress_bar.dart';
import '../../../../shared/widgets/media/q_network_image.dart';

class HistoryCard extends ConsumerWidget {
  const HistoryCard({required this.entry, this.onRemove, super.key});

  final ReadingHistoryEntry entry;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final String? coverUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(entry.coverImageKey);
    final TextDirection dir = entry.direction == TextDirectionKind.rtl
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QSpacing.s4,
        vertical: QSpacing.s1,
      ),
      child: Semantics(
        button: true,
        label:
            '${entry.title}. ${entry.isInProgress ? '${entry.progressPercent} percent read' : 'Read'}',
        child: QCard(
          padding: QCardPadding.md,
          onTap: () => context.push(Routes.piecePath(entry.pieceId)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: QRadii.controlRadius,
                    child: coverUrl == null
                        ? Container(
                            width: 52,
                            height: 52,
                            color: tokens.colors.bgRaised,
                            child: Icon(
                              Icons.menu_book_outlined,
                              size: 22,
                              color: tokens.colors.textMuted,
                            ),
                          )
                        : QNetworkImage(url: coverUrl, width: 52, height: 52),
                  ),
                  Gap.h3,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Directionality(
                          textDirection: dir,
                          child: Text(
                            entry.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.authorName.isNotEmpty
                              ? '${entry.authorName} · ${relativeTime(entry.lastReadAt)}'
                              : relativeTime(entry.lastReadAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onRemove != null)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: tokens.colors.textMuted,
                      ),
                      tooltip: 'Remove from history',
                      onPressed: onRemove,
                    ),
                ],
              ),
              if (entry.isInProgress) ...<Widget>[
                Gap.v2,
                ReadingProgressBar(
                  progress: entry.clampedProgress,
                  direction: dir,
                ),
                const SizedBox(height: 4),
                Text(
                  'Continue reading · ${entry.progressPercent}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.colors.accent,
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

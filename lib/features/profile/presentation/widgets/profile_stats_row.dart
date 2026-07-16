/// A row of profile stat tiles (docs/41 §11). Each tile is a big value over a
/// muted label. Purely presentational — the screen decides which stats to pass
/// (My Profile: published/drafts/bookmarks/reading; Public: published/followers/
/// following), so the same widget serves both. A null value renders as "—".
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';

@immutable
class ProfileStat {
  const ProfileStat({required this.label, required this.value, this.onTap});

  final String label;

  /// The already-formatted value ("12", "50+", "—").
  final String value;

  /// Optional tap target (e.g. Followers → the followers list). Null = static.
  final VoidCallback? onTap;
}

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({required this.stats, super.key});

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: QSpacing.s4),
        child: Row(
          children: <Widget>[
            for (final ProfileStat stat in stats)
              Expanded(
                child: Semantics(
                  button: stat.onTap != null,
                  label: '${stat.value} ${stat.label}',
                  child: InkWell(
                    onTap: stat.onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          stat.value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat.label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

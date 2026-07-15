/// The profile bio block (docs/41 §11) — the free-text bio plus the genre chips.
/// Purely presentational over a [Profile]. Renders nothing when there is neither a
/// bio nor any genres (a fresh profile), letting the screen skip the section. The
/// default language is intentionally not shown: the frozen `v1` returns it as an
/// opaque UUID with no client-side way to resolve it to a name (docs/40 §45).
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../domain/entities/profile.dart';

class ProfileBioBlock extends StatelessWidget {
  const ProfileBioBlock({required this.profile, super.key});

  final Profile profile;

  bool get _hasContent =>
      (profile.bio ?? '').trim().isNotEmpty || profile.genres.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if ((profile.bio ?? '').trim().isNotEmpty)
          Text(
            profile.bio!.trim(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.colors.textSecondary,
              height: 1.5,
            ),
          ),
        if (profile.genres.isNotEmpty) ...<Widget>[
          Gap.v3,
          Wrap(
            spacing: QSpacing.s2,
            runSpacing: QSpacing.s2,
            children: <Widget>[
              for (final genre in profile.genres)
                QChip(
                  label: genre.name.isNotEmpty ? genre.name : genre.slug,
                  tone: QChipTone.accent,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

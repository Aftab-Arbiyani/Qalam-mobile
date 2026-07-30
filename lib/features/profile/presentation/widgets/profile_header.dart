/// The profile header (docs/41 §11.11) — a cover banner with the avatar overlapping
/// its lower edge, then the display name, handle, location, and website. Shared by
/// My Profile and the read-only Public Profile. The avatar is wrapped in a [Hero]
/// (tag keyed by username) so it animates smoothly between surfaces.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../../../../shared/widgets/media/q_network_image.dart';
import '../../domain/entities/profile.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({required this.profile, this.trailing, super.key});

  final Profile profile;

  /// An optional action shown at the top-right of the header (e.g. Edit / Follow).
  final Widget? trailing;

  static const double _avatarSize = 88;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final String? bannerUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(profile.coverKey);
    final String? avatarUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(profile.avatarKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            _Banner(url: bannerUrl, tokens: tokens),
            Positioned(
              left: QSpacing.s4,
              bottom: -_avatarSize / 2,
              child: Hero(
                tag: 'profile-avatar-${profile.username}',
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: tokens.colors.bgCanvas,
                    shape: BoxShape.circle,
                  ),
                  child: QAvatar(
                    name: profile.displayName,
                    imageUrl: avatarUrl,
                    size: _avatarSize,
                  ),
                ),
              ),
            ),
            if (trailing != null)
              Positioned(
                right: QSpacing.s4,
                bottom: -QSpacing.s6 - 4,
                child: trailing!,
              ),
          ],
        ),
        const SizedBox(height: _avatarSize / 2 + QSpacing.s3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                profile.displayName,
                style: theme.textTheme.headlineSmall,
                semanticsLabel: 'Display name: ${profile.displayName}',
              ),
              const SizedBox(height: 2),
              Text(
                profile.handle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textMuted,
                ),
              ),
              if ((profile.location ?? '').isNotEmpty) ...<Widget>[
                Gap.v2,
                _MetaRow(
                  icon: Icons.place_outlined,
                  text: profile.location!,
                  tokens: tokens,
                ),
              ],
              if ((profile.websiteUrl ?? '').isNotEmpty) ...<Widget>[
                const SizedBox(height: QSpacing.s1),
                _MetaRow(
                  icon: Icons.link_outlined,
                  text: profile.websiteUrl!,
                  tokens: tokens,
                  accent: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.url, required this.tokens});

  final String? url;
  final QTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3,
      child: url == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    tokens.colors.accentSubtle,
                    tokens.colors.bgRaised,
                  ],
                ),
              ),
            )
          : QNetworkImage(url: url),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.text,
    required this.tokens,
    this.accent = false,
  });

  final IconData icon;
  final String text;
  final QTokens tokens;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final Color color = accent
        ? tokens.colors.accent
        : tokens.colors.textSecondary;
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: color),
        Gap.h2,
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

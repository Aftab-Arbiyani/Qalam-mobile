/// The reader's Author Card (docs/41 §35, §11.19). Loads the writer's profile by
/// username (for avatar, bio, follower count, and the follow relation) and offers
/// an optimistic Follow. Degrades gracefully: while loading it shows the byline
/// from the piece; on error it keeps the byline and hides the follow affordance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/content/author_byline.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../domain/entities/writer_profile.dart';
import '../controllers/writer_profile_controller.dart';

class ReaderAuthorCard extends ConsumerWidget {
  const ReaderAuthorCard({
    required this.username,
    required this.fallbackName,
    super.key,
  });

  final String username;
  final String fallbackName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WriterProfile> profile = ref.watch(
      writerProfileControllerProvider(username),
    );

    return QCard(
      child: profile.when(
        skipLoadingOnRefresh: true,
        data: (WriterProfile p) => _Loaded(profile: p),
        loading: () => AuthorByline(name: fallbackName, handle: '@$username'),
        error: (Object _, StackTrace _) =>
            AuthorByline(name: fallbackName, handle: '@$username'),
      ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.profile});

  final WriterProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final String? avatarUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(profile.avatarKey);
    final bool authed = ref
        .watch(sessionControllerProvider)
        .stateOrUnknown
        .isAuthenticated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AuthorByline(
          name: profile.displayName,
          handle: profile.handle,
          avatarUrl: avatarUrl,
          avatarSize: 44,
          meta:
              '${profile.followersCount} ${profile.followersCount == 1 ? 'follower' : 'followers'}',
          trailing: (profile.isSelf || !authed)
              ? null
              : _FollowButton(profile: profile),
        ),
        if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...<Widget>[
          Gap.v3,
          Text(
            profile.bio!.trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _FollowButton extends ConsumerWidget {
  const _FollowButton({required this.profile});

  final WriterProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool active = profile.isFollowing || profile.hasPendingRequest;
    final String label = profile.hasPendingRequest
        ? 'Requested'
        : (profile.isFollowing ? 'Following' : 'Follow');

    return QButton(
      label: label,
      size: QButtonSize.sm,
      variant: active ? QButtonVariant.secondary : QButtonVariant.primary,
      onPressed: () {
        QHaptics.selection();
        ref
            .read(writerProfileControllerProvider(profile.username).notifier)
            .toggleFollow();
      },
    );
  }
}

/// Public Profile (docs/40 §19, docs/13 §4.2) — a read-only author profile at
/// `/u/:username`, viewable signed-out. Shows the header, bio, and writer stats.
/// A private account viewed by a stranger comes back `restricted` — only the
/// header + counts render, behind a "this account is private" notice.
///
/// There is deliberately no published-pieces grid: the frozen `v1` has no endpoint
/// to list another author's pieces, so only the real `piecesPublished` COUNT is
/// shown (documented gap, docs/40 §45). Follow/response actions are a later epic.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/q_refresh.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/profile.dart';
import '../controllers/public_profile_controller.dart';
import '../widgets/profile_bio_block.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/profile_stats_row.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({required this.username, super.key});

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Profile> profileAsync = ref.watch(
      publicProfileControllerProvider(username),
    );

    return QScaffold(
      appBar: QAppBar(
        title: profileAsync.asData?.value.displayName ?? '@$username',
      ),
      body: profileAsync.when(
        loading: () => const ProfileSkeleton(),
        error: (Object error, _) => QErrorView(
          failure: error is Failure
              ? error
              : const Failure.unexpected(code: 'unknown'),
          onRetry: () => ref
              .read(publicProfileControllerProvider(username).notifier)
              .refresh(),
        ),
        data: (Profile profile) => QRefresh(
          onRefresh: () => ref
              .read(publicProfileControllerProvider(username).notifier)
              .refresh(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ProfileHeader(profile: profile),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  QSpacing.s4,
                  QSpacing.s4,
                  QSpacing.s4,
                  QSpacing.s6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ProfileStatsRow(
                      stats: <ProfileStat>[
                        ProfileStat(
                          label: 'Published',
                          value: '${profile.counts.piecesPublished}',
                        ),
                        ProfileStat(
                          label: 'Followers',
                          value: '${profile.counts.followers}',
                        ),
                        ProfileStat(
                          label: 'Following',
                          value: '${profile.counts.following}',
                        ),
                      ],
                    ),
                    if (profile.restricted) ...<Widget>[
                      Gap.v5,
                      _PrivateNotice(),
                    ] else ...<Widget>[
                      Gap.v5,
                      ProfileBioBlock(profile: profile),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivateNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Icon(Icons.lock_outline, color: tokens.colors.textMuted, size: 28),
        Gap.v2,
        Text(
          'This account is private.',
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Follow to see their bio and work.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: tokens.colors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

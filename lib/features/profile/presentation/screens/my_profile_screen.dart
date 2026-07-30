/// My Profile (docs/40 §19, docs/41 §11.11) — the `/me` tab. Shows the signed-in
/// user's header, bio, stats, and published-pieces grid, with an Edit action and a
/// Settings entry. Cache-then-network via [MyProfileController] (resolves offline);
/// pull-to-refresh and infinite pagination for the pieces. Replaces the M2 account
/// placeholder that previously sat on this tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/pagination/paged_list_state.dart';
import '../../../../shared/preferences/app_preferences_controllers.dart';
import '../../../../shared/preferences/content_privacy.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/q_refresh.dart';
import '../../../../shared/widgets/loading/q_loading_indicator.dart';
import '../../../../shared/widgets/media/q_network_image.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_piece.dart';
import '../../domain/repositories/profile_repository.dart';
import '../controllers/my_pieces_controller.dart';
import '../controllers/my_profile_controller.dart';
import '../controllers/profile_stats_controller.dart';
import '../widgets/profile_bio_block.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/profile_stats_row.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  final ScrollController _scroll = ScrollController();

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
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      ref.read(myPiecesControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait(<Future<void>>[
      ref.read(myProfileControllerProvider.notifier).refresh(),
      ref.read(profileStatsControllerProvider.notifier).refresh(),
      ref.read(myPiecesControllerProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Profile> profileAsync = ref.watch(
      myProfileControllerProvider,
    );

    return QScaffold(
      appBar: QAppBar(
        title: 'Profile',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const ProfileSkeleton(),
        error: (Object error, _) => QErrorView(
          failure: error is Failure
              ? error
              : const Failure.unexpected(code: 'unknown'),
          onRetry: () =>
              ref.read(myProfileControllerProvider.notifier).refresh(),
        ),
        data: (Profile profile) => QRefresh(
          onRefresh: _refreshAll,
          child: CustomScrollView(
            controller: _scroll,
            slivers: <Widget>[
              SliverToBoxAdapter(child: ProfileHeader(profile: profile)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    QSpacing.s4,
                    QSpacing.s4,
                    QSpacing.s4,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      QButton(
                        label: 'Edit profile',
                        icon: Icons.edit_outlined,
                        onPressed: () => context.push(Routes.profileEdit),
                      ),
                      Gap.v2,
                      _ProfileLink(
                        icon: Icons.collections_bookmark_outlined,
                        label: AppLocalizations.of(context).collectionsTitle,
                        onTap: () => context.push(Routes.collections),
                      ),
                      _ProfileLink(
                        icon: Icons.person_add_alt_1_outlined,
                        label: AppLocalizations.of(context).followRequestsTitle,
                        onTap: () => context.push(Routes.followRequests),
                      ),
                      Gap.v4,
                      ProfileBioBlock(profile: profile),
                      Gap.v4,
                      _StatsRow(publishedCount: profile.counts.piecesPublished),
                      Gap.v6,
                      Text(
                        'Published',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Gap.v2,
                    ],
                  ),
                ),
              ),
              const _PublishedPiecesSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: QSpacing.s6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact navigation row on the own-profile surface (Collections, Follow
/// requests) — a labelled, tappable list tile.
class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

/// The stat tiles — published (from the profile DTO) plus the drafts/bookmarks/
/// reading counts from the stats controller, with reading & bookmarks gated by the
/// owner's local content-privacy toggles.
class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.publishedCount});

  final int publishedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProfileStats? stats = ref
        .watch(profileStatsControllerProvider)
        .asData
        ?.value;
    final ContentPrivacy privacy = ref.watch(contentPrivacyControllerProvider);

    return ProfileStatsRow(
      stats: <ProfileStat>[
        ProfileStat(label: 'Published', value: '$publishedCount'),
        ProfileStat(label: 'Drafts', value: _bounded(stats?.drafts)),
        if (privacy.showBookmarks)
          ProfileStat(label: 'Bookmarks', value: _bounded(stats?.bookmarks)),
        if (privacy.showReadingHistory)
          ProfileStat(
            label: 'Reading',
            value: stats == null ? '—' : '${stats.readingHistory}',
          ),
      ],
    );
  }

  String _bounded(BoundedCount? count) {
    if (count == null) return '—';
    return count.hasMore ? '${count.count}+' : '${count.count}';
  }
}

class _PublishedPiecesSliver extends ConsumerWidget {
  const _PublishedPiecesSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PagedListState<ProfilePiece>> piecesAsync = ref.watch(
      myPiecesControllerProvider,
    );
    return piecesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(QSpacing.s6),
          child: Center(child: QLoadingIndicator()),
        ),
      ),
      error: (Object error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(QSpacing.s4),
          child: QErrorView(
            failure: error is Failure
                ? error
                : const Failure.unexpected(code: 'unknown'),
            onRetry: () =>
                ref.read(myPiecesControllerProvider.notifier).refresh(),
          ),
        ),
      ),
      data: (PagedListState<ProfilePiece> state) {
        if (state.isEmpty) {
          return const SliverToBoxAdapter(
            child: QEmptyState(
              icon: Icons.article_outlined,
              title: 'No published pieces yet.',
              message: 'Pieces you publish will appear here.',
              minHeight: 220,
            ),
          );
        }
        return SliverList.builder(
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index >= state.items.length) {
              return const Padding(
                padding: EdgeInsets.all(QSpacing.s4),
                child: Center(child: QLoadingIndicator()),
              );
            }
            return _PieceRow(piece: state.items[index]);
          },
        );
      },
    );
  }
}

class _PieceRow extends ConsumerWidget {
  const _PieceRow({required this.piece});

  final ProfilePiece piece;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final int minutes = (piece.readingTimeSeconds / 60).ceil().clamp(1, 999);
    return InkWell(
      onTap: () => context.push(Routes.piecePath(piece.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: QSpacing.s4,
          vertical: QSpacing.s3,
        ),
        child: Row(
          children: <Widget>[
            if (piece.coverImageKey != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: QNetworkImage(
                  url: ref
                      .watch(mediaUrlBuilderProvider)
                      .urlForKey(piece.coverImageKey),
                  width: 56,
                  height: 56,
                ),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tokens.colors.bgRaised,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.article_outlined,
                  color: tokens.colors.textMuted,
                ),
              ),
            Gap.h3,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    piece.title.isEmpty ? 'Untitled' : piece.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$minutes min read',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Followers and Following screens (docs/40 §follows) — a user's followers or
/// following list, cursor-paginated with pull-to-refresh, driven by the shared
/// follow controllers. Public/auth-aware (the backend gates privacy).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/social/presentation/controllers/follow_controllers.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../widgets/user_list_view.dart';

class FollowersScreen extends ConsumerWidget {
  const FollowersScreen({required this.username, super.key});

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = followersControllerProvider(username);
    return QScaffold(
      appBar: QAppBar(title: l10n.followersTitle),
      body: UserListView(
        state: ref.watch(provider),
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        emptyTitle: l10n.followersEmptyTitle,
        emptyBody: l10n.followersEmptyBody,
      ),
    );
  }
}

class FollowingScreen extends ConsumerWidget {
  const FollowingScreen({required this.username, super.key});

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = followingControllerProvider(username);
    return QScaffold(
      appBar: QAppBar(title: l10n.followingTitle),
      body: UserListView(
        state: ref.watch(provider),
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        emptyTitle: l10n.followingEmptyTitle,
        emptyBody: l10n.followingEmptyBody,
      ),
    );
  }
}

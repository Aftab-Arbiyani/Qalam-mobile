/// The follow-requests inbox (docs/40 §follows) — the signed-in user's incoming
/// pending requests, cursor-paginated, with accept / decline (optimistic removal
/// via the shared controller). Reached from a private account's profile.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/social/domain/entities/follow_user.dart';
import '../../../../shared/social/presentation/controllers/follow_controllers.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/content/author_byline.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class FollowRequestsScreen extends ConsumerWidget {
  const FollowRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = followRequestsControllerProvider;
    return QScaffold(
      appBar: QAppBar(title: l10n.followRequestsTitle),
      body: PagedFeedView<FollowRequest>(
        state: ref.watch(provider),
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        empty: QEmptyState(
          icon: Icons.person_add_alt_1_outlined,
          title: l10n.followRequestsEmptyTitle,
          message: l10n.followRequestsEmptyBody,
        ),
        itemBuilder: (BuildContext context, FollowRequest request, int index) {
          final String? avatarUrl = ref
              .watch(mediaUrlBuilderProvider)
              .urlForKey(request.requester.avatarKey);
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: QSpacing.s4,
              vertical: QSpacing.s2,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AuthorByline(
                    name: request.requester.displayName,
                    handle: request.requester.handle,
                    avatarUrl: avatarUrl,
                  ),
                ),
                Gap.h2,
                QButton(
                  label: l10n.followRequestAccept,
                  size: QButtonSize.sm,
                  variant: QButtonVariant.primary,
                  onPressed: () =>
                      ref.read(provider.notifier).accept(request.id),
                ),
                Gap.h1,
                QButton(
                  label: l10n.followRequestReject,
                  size: QButtonSize.sm,
                  variant: QButtonVariant.ghost,
                  onPressed: () =>
                      ref.read(provider.notifier).reject(request.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

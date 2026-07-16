/// The responses screen (docs/40 E7) — a piece's responses (infinite,
/// pull-to-refresh) plus "Write a response", which creates a linked draft and
/// opens it in the editor (owned by the writing feature, reached by route). A
/// response is a piece; tapping one opens the reader.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/utils/result.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/social/domain/entities/response_item.dart';
import '../../../../shared/social/presentation/controllers/responses_controller.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/social/response_tile.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class ResponsesScreen extends ConsumerWidget {
  const ResponsesScreen({
    required this.pieceId,
    this.languageCode = 'ur',
    super.key,
  });

  final String pieceId;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = responsesControllerProvider(pieceId);
    final bool authed =
        ref.watch(sessionControllerProvider).stateOrUnknown.isAuthenticated;

    return QScaffold(
      appBar: QAppBar(title: l10n.responsesTitle),
      floatingActionButton: authed
          ? FloatingActionButton.extended(
              onPressed: () => _writeResponse(context, ref),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.responseWrite),
            )
          : null,
      body: PagedFeedView<ResponseItem>(
        state: ref.watch(provider),
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        empty: QEmptyState(
          icon: Icons.forum_outlined,
          title: l10n.responsesEmptyTitle,
          message: l10n.responsesEmptyBody,
        ),
        itemBuilder: (BuildContext context, ResponseItem response, int index) =>
            ResponseTile(response: response),
      ),
    );
  }

  Future<void> _writeResponse(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await QHaptics.light();
    final Result<String> result = await ref
        .read(responsesControllerProvider(pieceId).notifier)
        .createResponse(languageCode: languageCode);
    if (!context.mounted) return;
    final String? draftId = result.valueOrNull;
    if (draftId != null) {
      unawaited(context.push(Routes.writeDraftPath(draftId)));
    } else {
      QSnackbar.show(
        context,
        message: l10n.socialActionFailed,
        variant: QSnackbarVariant.danger,
      );
    }
  }
}

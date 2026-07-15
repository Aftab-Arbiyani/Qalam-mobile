/// Offline banner (docs/41 §30, §31). A slim, unobtrusive strip shown while
/// offline; it never blocks content and disappears on reconnect.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/connectivity_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/q_tokens.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool online = ref
        .watch(connectivityStatusProvider)
        .maybeWhen(data: (bool value) => value, orElse: () => true);
    if (online) return const SizedBox.shrink();

    final QTokens tokens = QTokens.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      color: tokens.colors.warningBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off, size: 16, color: tokens.colors.warningText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.connectivityOffline,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.colors.warningText),
            ),
          ),
        ],
      ),
    );
  }
}

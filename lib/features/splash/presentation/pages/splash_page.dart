import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/branding/q_brand_mark.dart';
import '../../../../shared/widgets/loading/q_loading_indicator.dart';

/// Splash — shown while the session boot-restore is in flight (docs/40 §11.2).
/// The router leaves it for a real destination once the session resolves.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: tokens.colors.bgCanvas,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const QBrandMark(size: 96, semanticLabel: null),
            Gap.v3,
            Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
            Gap.v6,
            const QLoadingIndicator(size: 20),
          ],
        ),
      ),
    );
  }
}

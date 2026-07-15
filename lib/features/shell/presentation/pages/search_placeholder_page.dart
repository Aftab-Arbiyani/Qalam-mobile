import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/feature_placeholder.dart';

/// Search tab — placeholder (real search ships in M8).
class SearchPlaceholderPage extends StatelessWidget {
  const SearchPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return FeaturePlaceholder(
      title: l10n.navSearch,
      icon: Icons.search_outlined,
      body: l10n.placeholderSearchBody,
    );
  }
}

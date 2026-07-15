/// Shared layout for the auth corridor screens (docs/41 §24, §28). A calm,
/// single-column, keyboard-aware page: a large headline + subtitle, then the form
/// body, centered and width-capped for tablets/landscape. Tapping outside a field
/// dismisses the keyboard (docs/41 §28); the whole form is wrapped in an
/// [AutofillGroup] so platform autofill can complete across fields.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);

    return QScaffold(
      appBar: const QAppBar(title: ''),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: QSpacing.s5,
            vertical: QSpacing.s4,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Gap.v4,
                    Text(title, style: theme.textTheme.headlineSmall),
                    if (subtitle != null) ...<Widget>[
                      Gap.v2,
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ],
                    Gap.v6,
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

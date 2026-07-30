/// A single onboarding slide (docs/41 §1, §33) — a calm icon in an accent-tinted
/// circle, a title, and a warm body. Literary, unhurried, generous whitespace.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({required this.data, super.key});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: QSpacing.s6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.colors.accentSubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 40, color: tokens.colors.accent),
          ),
          Gap.v6,
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          Gap.v3,
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

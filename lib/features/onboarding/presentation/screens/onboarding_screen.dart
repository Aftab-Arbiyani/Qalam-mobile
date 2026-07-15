/// Onboarding carousel (docs/40 §11.5, docs/41 §1). A three-slide introduction —
/// welcome · platform features · privacy — shown once on first launch. Skip and
/// Finish both persist completion (via the core [OnboardingController]) and hand off
/// to the auth flow. Fully offline (no network). Page changes give a light haptic.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/session/onboarding_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/motion_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/haptics/q_haptics.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<OnboardingSlideData> _slides(AppLocalizations l10n) =>
      <OnboardingSlideData>[
        OnboardingSlideData(
          icon: Icons.menu_book_outlined,
          title: l10n.onboardingWelcomeTitle,
          body: l10n.onboardingWelcomeBody,
        ),
        OnboardingSlideData(
          icon: Icons.auto_stories_outlined,
          title: l10n.onboardingFeaturesTitle,
          body: l10n.onboardingFeaturesBody,
        ),
        OnboardingSlideData(
          icon: Icons.shield_outlined,
          title: l10n.onboardingPrivacyTitle,
          body: l10n.onboardingPrivacyBody,
        ),
      ];

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (mounted) context.go(Routes.login);
  }

  void _next(int lastIndex) {
    if (_page >= lastIndex) {
      unawaited(_finish());
      return;
    }
    unawaited(QHaptics.selection());
    _pageController.nextPage(
      duration: QDurations.base,
      curve: QCurves.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final List<OnboardingSlideData> slides = _slides(l10n);
    final int lastIndex = slides.length - 1;
    final bool onLast = _page == lastIndex;

    return QScaffold(
      showOfflineBanner: false,
      body: Column(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.all(QSpacing.s2),
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.onboardingSkip),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (int index) => setState(() => _page = index),
              itemBuilder: (_, int index) =>
                  OnboardingSlide(data: slides[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(QSpacing.s5),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < slides.length; i++) ...<Widget>[
                      AnimatedContainer(
                        duration: QDurations.base,
                        width: i == _page ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? tokens.colors.accent
                              : tokens.colors.border,
                          borderRadius: QRadii.controlRadius,
                        ),
                      ),
                      if (i < lastIndex) const SizedBox(width: QSpacing.s1),
                    ],
                  ],
                ),
                Gap.v6,
                QButton(
                  label: onLast
                      ? l10n.onboardingGetStarted
                      : l10n.onboardingNext,
                  variant: QButtonVariant.primary,
                  size: QButtonSize.lg,
                  block: true,
                  onPressed: () => _next(lastIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

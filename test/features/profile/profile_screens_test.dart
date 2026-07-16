import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_counts.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_piece.dart';
import 'package:qalam_mobile/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:qalam_mobile/features/profile/presentation/screens/privacy_settings_screen.dart';
import 'package:qalam_mobile/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_profile_repository.dart';
import '../../support/harness.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  required FakeProfileRepository repo,
}) async {
  // A tall surface so lazily-built slivers (piece rows / empty state) lay out
  // without needing to scroll them into view.
  tester.view.physicalSize = const Size(500, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  late final Widget app;
  await tester.runAsync(() async {
    app = await buildTestApp(
      profileRepository: repo,
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    );
  });
  await tester.pumpWidget(app);
  await settleFrames(tester);
}

void main() {
  testWidgets('My Profile renders header, stats, and a published piece', (
    WidgetTester tester,
  ) async {
    final FakeProfileRepository repo = FakeProfileRepository(
      publishedPieces: <ProfilePiece>[
        const ProfilePiece(id: 'p1', title: 'Rain at Midnight'),
      ],
    );
    await _pump(tester, const MyProfileScreen(), repo: repo);

    expect(find.text('Meera K.'), findsOneWidget);
    expect(find.text('@meera_k'), findsOneWidget);
    expect(find.text('Published'), findsWidgets);
    expect(find.text('Rain at Midnight'), findsOneWidget);
  });

  testWidgets('My Profile shows an empty state with no published pieces', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const MyProfileScreen(), repo: FakeProfileRepository());
    expect(find.text('No published pieces yet.'), findsOneWidget);
  });

  testWidgets('Public Profile shows a private teaser when restricted', (
    WidgetTester tester,
  ) async {
    final FakeProfileRepository repo = FakeProfileRepository(
      profile: const Profile(
        id: 'u9',
        username: 'hidden',
        penName: 'Hidden',
        isPrivate: true,
        restricted: true,
        counts: ProfileCounts(followers: 4),
      ),
    );
    await _pump(
      tester,
      const PublicProfileScreen(username: 'hidden'),
      repo: repo,
    );

    expect(find.text('This account is private.'), findsOneWidget);
    expect(find.text('Followers'), findsWidgets);
  });

  testWidgets('Privacy screen toggling Private account calls the repo', (
    WidgetTester tester,
  ) async {
    final FakeProfileRepository repo = FakeProfileRepository();
    await _pump(tester, const PrivacySettingsScreen(), repo: repo);

    expect(find.text('Private account'), findsOneWidget);
    await tester.tap(find.text('Private account'));
    await settleFrames(tester);

    expect(repo.updateCalls, 1);
    expect(repo.lastEdit?.isPrivate, isTrue);
  });
}

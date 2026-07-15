import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_counts.dart';
import 'package:qalam_mobile/features/profile/domain/entities/viewer_relation.dart';
import 'package:qalam_mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:qalam_mobile/features/profile/presentation/widgets/profile_stats_row.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

const Profile _profile = Profile(
  id: 'u1',
  username: 'meera_k',
  penName: 'Meera K.',
  bio: 'Poems at midnight; ghazals at dawn.',
  location: 'Lahore',
  websiteUrl: 'https://meera.example',
  genres: <GenreRef>[
    GenreRef(slug: 'ghazal', name: 'Ghazal'),
    GenreRef(slug: 'nazm', name: 'Nazm'),
  ],
  counts: ProfileCounts(followers: 128, following: 37, piecesPublished: 12),
  viewerRelation: ViewerRelation(isSelf: true),
);

Widget _scoped(Brightness brightness, Widget child) => ProviderScope(
  overrides: [appConfigProvider.overrideWithValue(testConfig)],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildQalamTheme(brightness: brightness),
    home: Scaffold(body: SizedBox(width: 380, child: child)),
  ),
);

void main() {
  testWidgets('ProfileHeader — light', (WidgetTester tester) async {
    await tester.pumpWidget(
      _scoped(Brightness.light, const ProfileHeader(profile: _profile)),
    );
    await tester.pump();
    await expectLater(
      find.byType(ProfileHeader),
      matchesGoldenFile('goldens/profile_header_light.png'),
    );
  });

  testWidgets('ProfileStatsRow — light', (WidgetTester tester) async {
    await tester.pumpWidget(
      _scoped(
        Brightness.light,
        const Padding(
          padding: EdgeInsets.all(16),
          child: ProfileStatsRow(
            stats: <ProfileStat>[
              ProfileStat(label: 'Published', value: '12'),
              ProfileStat(label: 'Drafts', value: '3'),
              ProfileStat(label: 'Bookmarks', value: '50+'),
              ProfileStat(label: 'Reading', value: '87'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(ProfileStatsRow),
      matchesGoldenFile('goldens/profile_stats_row_light.png'),
    );
  });

  testWidgets('ProfileStatsRow — dark', (WidgetTester tester) async {
    await tester.pumpWidget(
      _scoped(
        Brightness.dark,
        const Padding(
          padding: EdgeInsets.all(16),
          child: ProfileStatsRow(
            stats: <ProfileStat>[
              ProfileStat(label: 'Published', value: '12'),
              ProfileStat(label: 'Followers', value: '128'),
              ProfileStat(label: 'Following', value: '37'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(ProfileStatsRow),
      matchesGoldenFile('goldens/profile_stats_row_dark.png'),
    );
  });
}

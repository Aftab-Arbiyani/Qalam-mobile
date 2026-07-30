import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/search/presentation/widgets/search_result_tiles.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/domain/entities/trend_item.dart';
import 'package:qalam_mobile/shared/domain/entities/writer_summary.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

Widget _scene(Brightness brightness) => ProviderScope(
  overrides: [appConfigProvider.overrideWithValue(testConfig)],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildQalamTheme(brightness: brightness),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 390,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const WriterResultTile(
                writer: WriterSummary(
                  username: 'meera_k',
                  penName: 'Meera Kulkarni',
                  bio: 'Writes ghazals about rain and longing.',
                  followersCount: 1240,
                ),
              ),
              const WriterResultTile(
                writer: WriterSummary(
                  username: 'private_pen',
                  penName: 'A Private Pen',
                  isPrivate: true,
                ),
              ),
              tagResultTile(
                const TrendingTag(slug: 'barish', name: 'barish', pieceCount: 42),
                () {},
              ),
              languageResultTile(
                const TrendingLanguage(
                  code: 'ur',
                  nativeName: 'اردو',
                  direction: TextDirectionKind.rtl,
                  pieceCount: 88,
                ),
                () {},
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('search result tiles — light', (WidgetTester tester) async {
    await tester.pumpWidget(_scene(Brightness.light));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/search_result_tiles_light.png'),
    );
  });

  testWidgets('search result tiles — dark', (WidgetTester tester) async {
    await tester.pumpWidget(_scene(Brightness.dark));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/search_result_tiles_dark.png'),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/social/domain/entities/comment.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';
import 'package:qalam_mobile/shared/widgets/social/comment_tile.dart';

import '../../../support/harness.dart';

Widget _scene(Brightness brightness) => ProviderScope(
  overrides: [appConfigProvider.overrideWithValue(testConfig)],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildQalamTheme(brightness: brightness),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CommentTile(
              comment: Comment(
                id: 'c1',
                author: const CommentAuthor(
                  username: 'meera_k',
                  penName: 'Meera',
                ),
                body: 'This ghazal undid me — the last couplet especially.',
                replyCount: 2,
                createdAt: DateTime.utc(2026, 7, 16, 10),
                editedAt: DateTime.utc(2026, 7, 16, 11),
              ),
              pieceId: 'p1',
            ),
            const CommentTile(
              comment: Comment(id: 'c2', isDeleted: true),
              pieceId: 'p1',
            ),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('comment tiles — light', (WidgetTester tester) async {
    await tester.pumpWidget(_scene(Brightness.light));
    await tester.pump();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/comment_tiles_light.png'),
    );
  });

  testWidgets('comment tiles — dark', (WidgetTester tester) async {
    await tester.pumpWidget(_scene(Brightness.dark));
    await tester.pump();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/comment_tiles_dark.png'),
    );
  });
}
